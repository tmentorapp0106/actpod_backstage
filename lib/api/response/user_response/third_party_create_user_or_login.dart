import 'package:dio/dio.dart';

class ThirdPartyCreateUserOrLoginResponse {
  final String code;
  final String message;
  final String userToken;

  const ThirdPartyCreateUserOrLoginResponse({
    required this.code,
    required this.message,
    required this.userToken,
  });

  factory ThirdPartyCreateUserOrLoginResponse.fromResponse(Response response) {
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};
    final data = json['data'];
    final dataJson = data is Map<String, dynamic> ? data : <String, dynamic>{};

    return ThirdPartyCreateUserOrLoginResponse(
      code: json['code'] is String ? json['code'] as String : '',
      message: json['message'] is String ? json['message'] as String : '',
      userToken: dataJson['userToken'] is String
          ? dataJson['userToken'] as String
          : '',
    );
  }
}
