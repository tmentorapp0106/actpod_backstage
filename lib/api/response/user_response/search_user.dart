import 'package:actpod_studio/features/create_story/models/user_model.dart';
import 'package:dio/dio.dart';

class SearchUserResponse {
  final String code;
  final String message;
  final List<UserInfo> users;

  const SearchUserResponse({
    required this.code,
    required this.message,
    required this.users,
  });

  factory SearchUserResponse.fromResponse(Response response) {
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};
    final data = json['data'];

    return SearchUserResponse(
      code: json['code'] is String ? json['code'] as String : '',
      message: json['message'] is String ? json['message'] as String : '',
      users: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(UserInfo.fromJson)
                .toList()
          : const [],
    );
  }
}
