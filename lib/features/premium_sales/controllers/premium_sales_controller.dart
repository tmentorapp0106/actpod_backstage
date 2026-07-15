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

      final userPackages = packagesResponse.packages
          .where((package) => package.packageId.isNotEmpty)
          .toList();
      final packageIds = userPackages
          .map((package) => package.packageId)
          .toList();
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
        for (var i = 0; i < userPackages.length; i++)
          PremiumSaleEntry(
            type: PremiumSaleType.package,
            targetId: userPackages[i].packageId,
            title: userPackages[i].packageName.trim().isNotEmpty
                ? userPackages[i].packageName
                : 'Package ${i + 1}',
            subtitle: userPackages[i].packageDescription.trim().isNotEmpty
                ? userPackages[i].packageDescription
                : userPackages[i].channelId,
            salesCount: packageCounts[i].count,
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

final premiumSalesControllerProvider =
    NotifierProvider<PremiumSalesController, PremiumSalesState>(
      PremiumSalesController.new,
    );
