import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CreateFlowType { single, package }

class CreateFlowState {
  final int currentPage;
  final CreateFlowType? flowType;
  final bool isSaving;

  const CreateFlowState({
    this.currentPage = 0,
    this.flowType,
    this.isSaving = false,
  });

  bool get isPackageFlow => flowType == CreateFlowType.package;

  int get totalSteps => isPackageFlow ? 5 : 5;

  CreateFlowState copyWith({
    int? currentPage,
    CreateFlowType? flowType,
    bool? isSaving,
  }) {
    return CreateFlowState(
      currentPage: currentPage ?? this.currentPage,
      flowType: flowType ?? this.flowType,
      isSaving: isSaving ?? this.isSaving,
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

  void clear() {
    state = const CreateFlowState();
  }
}

final createFlowControllerProvider =
    NotifierProvider<CreateFlowController, CreateFlowState>(
      CreateFlowController.new,
    );
