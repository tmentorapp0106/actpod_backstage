import 'package:actpod_studio/features/create_story/models/user_model.dart';
import 'package:dio/dio.dart';

class GetUserInfoResponse {
  final String code;
  final String message;
  final UserInfo userInfo;

  const GetUserInfoResponse({
    required this.code,
    required this.message,
    required this.userInfo,
  });

  factory GetUserInfoResponse.fromResponse(Response response) {
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};

    return GetUserInfoResponse(
      code: json['code'] is String ? json['code'] as String : '',
      message: json['message'] is String ? json['message'] as String : '',
      userInfo: UserInfo.fromJson(json),
    );
  }
}
