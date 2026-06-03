import 'package:actpod_studio/features/create_story/models/channel_model.dart';
import 'package:dio/dio.dart';

class GetUserChannelsResponse {
  final String code;
  final String message;
  final List<Channel> channels;

  const GetUserChannelsResponse({
    required this.code,
    required this.message,
    required this.channels,
  });

  factory GetUserChannelsResponse.fromResponse(Response response) {
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};
    final data = json['data'];

    return GetUserChannelsResponse(
      code: json['code'] is String ? json['code'] as String : '',
      message: json['message'] is String ? json['message'] as String : '',
      channels: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(Channel.fromJson)
                .toList()
          : const [],
    );
  }
}
