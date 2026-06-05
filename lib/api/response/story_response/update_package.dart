import 'package:dio/dio.dart';

class UpdatePackageResponse {
  final String code;
  final String message;

  const UpdatePackageResponse({
    required this.code,
    required this.message,
  });

  factory UpdatePackageResponse.fromResponse(Response response) {
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};

    return UpdatePackageResponse(
      code: json['code'] is String ? json['code'] as String : '',
      message: json['message'] is String ? json['message'] as String : '',
    );
  }
}