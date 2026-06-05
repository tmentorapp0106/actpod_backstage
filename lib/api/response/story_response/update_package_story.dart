import 'package:dio/dio.dart';

class UpdatePackageStoryResponse {
  final String code;
  final String message;

  const UpdatePackageStoryResponse({
    required this.code,
    required this.message,
  });

  factory UpdatePackageStoryResponse.fromResponse(Response response) {
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};

    return UpdatePackageStoryResponse(
      code: json['code'] is String ? json['code'] as String : '',
      message: json['message'] is String ? json['message'] as String : '',
    );
  }
}