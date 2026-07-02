import 'package:dio/dio.dart';

class CommentActionResponse {
  final String code;
  final String message;

  const CommentActionResponse({required this.code, required this.message});

  factory CommentActionResponse.fromResponse(Response response) {
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};

    return CommentActionResponse(
      code: json['code'] is String ? json['code'] as String : '',
      message: json['message'] is String ? json['message'] as String : '',
    );
  }
}

class CreateCommentResponse {
  final String code;
  final String message;
  final String commentId;

  const CreateCommentResponse({
    required this.code,
    required this.message,
    required this.commentId,
  });

  factory CreateCommentResponse.fromResponse(Response response) {
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};

    return CreateCommentResponse(
      code: json['code'] is String ? json['code'] as String : '',
      message: json['message'] is String ? json['message'] as String : '',
      commentId: json['data'] is String ? json['data'] as String : '',
    );
  }
}
