import 'package:actpod_studio/api/response/story_response/batch_get_user_stories.dart';
import 'package:actpod_studio/api/response/story_response/package_models.dart';
import 'package:flutter/foundation.dart';

enum PremiumSaleType { single, package }

@immutable
class PremiumSaleEntry {
  final PremiumSaleType type;
  final String targetId;
  final String title;
  final String subtitle;
  final int salesCount;
  final List<StoryItem> stories;

  const PremiumSaleEntry({
    required this.type,
    required this.targetId,
    required this.title,
    required this.subtitle,
    required this.salesCount,
    required this.stories,
  });

  bool get isPackage => type == PremiumSaleType.package;
}

@immutable
class PremiumSalesState {
  final bool loading;
  final String? error;
  final List<PremiumSaleEntry> singleStories;
  final List<PremiumSaleEntry> packages;

  const PremiumSalesState({
    required this.loading,
    required this.error,
    required this.singleStories,
    required this.packages,
  });

  const PremiumSalesState.initial()
    : loading = false,
      error = null,
      singleStories = const [],
      packages = const [];

  PremiumSalesState copyWith({
    bool? loading,
    Object? error = _sentinel,
    List<PremiumSaleEntry>? singleStories,
    List<PremiumSaleEntry>? packages,
  }) {
    return PremiumSalesState(
      loading: loading ?? this.loading,
      error: identical(error, _sentinel) ? this.error : error as String?,
      singleStories: singleStories ?? this.singleStories,
      packages: packages ?? this.packages,
    );
  }
}

const _sentinel = Object();

@immutable
class PurchaseRecordDetailViewModel {
  final bool loading;
  final String? error;
  final String title;
  final String subtitle;
  final PremiumSaleType type;
  final String targetId;
  final int total;
  final int page;
  final int pageSize;
  final List<PurchaseRecord> records;
  final List<StoryItem> stories;

  const PurchaseRecordDetailViewModel({
    required this.loading,
    required this.error,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.targetId,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.records,
    required this.stories,
  });
}
