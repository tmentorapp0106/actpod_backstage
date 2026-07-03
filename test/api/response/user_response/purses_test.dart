import 'package:actpod_studio/api/response/user_response/purses.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PursesResponse', () {
    test('parses coins and cash purses', () {
      final response = PursesResponse.fromResponse(
        _response({
          'code': '0000',
          'message': 'OK',
          'data': {
            'coinsPurse': {
              'userId': 'user-1',
              'podCoins': 100,
              'updateTime': '2026-07-02T12:30:00Z',
            },
            'cashPurse': {
              'userId': 'user-1',
              'podCash': '200',
              'updateTime': '2026-07-02T12:35:00Z',
            },
          },
        }),
      );

      expect(response.code, '0000');
      expect(response.message, 'OK');
      expect(response.coinsPurse?.userId, 'user-1');
      expect(response.coinsPurse?.podCoins, 100);
      expect(response.coinsPurse?.updateTime?.toUtc().year, 2026);
      expect(response.cashPurse?.userId, 'user-1');
      expect(response.cashPurse?.podCash, 200);
      expect(response.cashPurse?.updateTime?.toUtc().year, 2026);
    });

    test('falls back safely for missing or invalid data', () {
      final response = PursesResponse.fromResponse(
        _response({'code': 200, 'message': null, 'data': null}),
      );

      expect(response.code, '');
      expect(response.message, '');
      expect(response.coinsPurse, isNull);
      expect(response.cashPurse, isNull);
    });
  });
}

Response _response(Map<String, dynamic> data) {
  return Response(
    data: data,
    requestOptions: RequestOptions(path: '/'),
  );
}
