import 'package:dio/dio.dart';

class UploadStoryImageResponse {
  final String code;
  final String message;
  final String signedUrl;
  final String publicUrl;

  const UploadStoryImageResponse({
    required this.code,
    required this.message,
    required this.signedUrl,
    required this.publicUrl,
  });

  factory UploadStoryImageResponse.fromResponse(Response response) {
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};
    final data = json['data'];
    final dataJson = data is Map<String, dynamic> ? data : <String, dynamic>{};

    return UploadStoryImageResponse(
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
