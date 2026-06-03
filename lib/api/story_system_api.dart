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
      "price": 0,
      "collaboratorId": null,
      "releaseTime": releaseTime?.toUtc().toIso8601String(),
    };

    final response = await DioClient.handelPostWithToken("/story/", data);
    return UploadStoryResponse.fromResponse(response);
  }

  Future<CreatePackageResponse> createPackage(
    String packageName,
    String packageDescription,
    int packagePrice,
    int soloPrice,
  ) async {
    var data = {
      "packageName": packageName,
      "packageDescription": packageDescription,
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
      "collaboratorId": null,
      "releaseTime": releaseTime?.toUtc().toIso8601String(),
    };

    final response = await DioClient.handelPostWithToken(
      "/story/package/story",
      data,
    );
    return CreatePackageStoryResponse.fromResponse(response);
  }
}
