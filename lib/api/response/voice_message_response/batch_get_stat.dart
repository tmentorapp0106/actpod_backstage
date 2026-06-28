import 'package:dio/dio.dart';

class BatchGetVoiceMessageResponse {
  final String code;
  final String message;
  final List<VoiceMessageStat> stats;

  const BatchGetVoiceMessageResponse({
    required this.code,
    required this.message,
    required this.stats,
  });

  factory BatchGetVoiceMessageResponse.fromResponse(Response response) {
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};
    final data = json['data'];

    return BatchGetVoiceMessageResponse(
      code: json['code'] is String ? json['code'] as String : '',
      message: json['message'] is String ? json['message'] as String : '',
      stats: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(VoiceMessageStat.fromJson)
                .toList()
          : const [],
    );
  }
}

class VoiceMessageStat {
  final String storyId;
  final String userId;
  final String status;
  final int count;
  final bool archive;

  const VoiceMessageStat({
    required this.storyId,
    required this.userId,
    required this.status,
    required this.count,
    required this.archive,
  });

  factory VoiceMessageStat.fromJson(Map<String, dynamic> json) {
    return VoiceMessageStat(
      storyId: json['storyId'] is String ? json['storyId'] as String : '',
      userId: json['userId'] is String ? json['userId'] as String : '',
      status: json['status'] is String ? json['status'] as String : '',
      count: _int(json['count']),
      archive: json['archive'] is bool ? json['archive'] as bool : false,
    );
  }
}

int _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}