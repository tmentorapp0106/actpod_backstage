import 'package:actpod_studio/api/response/story_response/get_package_info.dart';
import 'package:actpod_studio/api/response/story_response/get_user_packages.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GetPackageInfoResponse', () {
    test('parses package info with prices and stories', () {
      final response = GetPackageInfoResponse.fromResponse(
        _response({
          'code': '200',
          'message': 'ok',
          'data': {
            'packageId': 'package-1',
            'userId': 'user-1',
            'packageName': 'A Package',
            'packageDescription': 'A package description',
            'packageImageUrl': 'https://example.com/package.jpg',
            'channelId': 'channel-1',
            'spaceId': 'space-1',
            'packageType': 'package',
            'packagePrices': [
              {
                'packagePriceId': 'price-1',
                'priceType': 'package',
                'lable': 'Full set',
                'podcoins': 120,
                'twd': 90,
                'isActive': true,
              },
            ],
            'createTime': '2026-06-05T10:00:00Z',
            'updateTime': 'bad date',
            'nickname': 'Creator',
            'avatarUrl': 'https://example.com/avatar.jpg',
            'channelName': 'Main Channel',
            'channelImageUrl': 'https://example.com/channel.jpg',
            'spaceName': 'Main Space',
            'stories': [
              {
                'storyId': 'story-1',
                'userId': 'user-1',
                'collaborator': 'collab-1',
                'spaceId': 'space-1',
                'channelId': 'channel-1',
                'storyUrl': 'https://example.com/story.mp3',
                'previewStartFrom': 1000,
                'previewEndAt': 2000,
                'previewUrl': 'https://example.com/preview.mp3',
                'storyName': 'Story One',
                'storyDescription': 'Story description',
                'storyImageUrls': ['https://example.com/story.jpg'],
                'storyLength': 3000,
                'storyUploadTime': '2026-06-05T11:00:00Z',
                'count': 7,
                'isPremium': true,
                'packageId': 'package-1',
                'packageNote': 'Read first',
                'storyStatus': 'published',
                'review': {'note': 'approved'},
                'locked': false,
                'archive': false,
                'updateTime': '2026-06-05T12:00:00Z',
                'releaseTime': '2026-06-05T13:00:00Z',
                'nickname': 'Creator',
                'avatarUrl': 'https://example.com/avatar.jpg',
                'collaboratorName': 'Collaborator',
                'collaboratorAvatarUrl': 'https://example.com/collab.jpg',
                'channelName': 'Main Channel',
                'channelImageUrl': 'https://example.com/channel.jpg',
                'spaceName': 'Main Space',
              },
            ],
          },
        }),
      );

      expect(response.code, '200');
      expect(response.message, 'ok');
      expect(response.packageInfo?.packageId, 'package-1');
      expect(response.packageInfo?.packagePrices.single.priceType, 'package');
      expect(response.packageInfo?.packagePrices.single.lable, 'Full set');
      expect(response.packageInfo?.createTime?.toUtc().year, 2026);
      expect(response.packageInfo?.updateTime, isNull);
      expect(response.packageInfo?.stories.single.storyName, 'Story One');
      expect(response.packageInfo?.stories.single.storyStatus, 'published');
      expect(
        response.packageInfo?.stories.single.review.data['note'],
        'approved',
      );
    });

    test('falls back safely for invalid body and missing data', () {
      final response = GetPackageInfoResponse.fromResponse(
        _response({'code': 200, 'message': null, 'data': null}),
      );

      expect(response.code, '');
      expect(response.message, '');
      expect(response.packageInfo, isNull);
    });
  });

  group('GetUserPackagesResponse', () {
    test('parses data as package array', () {
      final response = GetUserPackagesResponse.fromResponse(
        _response({
          'code': '200',
          'message': 'ok',
          'data': [
            {
              'packageId': 'package-1',
              'userId': 'user-1',
              'packageName': 'A Package',
              'packageDescription': 'A package description',
              'packageImageUrl': 'https://example.com/package.jpg',
              'channelId': 'channel-1',
              'spaceId': 'space-1',
              'packageType': 'package',
              'packagePrices': [
                {
                  'packagePriceId': 'price-1',
                  'priceType': 'single',
                  'lable': 'Episode',
                  'podcoins': 30,
                  'twd': 20,
                  'isActive': false,
                },
              ],
              'createTime': '2026-06-05T10:00:00Z',
              'updateTime': 'not a date',
            },
          ],
        }),
      );

      expect(response.code, '200');
      expect(response.packages, hasLength(1));
      expect(response.packages.single.packageId, 'package-1');
      expect(response.packages.single.updateTime, isNull);
    });

    test('falls back to empty packages when data is not an array', () {
      final response = GetUserPackagesResponse.fromResponse(
        _response({'code': '200', 'message': 'ok', 'data': {}}),
      );

      expect(response.packages, isEmpty);
    });
  });
}

Response _response(Map<String, dynamic> data) {
  return Response(
    data: data,
    requestOptions: RequestOptions(path: '/'),
  );
}
