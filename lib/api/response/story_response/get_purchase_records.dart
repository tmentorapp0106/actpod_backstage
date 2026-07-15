import 'package:actpod_studio/api/response/story_response/package_models.dart';
import 'package:dio/dio.dart';

class GetPurchaseRecordsResponse {
  final String code;
  final String message;
  final PurchaseRecordPage? data;

  const GetPurchaseRecordsResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory GetPurchaseRecordsResponse.fromResponse(Response response) {
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};
    final data = json['data'];

    return GetPurchaseRecordsResponse(
      code: json['code'] is String ? json['code'] as String : '',
      message: json['message'] is String ? json['message'] as String : '',
      data: data is Map<String, dynamic>
          ? PurchaseRecordPage.fromJson(data)
          : null,
    );
  }
}
