import 'package:actpod_studio/api/api.dart';
import 'package:actpod_studio/api/response/story_response/create_package.dart';
import 'package:actpod_studio/api/response/story_response/create_package_story.dart';
import 'package:actpod_studio/api/response/story_response/upload_story.dart';

class StoryApi {
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
    String packageName,
    String packageDescription,
    String packageImageUrl,
    String spaceId,
    String channelId,
    int packagePrice,
    int soloPrice,
  ) async {
    var data = {
      "packageName": packageName,
      "packageDescription": packageDescription,
      "packageImageUrl": packageImageUrl,
      "spaceId": spaceId,
      "channelId": channelId,
      "packagePrice": packagePrice,
      "soloPrice": soloPrice,
    };

    final response = await DioClient.handelPostWithToken(
      "/story/package",
      data,
    );
    return CreatePackageResponse.fromResponse(response);
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
    String? collaboratorId,
    DateTime? releaseTime,
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
      "releaseTime": releaseTime?.toUtc().toIso8601String(),
    };

    final response = await DioClient.handelPostWithToken(
      "/story/package/story",
      data,
    );
    return CreatePackageStoryResponse.fromResponse(response);
  }
}
