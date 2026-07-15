import 'package:dio/dio.dart';

class GetPurchaseRecordCountResponse {
  final String code;
  final String message;
  final int count;

  const GetPurchaseRecordCountResponse({
    required this.code,
    required this.message,
    required this.count,
  });

  factory GetPurchaseRecordCountResponse.fromResponse(Response response) {
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};

    return GetPurchaseRecordCountResponse(
      code: json['code'] is String ? json['code'] as String : '',
      message: json['message'] is String ? json['message'] as String : '',
      count: _int(json['data']),
    );
  }
}

int _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
