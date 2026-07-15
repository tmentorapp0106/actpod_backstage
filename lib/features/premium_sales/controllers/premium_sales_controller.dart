import 'package:actpod_studio/api/story_system_api.dart';
import 'package:actpod_studio/api/response/story_response/batch_get_user_stories.dart';
import 'package:actpod_studio/api/response/story_response/get_purchase_record_count.dart';
import 'package:actpod_studio/features/premium_sales/models/premium_sales_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PremiumSalesController extends Notifier<PremiumSalesState> {
  @override
  PremiumSalesState build() => const PremiumSalesState.initial();

  Future<void> load(String userId) async {
    if (userId.isEmpty || state.loading) return;

    state = state.copyWith(loading: true, error: null);
    try {
      final api = StoryApi();
      final storiesResponse = await api.getStoriesByUserId(
        userId,
        filterReviewStatus: false,
        isPremium: true,
      );
      final packagesResponse = await api.getUserPackages(userId);
      final stories = [...?storiesResponse.storyList]
        ..sort((a, b) => b.releaseTime.compareTo(a.releaseTime));
      final singleStories = stories
          .where((story) => story.packageId.isEmpty)
          .toList();
      final packageGroups = <String, List<StoryItem>>{};
      for (final story in stories.where(
        (story) => story.packageId.isNotEmpty,
      )) {
        packageGroups.putIfAbsent(story.packageId, () => []).add(story);
      }

      final userPackages = packagesResponse.packages
          .where((package) => package.packageId.isNotEmpty)
          .toList();
      final countResponse = await api.getPurchaseRecordCount(
        storyIds: singleStories.map((story) => story.storyId).toList(),
        packageIds: userPackages.map((package) => package.packageId).toList(),
      );
      final countByStoryId = <String, int>{};
      final countByPackageId = <String, int>{};
      for (final item in countResponse.data) {
        _applyCount(item, countByStoryId, countByPackageId);
      }

      final singleEntries = [
        for (var i = 0; i < singleStories.length; i++)
          PremiumSaleEntry(
            type: PremiumSaleType.single,
            targetId: singleStories[i].storyId,
            title: singleStories[i].storyName,
            subtitle: singleStories[i].channelName,
            imageUrl: singleStories[i].storyImageUrl.isNotEmpty
                ? singleStories[i].storyImageUrl
                : (singleStories[i].storyImageUrls.isNotEmpty
                      ? singleStories[i].storyImageUrls.first
                      : ''),
            salesCount: countByStoryId[singleStories[i].storyId] ?? 0,
            stories: [singleStories[i]],
          ),
      ]..sort((a, b) => b.salesCount.compareTo(a.salesCount));

      final packageEntries = [
        for (var i = 0; i < userPackages.length; i++)
          PremiumSaleEntry(
            type: PremiumSaleType.package,
            targetId: userPackages[i].packageId,
            title: userPackages[i].packageName.trim().isNotEmpty
                ? userPackages[i].packageName
                : 'Package ${i + 1}',
            subtitle: '',
            imageUrl: userPackages[i].packageImageUrl,
            salesCount: countByPackageId[userPackages[i].packageId] ?? 0,
            stories: packageGroups[userPackages[i].packageId] ?? const [],
          ),
      ]..sort((a, b) => b.salesCount.compareTo(a.salesCount));

      state = state.copyWith(
        loading: false,
        singleStories: singleEntries,
        packages: packageEntries,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}

void _applyCount(
  PurchaseRecordCountInfo item,
  Map<String, int> countByStoryId,
  Map<String, int> countByPackageId,
) {
  if (item.storyId.isNotEmpty) {
    countByStoryId[item.storyId] = item.count;
  }
  if (item.packageId.isNotEmpty) {
    countByPackageId[item.packageId] = item.count;
  }
}

final premiumSalesControllerProvider =
    NotifierProvider<PremiumSalesController, PremiumSalesState>(
      PremiumSalesController.new,
    );
