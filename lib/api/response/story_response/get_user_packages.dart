import 'package:actpod_studio/api/response/story_response/package_models.dart';
import 'package:dio/dio.dart';

class GetUserPackagesResponse {
  final String code;
  final String message;
  final List<PremiumPackage> packages;

  const GetUserPackagesResponse({
    required this.code,
    required this.message,
    required this.packages,
  });

  factory GetUserPackagesResponse.fromResponse(Response response) {
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};
    final data = json['data'];

    return GetUserPackagesResponse(
      code: json['code'] is String ? json['code'] as String : '',
      message: json['message'] is String ? json['message'] as String : '',
      packages: data is List
        ? data
          .whereType<Map<String, dynamic>>()
          .map(PremiumPackage.fromJson)
          .toList()
        : const [],
    );
  }
}
