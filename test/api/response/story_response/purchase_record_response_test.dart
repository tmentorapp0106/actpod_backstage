import 'package:actpod_studio/api/response/story_response/get_purchase_record_count.dart';
import 'package:actpod_studio/api/response/story_response/get_purchase_records.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GetPurchaseRecordCountResponse', () {
    test('parses count from data', () {
      final response = GetPurchaseRecordCountResponse.fromResponse(
        _response({'code': '0000', 'message': 'OK', 'data': 12}),
      );

      expect(response.code, '0000');
      expect(response.message, 'OK');
      expect(response.count, 12);
    });

    test('falls back safely for invalid data', () {
      final response = GetPurchaseRecordCountResponse.fromResponse(
        _response({'code': 0, 'message': null, 'data': 'not-a-number'}),
      );

      expect(response.code, '');
      expect(response.message, '');
      expect(response.count, 0);
    });
  });

  group('GetPurchaseRecordsResponse', () {
    test('parses paged purchase records', () {
      final response = GetPurchaseRecordsResponse.fromResponse(
        _response({
          'code': '0000',
          'message': 'OK',
          'data': {
            'total': 34,
            'page': 1,
            'pageSize': 20,
            'records': [
              {
                'userId': 'user_001',
                'packageId': '',
                'storyId': 'story_123',
                'priceId': 'price_001',
                'archive': false,
                'updateTime': '2026-07-15T10:20:30Z',
                'createTime': '2026-07-15T10:20:30Z',
                'userInfo': {
                  'userId': 'user_001',
                  'nickname': '王小明',
                  'avatarUrl': 'https://example.com/avatar.jpg',
                },
              },
            ],
          },
        }),
      );

      expect(response.code, '0000');
      expect(response.message, 'OK');
      expect(response.data?.total, 34);
      expect(response.data?.page, 1);
      expect(response.data?.pageSize, 20);
      expect(response.data?.records, hasLength(1));
      expect(response.data?.records.single.storyId, 'story_123');
      expect(response.data?.records.single.userInfo?.nickname, '王小明');
      expect(response.data?.records.single.createTime?.toUtc().year, 2026);
    });

    test('falls back safely when data is missing', () {
      final response = GetPurchaseRecordsResponse.fromResponse(
        _response({'code': '0008', 'message': 'request invalid', 'data': null}),
      );

      expect(response.code, '0008');
      expect(response.message, 'request invalid');
      expect(response.data, isNull);
    });
  });
}

Response _response(Map<String, dynamic> data) {
  return Response(
    data: data,
    requestOptions: RequestOptions(path: '/'),
  );
}
