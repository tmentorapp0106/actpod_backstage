import 'package:actpod_studio/api/response/story_response/package_models.dart';
import 'package:dio/dio.dart';

class GetPackageInfoResponse {
  final String code;
  final String message;
  final PackageInfo? packageInfo;

  const GetPackageInfoResponse({
    required this.code,
    required this.message,
    required this.packageInfo,
  });

  factory GetPackageInfoResponse.fromResponse(Response response) {
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};
    final data = json['data'];

    return GetPackageInfoResponse(
      code: json['code'] is String ? json['code'] as String : '',
      message: json['message'] is String ? json['message'] as String : '',
      packageInfo: data is Map<String, dynamic>
          ? PackageInfo.fromJson(data)
          : null,
    );
  }
}
