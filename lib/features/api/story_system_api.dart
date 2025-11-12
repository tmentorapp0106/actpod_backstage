import 'package:actpod_studio/features/api/api.dart';
import 'package:dio/dio.dart';

class StoryApi {
  Future<String> uploadStory(
    String spaceId,
    String channelId,
    String contentUrl,
    String storyName,
    String storyDescription,
    List<String> storyImageUrls,
    int storyMilliSec,
    int previewStartFrom,
    int previewEndAt,
    List<BlockInfoDto> blockInfoList,
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
      "blockInfoList": blockInfoList,
      "voiceMessageStatus": voiceMessageStatus,
      "isPremium": isPremium,
      "price": 0,
      "collaboratorId":null,
      "releaseTime": releaseTime?.toUtc().toIso8601String(),
    };

    Response response = await DioClient.handelPostWithToken("/story/", data);
    return response.data.toString();
  }
}


class BlockInfoDto {
  Duration from;
  Duration to;
  Duration position;
  int soundIndex;
  Duration length;
  double volume;
  String url;
  String name;
  List<double> waveformData;
  Duration skip; // for cut
  String type; // sound, story
  String soundType; // soundEffect, music

  BlockInfoDto(
  {required this.from,
    required this.to,
    required this.position,
    required this.soundIndex,
    required this.length,
    required this.volume,
    required this.url,
    required this.name,
    required this.waveformData,
    required this.skip,
    required this.type,
    required this.soundType,
  });

  factory BlockInfoDto.fromJson(Map<String, dynamic> json) {
    return BlockInfoDto(
      from: Duration(milliseconds: json['fromMilliSec']),
      to: Duration(milliseconds: json['toMilliSec']),
      position: Duration(milliseconds: json['positionMilliSec']),
      soundIndex: json['soundIndex'],
      length: Duration(milliseconds: json['lengthMilliSec']),
      volume: (json['volume'] as num).toDouble(), // Ensures it's a double
      url: json['url'],
      name: json['name'],
      waveformData: (json['waveformData'] as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
      skip: Duration(milliseconds: json['skipMilliSec']),
      type: json['type'],
      soundType: json['soundType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromMilliSec': from.inMilliseconds,
      'toMilliSec': to.inMilliseconds,
      'positionMilliSec': position.inMilliseconds,
      'soundIndex': soundIndex,
      'lengthMilliSec': length.inMilliseconds,
      'name': name,
      'waveformData': waveformData,
      'skipMilliSec': skip.inMilliseconds,
      'volume': volume,
      'url': url,
      'type': type,
      'soundType': soundType
    };
  }

  // Clone method
  BlockInfoDto clone() {
    return BlockInfoDto(
      from: Duration(milliseconds: from.inMilliseconds),
      to: Duration(milliseconds: to.inMilliseconds),
      position: Duration(milliseconds: position.inMilliseconds),
      soundIndex: soundIndex,
      length: Duration(milliseconds: length.inMilliseconds),
      volume: volume,
      url: url,
      name: name,
      waveformData: List<double>.from(waveformData), // Deep copy of the list
      skip: Duration(milliseconds: skip.inMilliseconds),
      type: type,
      soundType: soundType,
    );
  }
}