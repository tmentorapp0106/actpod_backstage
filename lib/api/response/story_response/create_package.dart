import 'package:dio/dio.dart';

class CreatePackageResponse {
  final String code;
  final String message;
  final String packageId;

  const CreatePackageResponse({
    required this.code,
    required this.message,
    required this.packageId,
  });

  factory CreatePackageResponse.fromResponse(Response response) {
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};

    return CreatePackageResponse(
      code: json['code'] is String ? json['code'] as String : '',
      message: json['message'] is String ? json['message'] as String : '',
      packageId: json['data'] is String ? json['data'] as String : '',
    );
  }
}
