import 'package:dio/dio.dart';

class UploadStoryContentResponse {
  final String code;
  final String message;
  final String signedUrl;
  final String publicUrl;

  const UploadStoryContentResponse({
    required this.code,
    required this.message,
    required this.signedUrl,
    required this.publicUrl,
  });

  factory UploadStoryContentResponse.fromResponse(Response response) {
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};
    final data = json['data'];
    final dataJson = data is Map<String, dynamic> ? data : <String, dynamic>{};

    return UploadStoryContentResponse(
      code: json['code'] is String ? json['code'] as String : '',
      message: json['message'] is String ? json['message'] as String : '',
      signedUrl: dataJson['signedUrl'] is String
          ? dataJson['signedUrl'] as String
          : '',
      publicUrl: dataJson['publicUrl'] is String
          ? dataJson['publicUrl'] as String
          : '',
    );
  }
}
