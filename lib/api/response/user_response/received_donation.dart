import 'package:dio/dio.dart';

class ReceivedDonationResponse {
  final String code;
  final String message;
  final ReceivedDonation? donation;

  const ReceivedDonationResponse({
    required this.code,
    required this.message,
    required this.donation,
  });

  factory ReceivedDonationResponse.fromResponse(Response response) {
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};
    final data = json['data'];

    return ReceivedDonationResponse(
      code: _string(json['code']),
      message: _string(json['message']),
      donation: data is Map<String, dynamic>
          ? ReceivedDonation.fromJson(data)
          : null,
    );
  }
}

class ReceivedDonation {
  final String transactionId;
  final String fromUserId;
  final String fromUserNickname;
  final String fromUserAvatarUrl;
  final int receivedPodCash;
  final String type;
  final DateTime? createTime;

  const ReceivedDonation({
    required this.transactionId,
    required this.fromUserId,
    required this.fromUserNickname,
    required this.fromUserAvatarUrl,
    required this.receivedPodCash,
    required this.type,
    required this.createTime,
  });

  factory ReceivedDonation.fromJson(Map<String, dynamic> json) {
    return ReceivedDonation(
      transactionId: _string(json['transactionId']),
      fromUserId: _string(json['fromUserId']),
      fromUserNickname: _string(json['fromUserNickname']),
      fromUserAvatarUrl: _string(json['fromUserAvatarUrl']),
      receivedPodCash: _int(json['receivedPodCash']),
      type: _string(json['type']),
      createTime: _dateTime(json['createTime']),
    );
  }
}

String _string(dynamic value) {
  if (value is String) return value;
  return '';
}

int _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

DateTime? _dateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
