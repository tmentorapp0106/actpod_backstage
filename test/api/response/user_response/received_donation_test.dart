import 'package:actpod_studio/api/response/user_response/received_donation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReceivedDonationResponse', () {
    test('parses received donation data', () {
      final response = ReceivedDonationResponse.fromResponse(
        _response({
          'code': '0000',
          'message': 'OK',
          'data': {
            'transactionId': 'transaction-1',
            'fromUserId': 'user-1',
            'fromUserNickname': 'Supporter',
            'fromUserAvatarUrl': 'https://example.com/avatar.jpg',
            'receivedPodCash': 100,
            'type': 'SuperCommentDonation',
            'createTime': '2026-07-02T12:30:00Z',
          },
        }),
      );

      expect(response.code, '0000');
      expect(response.message, 'OK');
      expect(response.donations, hasLength(1));
      expect(response.donation?.transactionId, 'transaction-1');
      expect(response.donation?.fromUserId, 'user-1');
      expect(response.donation?.fromUserNickname, 'Supporter');
      expect(
        response.donation?.fromUserAvatarUrl,
        'https://example.com/avatar.jpg',
      );
      expect(response.donation?.receivedPodCash, 100);
      expect(response.donation?.type, 'SuperCommentDonation');
      expect(response.donation?.createTime?.toUtc().year, 2026);
    });

    test('falls back safely for missing or invalid data', () {
      final response = ReceivedDonationResponse.fromResponse(
        _response({'code': 200, 'message': null, 'data': null}),
      );

      expect(response.code, '');
      expect(response.message, '');
      expect(response.donation, isNull);
      expect(response.donations, isEmpty);
    });

    test('parses donation data as an array', () {
      final response = ReceivedDonationResponse.fromResponse(
        _response({
          'code': '0000',
          'message': 'OK',
          'data': [
            {
              'transactionId': 'transaction-1',
              'receivedPodCash': '100',
              'createTime': '2026-07-02T12:30:00Z',
            },
            {
              'transactionId': 'transaction-2',
              'receivedPodCash': 50,
              'createTime': '2026-07-01T12:30:00Z',
            },
          ],
        }),
      );

      expect(response.donations, hasLength(2));
      expect(response.donations.first.transactionId, 'transaction-1');
      expect(response.donations.first.receivedPodCash, 100);
    });
  });
}

Response _response(Map<String, dynamic> data) {
  return Response(
    data: data,
    requestOptions: RequestOptions(path: '/'),
  );
}
