import 'package:actpod_studio/api/response/user_response/withdraws.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WithdrawActionResponse', () {
    test('parses code and message', () {
      final response = WithdrawActionResponse.fromResponse(
        _response({'code': '0000', 'message': 'OK'}),
      );

      expect(response.code, '0000');
      expect(response.message, 'OK');
    });
  });

  group('GetWithdrawsResponse', () {
    test('parses withdraw list', () {
      final response = GetWithdrawsResponse.fromResponse(
        _response({
          'code': '0000',
          'message': 'OK',
          'data': [
            {
              'withdrawId': 'withdraw-1',
              'status': 'pending',
              'userId': 'user-1',
              'podCash': '100',
              'email': 'creator@example.com',
              'phone': '0912345678',
              'transferTime': '2026-07-02T12:30:00Z',
              'createTime': '2026-07-02T12:00:00Z',
              'updateTime': 'bad date',
            },
          ],
        }),
      );

      expect(response.code, '0000');
      expect(response.message, 'OK');
      expect(response.withdraws, hasLength(1));
      expect(response.withdraws.single.withdrawId, 'withdraw-1');
      expect(response.withdraws.single.status, 'pending');
      expect(response.withdraws.single.userId, 'user-1');
      expect(response.withdraws.single.podCash, 100);
      expect(response.withdraws.single.email, 'creator@example.com');
      expect(response.withdraws.single.phone, '0912345678');
      expect(response.withdraws.single.transferTime?.toUtc().year, 2026);
      expect(response.withdraws.single.createTime?.toUtc().year, 2026);
      expect(response.withdraws.single.updateTime, isNull);
    });

    test('falls back safely for missing or invalid data', () {
      final response = GetWithdrawsResponse.fromResponse(
        _response({'code': 200, 'message': null, 'data': {}}),
      );

      expect(response.code, '');
      expect(response.message, '');
      expect(response.withdraws, isEmpty);
    });
  });
}

Response _response(Map<String, dynamic> data) {
  return Response(
    data: data,
    requestOptions: RequestOptions(path: '/'),
  );
}
