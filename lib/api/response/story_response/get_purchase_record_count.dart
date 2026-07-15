import 'package:dio/dio.dart';

class PurchaseRecordCountInfo {
  final String storyId;
  final String packageId;
  final int count;

  const PurchaseRecordCountInfo({
    required this.storyId,
    required this.packageId,
    required this.count,
  });

  factory PurchaseRecordCountInfo.fromJson(Map<String, dynamic> json) {
    return PurchaseRecordCountInfo(
      storyId: _string(json['storyId']),
      packageId: _string(json['packageId']),
      count: _int(json['count']),
    );
  }
}

class GetPurchaseRecordCountResponse {
  final String code;
  final String message;
  final List<PurchaseRecordCountInfo> data;

  const GetPurchaseRecordCountResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory GetPurchaseRecordCountResponse.fromResponse(Response response) {
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};
    final data = json['data'];

    return GetPurchaseRecordCountResponse(
      code: _string(json['code']),
      message: _string(json['message']),
      data: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(PurchaseRecordCountInfo.fromJson)
                .toList()
          : const [],
    );
  }
}

String _string(dynamic value) => value is String ? value : '';

int _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
