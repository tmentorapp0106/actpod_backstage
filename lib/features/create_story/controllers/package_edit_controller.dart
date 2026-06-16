import 'package:actpod_studio/api/response/story_response/package_models.dart';
import 'package:actpod_studio/api/story_system_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _unset = Object();

@immutable
class PackageEditState {
  final List<PremiumPackage> editablePackages;
  final List<Price> packagePrices;
  final bool loadingEditablePackages;
  final bool loadingPackageInfo;
  final String? selectedPackageId;
  final String? loadedPackageId;
  final PackageInfo? packageInfo;
  final String? error;

  const PackageEditState({
    this.editablePackages = const [],
    this.packagePrices = const [],
    this.loadingEditablePackages = false,
    this.loadingPackageInfo = false,
    this.selectedPackageId,
    this.loadedPackageId,
    this.packageInfo,
    this.error,
  });

  PackageEditState copyWith({
    List<PremiumPackage>? editablePackages,
    List<Price>? packagePrices,
    bool? loadingEditablePackages,
    bool? loadingPackageInfo,
    Object? selectedPackageId = _unset,
    Object? loadedPackageId = _unset,
    Object? packageInfo = _unset,
    Object? error = _unset,
  }) {
    return PackageEditState(
      editablePackages: editablePackages ?? this.editablePackages,
      packagePrices: packagePrices ?? this.packagePrices,
      loadingEditablePackages:
          loadingEditablePackages ?? this.loadingEditablePackages,
      loadingPackageInfo: loadingPackageInfo ?? this.loadingPackageInfo,
      selectedPackageId: selectedPackageId == _unset
          ? this.selectedPackageId
          : selectedPackageId as String?,
      loadedPackageId: loadedPackageId == _unset
          ? this.loadedPackageId
          : loadedPackageId as String?,
      packageInfo: packageInfo == _unset
          ? this.packageInfo
          : packageInfo as PackageInfo?,
      error: error == _unset ? this.error : error as String?,
    );
  }
}

class PackageEditController extends Notifier<PackageEditState> {
  @override
  PackageEditState build() => const PackageEditState();

  Future<void> loadEditablePackages(String userId) async {
    if (state.loadingEditablePackages) return;

    state = state.copyWith(loadingEditablePackages: true, error: null);
    try {
      final response = await StoryApi().getUserPackages(userId);
      state = state.copyWith(
        editablePackages: response.packages,
        selectedPackageId:
            response.packages.any(
              (package) => package.packageId == state.selectedPackageId,
            )
            ? state.selectedPackageId
            : null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(loadingEditablePackages: false);
    }
  }

  void selectPackage(String packageId) {
    state = state.copyWith(
      selectedPackageId: packageId,
      loadedPackageId: null,
      packageInfo: null,
      packagePrices: const [],
      error: null,
    );
  }

  Future<SelectedPackageEditData?> loadSelectedPackageInfo() async {
    final packageId = state.selectedPackageId;
    if (packageId == null || packageId.isEmpty) return null;
    if (state.loadingPackageInfo && state.packageInfo != null) {
      return SelectedPackageEditData(
        packageInfo: state.packageInfo!,
        prices: state.packagePrices,
      );
    }
    if (state.loadedPackageId == packageId && state.packageInfo != null) {
      return SelectedPackageEditData(
        packageInfo: state.packageInfo!,
        prices: state.packagePrices,
      );
    }

    state = state.copyWith(loadingPackageInfo: true, error: null);
    try {
      final api = StoryApi();
      final response = await api.getPackageInfo(packageId);
      final pricesResponse = await api.getPackagePrices(packageId);
      final packageInfo = response.packageInfo;
      if (packageInfo == null) {
        state = state.copyWith(
          error: response.message,
          packageInfo: null,
          packagePrices: const [],
        );
        return null;
      }

      state = state.copyWith(
        packageInfo: packageInfo,
        packagePrices: pricesResponse.prices,
        loadedPackageId: packageId,
      );
      return SelectedPackageEditData(
        packageInfo: packageInfo,
        prices: pricesResponse.prices,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        packageInfo: null,
        packagePrices: const [],
      );
      return null;
    } finally {
      state = state.copyWith(loadingPackageInfo: false);
    }
  }

  void clear() {
    state = const PackageEditState();
  }
}

class SelectedPackageEditData {
  final PackageInfo packageInfo;
  final List<Price> prices;

  const SelectedPackageEditData({
    required this.packageInfo,
    required this.prices,
  });
}

final packageEditControllerProvider =
    NotifierProvider<PackageEditController, PackageEditState>(
      PackageEditController.new,
    );
