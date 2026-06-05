import 'package:actpod_studio/api/api.dart';
import 'package:actpod_studio/api/response/story_response/create_package.dart';
import 'package:actpod_studio/api/response/story_response/create_package_story.dart';
import 'package:actpod_studio/api/response/story_response/get_package_info.dart';
import 'package:actpod_studio/api/response/story_response/get_user_packages.dart';
import 'package:actpod_studio/api/response/story_response/package_models.dart';
import 'package:actpod_studio/api/response/story_response/update_package.dart';
import 'package:actpod_studio/api/response/story_response/update_package_story.dart';
import 'package:actpod_studio/api/response/story_response/upload_story.dart';

class StoryApi {
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
    int price,
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
      "price": price,
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
    String spaceId,
    String channelId,
    List<PackagePrice> packagePrices,
  ) async {
    var data = {
      "userId": userId,
      "packageName": packageName,
      "packageDescription": packageDescription,
      "packageImageUrl": packageImageUrl,
      "spaceId": spaceId,
      "channelId": channelId,
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
    List<PackagePrice> packagePrices,
  ) async {
    var data = {
      "packageId": packageId,
      "packageName": packageName,
      "packageDescription": packageDescription,
      "packageImageUrl": packageImageUrl,
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
    String? collaboratorId,
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
}
