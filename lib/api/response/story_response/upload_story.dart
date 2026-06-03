import 'package:dio/dio.dart';

class UploadStoryResponse {
  final String code;
  final String message;
  final Object? data;

  const UploadStoryResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory UploadStoryResponse.fromResponse(Response response) {
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};

    return UploadStoryResponse(
      code: json['code'] is String ? json['code'] as String : '',
      message: json['message'] is String ? json['message'] as String : '',
      data: json['data'],
    );
  }
}
