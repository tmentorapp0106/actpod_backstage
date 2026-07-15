import 'package:actpod_studio/api/story_system_api.dart';
import 'package:actpod_studio/api/response/story_response/batch_get_user_stories.dart';
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
      final packageNames = {
        for (final package in packagesResponse.packages)
          package.packageId: package.packageName,
      };

      final singleStories = stories
          .where((story) => story.packageId.isEmpty)
          .toList();
      final packageGroups = <String, List<StoryItem>>{};
      for (final story in stories.where(
        (story) => story.packageId.isNotEmpty,
      )) {
        packageGroups.putIfAbsent(story.packageId, () => []).add(story);
      }

      final singleCounts = await Future.wait(
        singleStories.map(
          (story) => api.getPurchaseRecordCount(storyId: story.storyId),
        ),
      );

      final packageIds = packageGroups.keys.toList();
      final packageCounts = await Future.wait(
        packageIds.map(
          (packageId) => api.getPurchaseRecordCount(packageId: packageId),
        ),
      );

      final singleEntries = [
        for (var i = 0; i < singleStories.length; i++)
          PremiumSaleEntry(
            type: PremiumSaleType.single,
            targetId: singleStories[i].storyId,
            title: singleStories[i].storyName,
            subtitle: singleStories[i].channelName,
            salesCount: singleCounts[i].count,
            stories: [singleStories[i]],
          ),
      ]..sort((a, b) => b.salesCount.compareTo(a.salesCount));

      final packageEntries = [
        for (var i = 0; i < packageIds.length; i++)
          PremiumSaleEntry(
            type: PremiumSaleType.package,
            targetId: packageIds[i],
            title: packageNames[packageIds[i]]?.trim().isNotEmpty == true
                ? packageNames[packageIds[i]]!
                : 'Package ${i + 1}',
            subtitle:
                '${packageGroups[packageIds[i]]!.length} 個 premium stories',
            salesCount: packageCounts[i].count,
            stories: packageGroups[packageIds[i]]!.cast(),
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

final premiumSalesControllerProvider =
    NotifierProvider<PremiumSalesController, PremiumSalesState>(
      PremiumSalesController.new,
    );
