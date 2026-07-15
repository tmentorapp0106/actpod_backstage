import 'package:actpod_studio/api/api.dart';
import 'package:actpod_studio/api/response/story_response/batch_get_listen_count.dart';
import 'package:actpod_studio/api/response/story_response/batch_get_user_stories.dart';
import 'package:actpod_studio/api/response/story_response/create_package.dart';
import 'package:actpod_studio/api/response/story_response/create_package_story.dart';
import 'package:actpod_studio/api/response/story_response/get_package_info.dart';
import 'package:actpod_studio/api/response/story_response/get_purchase_record_count.dart';
import 'package:actpod_studio/api/response/story_response/get_purchase_records.dart';
import 'package:actpod_studio/api/response/story_response/get_user_packages.dart';
import 'package:actpod_studio/api/response/story_response/package_models.dart';
import 'package:actpod_studio/api/response/story_response/update_package.dart';
import 'package:actpod_studio/api/response/story_response/update_package_story.dart';
import 'package:actpod_studio/api/response/story_response/upload_story.dart';

class StoryApi {
  Future<BatchGetListenCountResponse> batchGetListenCount(
    List<String> storyIds,
  ) async {
    final data = {"storyIds": storyIds};

    final response = await DioClient.handelPostWithToken(
      "/story/listenCount/batchGet",
      data,
    );
    return BatchGetListenCountResponse.fromResponse(response);
  }

  Future<GetPackagePricesResponse> getPackagePrices(String packageId) async {
    final response = await DioClient.handelGet(
      "/story/price/package/$packageId",
      {},
    );
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};
    return GetPackagePricesResponse.fromJson(json);
  }

  Future<GetPackageActivePriceResponse> getPackageActivePrice(
    String packageId,
  ) async {
    final response = await DioClient.handelGet(
      "/story/price/package/active/$packageId",
      {},
    );
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};
    return GetPackageActivePriceResponse.fromJson(json);
  }

  Future<GetStoryActivePriceResponse> getStoryActivePrice(
    String storyId,
  ) async {
    final response = await DioClient.handelGet(
      "/story/price/story/active/$storyId",
      {},
    );
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};
    return GetStoryActivePriceResponse.fromJson(json);
  }

  Future<GetPackageInfoResponse> getPackageInfo(String packageId) async {
    final response = await DioClient.handelGet("/story/package/$packageId", {});
    return GetPackageInfoResponse.fromResponse(response);
  }

  Future<GetUserPackagesResponse> getUserPackages(String userId) async {
    final response = await DioClient.handelGet(
      "/story/package/user/$userId",
      {},
    );
    return GetUserPackagesResponse.fromResponse(response);
  }

  Future<GetPurchaseRecordCountResponse> getPurchaseRecordCount({
    String? storyId,
    String? packageId,
  }) async {
    final query = <String, dynamic>{
      if (storyId?.isNotEmpty ?? false) 'storyId': storyId,
      if (packageId?.isNotEmpty ?? false) 'packageId': packageId,
    };
    final response = await DioClient.handelGet(
      "/story/premium/record/count",
      query,
    );
    return GetPurchaseRecordCountResponse.fromResponse(response);
  }

  Future<GetPurchaseRecordsResponse> getPurchaseRecords({
    String? storyId,
    String? packageId,
    dynamic page,
    dynamic pageSize,
  }) async {
    final query = <String, dynamic>{
      if (storyId?.isNotEmpty ?? false) 'storyId': storyId,
      if (packageId?.isNotEmpty ?? false) 'packageId': packageId,
      'page': _parsePageOrDefault(page, 1),
      'pageSize': _parsePageOrDefault(pageSize, 20),
    };
    final response = await DioClient.handelGet("/story/premium/records", query);
    return GetPurchaseRecordsResponse.fromResponse(response);
  }

  Future<UploadStoryResponse> uploadStory(
    String spaceId,
    String channelId,
    String contentUrl,
    String storyName,
    String storyDescription,
    List<String> storyImageUrls,
    int storyMilliSec,
    int previewStartFrom,
    int previewEndAt,
    String voiceMessageStatus,
    bool isPremium,
    int podcoins,
    int twd,
    bool isAdult,
    String? collaboratorId,
    DateTime? releaseTime,
  ) async {
    var data = {
      "contentUrl": contentUrl,
      "spaceId": spaceId,
      "channelId": channelId,
      "storyName": storyName,
      "storyDescription": storyDescription,
      "storyImageUrls": storyImageUrls,
      "storyMilliSec": storyMilliSec,
      "previewStartFrom": previewStartFrom,
      "previewEndAt": previewEndAt,
      "voiceMessageStatus": voiceMessageStatus,
      "isPremium": isPremium,
      "podcoins": podcoins,
      "twd": twd,
      "contentRating": isAdult ? "adult" : "general",
      "collaboratorId": collaboratorId,
      "releaseTime": releaseTime?.toUtc().toIso8601String(),
    };

    final response = await DioClient.handelPostWithToken("/story/", data);
    return UploadStoryResponse.fromResponse(response);
  }

  Future<CreatePackageResponse> createPackage(
    String userId,
    String packageName,
    String packageDescription,
    String packageImageUrl,
    String coverImageUrl,
    List<PackagePrice> packagePrices,
  ) async {
    var data = {
      "userId": userId,
      "packageName": packageName,
      "packageDescription": packageDescription,
      "packageImageUrl": packageImageUrl,
      "coverImageUrl": coverImageUrl,
      "packagePrices": packagePrices.map((price) => price.toJson()).toList(),
    };

    final response = await DioClient.handelPostWithToken(
      "/story/package",
      data,
    );
    return CreatePackageResponse.fromResponse(response);
  }

  Future<UpdatePackageResponse> updatePackage(
    String packageId,
    String packageName,
    String packageDescription,
    String packageImageUrl,
    String coverImageUrl,
    List<PackagePrice> packagePrices,
  ) async {
    var data = {
      "packageId": packageId,
      "packageName": packageName,
      "packageDescription": packageDescription,
      "packageImageUrl": packageImageUrl,
      "coverImageUrl": coverImageUrl,
      "packagePrices": packagePrices.map((price) => price.toJson()).toList(),
    };
    final response = await DioClient.handelPostWithToken(
      "/story/package/update",
      data,
    );
    return UpdatePackageResponse.fromResponse(response);
  }

  Future<CreatePackageStoryResponse> createPackageStory(
    String packageId,
    String contentUrl,
    String storyName,
    String storyDescription,
    List<String> storyImageUrls,
    int storyMilliSec,
    int previewStartFrom,
    int previewEndAt,
    String voiceMessageStatus,
    String packageNote,
    String channelId,
    String spaceId,
    String? collaboratorId,
    int podcoins,
    int twd,
  ) async {
    var data = {
      "packageId": packageId,
      "contentUrl": contentUrl,
      "storyName": storyName,
      "storyDescription": storyDescription,
      "storyImageUrls": storyImageUrls,
      "storyMilliSec": storyMilliSec,
      "previewStartFrom": previewStartFrom,
      "previewEndAt": previewEndAt,
      "voiceMessageStatus": voiceMessageStatus,
      "collaboratorId": collaboratorId,
      "channelId": channelId,
      "spaceId": spaceId,
      "podcoins": podcoins,
      "twd": twd,
      "packageNote": packageNote,
    };

    final response = await DioClient.handelPostWithToken(
      "/story/package/story",
      data,
    );
    return CreatePackageStoryResponse.fromResponse(response);
  }

  Future<UpdatePackageStoryResponse> updatePackageStory(
    String storyId,
    String packageId,
    String contentUrl,
    String storyName,
    String storyDescription,
    List<String> storyImageUrls,
    int storyMilliSec,
    int previewStartFrom,
    int previewEndAt,
    String packageNote,
    String collaboratorId,
    bool updateStory,
  ) async {
    var data = {
      "storyId": storyId,
      "packageId": packageId,
      "contentUrl": contentUrl,
      "storyName": storyName,
      "storyDescription": storyDescription,
      "storyImageUrls": storyImageUrls,
      "storyMilliSec": storyMilliSec,
      "previewStartFrom": previewStartFrom,
      "previewEndAt": previewEndAt,
      "collaboratorId": collaboratorId,
      "packageNote": packageNote,
      "updateStory": updateStory,
    };

    final response = await DioClient.handelPostWithToken(
      "/story/package/story/update",
      data,
    );
    return UpdatePackageStoryResponse.fromResponse(response);
  }

  Future<GetStoriesByUserIdRes> getStoriesByUserId(
    String userId, {
    bool filterReviewStatus = true,
    bool? isPremium,
  }) async {
    final response = await DioClient.handelGet("/story/user/$userId", {
      'filterReviewStatus': filterReviewStatus,
      if (isPremium != null) 'isPremium': isPremium,
    });
    return GetStoriesByUserIdRes.fromJson(response.data);
  }
}

int _parsePageOrDefault(dynamic value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}
