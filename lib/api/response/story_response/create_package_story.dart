import 'package:dio/dio.dart';

class CreatePackageStoryResponse {
  final String code;
  final String message;
  final String storyId;

  const CreatePackageStoryResponse({
    required this.code,
    required this.message,
    required this.storyId,
  });

  factory CreatePackageStoryResponse.fromResponse(Response response) {
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};

    return CreatePackageStoryResponse(
      code: json['code'] is String ? json['code'] as String : '',
      message: json['message'] is String ? json['message'] as String : '',
      storyId: json['data'] is String ? json['data'] as String : '',
    );
  }
}
