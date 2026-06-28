import 'package:dio/dio.dart';

class BatchGetStoryStatResponse {
  final String code;
  final String message;
  final List<CommentStoryStat> data;

  const BatchGetStoryStatResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory BatchGetStoryStatResponse.fromResponse(Response response) {
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};
    final data = json['data'];

    return BatchGetStoryStatResponse(
      code: json['code'] is String ? json['code'] as String : '',
      message: json['message'] is String ? json['message'] as String : '',
      data: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(CommentStoryStat.fromJson)
                .toList()
          : const [],
    );
  }
}

class CommentStoryStat {
  final String storyId;
  final String userId;
  final int commentCount;
  final int instantCommentCount;
  final int likeCount;

  const CommentStoryStat({
    required this.storyId,
    required this.userId,
    required this.commentCount,
    required this.instantCommentCount,
    required this.likeCount,
  });

  factory CommentStoryStat.fromJson(Map<String, dynamic> json) {
    return CommentStoryStat(
      storyId: json['storyId'] is String ? json['storyId'] as String : '',
      userId: json['userId'] is String ? json['userId'] as String : '',
      commentCount: _int(json['commentCount']),
      instantCommentCount: _int(json['instantCommentCount']),
      likeCount: _int(json['likeCount']),
    );
  }
}

int _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}