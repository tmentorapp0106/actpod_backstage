import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CreateFlowType { single, package }

const _unset = Object();

enum UploadQueueItemStatus { pending, active, done, failed }

class UploadQueueItem {
  final String id;
  final String label;
  final UploadQueueItemStatus status;

  const UploadQueueItem({
    required this.id,
    required this.label,
    this.status = UploadQueueItemStatus.pending,
  });

  UploadQueueItem copyWith({
    String? id,
    String? label,
    UploadQueueItemStatus? status,
  }) {
    return UploadQueueItem(
      id: id ?? this.id,
      label: label ?? this.label,
      status: status ?? this.status,
    );
  }
}

class CreateFlowState {
  final int currentPage;
  final CreateFlowType? flowType;
  final bool isSaving;
  final List<UploadQueueItem> uploadItems;
  final String? currentUploadLabel;

  const CreateFlowState({
    this.currentPage = 0,
    this.flowType,
    this.isSaving = false,
    this.uploadItems = const [],
    this.currentUploadLabel,
  });

  bool get isPackageFlow => flowType == CreateFlowType.package;

  int get totalSteps => isPackageFlow ? 5 : 5;

  int get completedUploadCount => uploadItems
      .where((item) => item.status == UploadQueueItemStatus.done)
      .length;

  CreateFlowState copyWith({
    int? currentPage,
    CreateFlowType? flowType,
    bool? isSaving,
    List<UploadQueueItem>? uploadItems,
    Object? currentUploadLabel = _unset,
  }) {
    return CreateFlowState(
      currentPage: currentPage ?? this.currentPage,
      flowType: flowType ?? this.flowType,
      isSaving: isSaving ?? this.isSaving,
      uploadItems: uploadItems ?? this.uploadItems,
      currentUploadLabel: currentUploadLabel == _unset
          ? this.currentUploadLabel
          : currentUploadLabel as String?,
    );
  }
}

class CreateFlowController extends Notifier<CreateFlowState> {
  @override
  CreateFlowState build() => const CreateFlowState();

  void setFlowType(CreateFlowType type) {
    state = state.copyWith(flowType: type, currentPage: 0);
  }

  void next(int totalSteps) {
    if (state.currentPage < totalSteps - 1) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void back() {
    if (state.currentPage > 0) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  void jumpTo(int index, int totalSteps) {
    state = state.copyWith(currentPage: index.clamp(0, totalSteps - 1));
  }

  void setSaving(bool saving) {
    state = state.copyWith(isSaving: saving);
  }

  void beginUploadQueue(List<UploadQueueItem> items) {
    state = state.copyWith(
      isSaving: true,
      uploadItems: items,
      currentUploadLabel: items.isEmpty ? null : items.first.label,
    );
  }

  void markUploadActive(String id) {
    String? label;
    final updated = [
      for (final item in state.uploadItems)
        if (item.id == id)
          (() {
            label = item.label;
            return item.copyWith(status: UploadQueueItemStatus.active);
          })()
        else if (item.status == UploadQueueItemStatus.active)
          item.copyWith(status: UploadQueueItemStatus.pending)
        else
          item,
    ];
    state = state.copyWith(uploadItems: updated, currentUploadLabel: label);
  }

  void markUploadDone(String id) {
    state = state.copyWith(
      uploadItems: [
        for (final item in state.uploadItems)
          if (item.id == id)
            item.copyWith(status: UploadQueueItemStatus.done)
          else
            item,
      ],
    );
  }

  void markUploadFailed(String id) {
    UploadQueueItem? failedItem;
    for (final item in state.uploadItems) {
      if (item.id == id) {
        failedItem = item;
        break;
      }
    }
    state = state.copyWith(
      uploadItems: [
        for (final item in state.uploadItems)
          if (item.id == id)
            item.copyWith(status: UploadQueueItemStatus.failed)
          else
            item,
      ],
      currentUploadLabel: failedItem?.label,
    );
  }

  void clearUploadQueue() {
    state = state.copyWith(
      uploadItems: const [],
      currentUploadLabel: null,
      isSaving: false,
    );
  }

  void clear() {
    state = const CreateFlowState();
  }
}

final createFlowControllerProvider =
    NotifierProvider<CreateFlowController, CreateFlowState>(
      CreateFlowController.new,
    );
