import 'package:dio/dio.dart';

class BatchGetListenCountResponse {
  final String code;
  final String message;
  final List<StoryListenCount> listenCounts;

  const BatchGetListenCountResponse({
    required this.code,
    required this.message,
    required this.listenCounts,
  });

  factory BatchGetListenCountResponse.fromResponse(Response response) {
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};
    final data = json['data'];

    return BatchGetListenCountResponse(
      code: json['code'] is String ? json['code'] as String : '',
      message: json['message'] is String ? json['message'] as String : '',
      listenCounts: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(StoryListenCount.fromJson)
                .toList()
          : const [],
    );
  }
}

class StoryListenCount {
  final String storyId;
  final int count;

  const StoryListenCount({required this.storyId, required this.count});

  factory StoryListenCount.fromJson(Map<String, dynamic> json) {
    return StoryListenCount(
      storyId: json['storyId'] is String ? json['storyId'] as String : '',
      count: _int(json['count']),
    );
  }
}

int _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
