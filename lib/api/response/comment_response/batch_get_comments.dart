import 'package:dio/dio.dart';

class BatchGetCommentsResponse {
  final String code;
  final String message;
  final List<StoryComments> data;

  const BatchGetCommentsResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory BatchGetCommentsResponse.fromResponse(Response response) {
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};
    final data = json['data'];

    return BatchGetCommentsResponse(
      code: _string(json['code']),
      message: _string(json['message']),
      data: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(StoryComments.fromJson)
                .toList()
          : const [],
    );
  }
}

class StoryComments {
  final String story;
  final List<CommentThread> comments;

  const StoryComments({required this.story, required this.comments});

  factory StoryComments.fromJson(Map<String, dynamic> json) {
    final comments = json['comments'];

    return StoryComments(
      story: _string(json['story']),
      comments: comments is List
          ? comments
                .whereType<Map<String, dynamic>>()
                .map(CommentThread.fromJson)
                .toList()
          : const [],
    );
  }
}

class CommentThread {
  final StoryComment comment;
  final CommentUser user;
  final List<CommentReplyThread> replies;

  const CommentThread({
    required this.comment,
    required this.user,
    required this.replies,
  });

  factory CommentThread.fromJson(Map<String, dynamic> json) {
    final replies = json['replies'];

    return CommentThread(
      comment: StoryComment.fromJson(_map(json['comment'])),
      user: CommentUser.fromJson(_map(json['user'])),
      replies: replies is List
          ? replies
                .whereType<Map<String, dynamic>>()
                .map(CommentReplyThread.fromJson)
                .toList()
          : const [],
    );
  }
}

class StoryComment {
  final String storyId;
  final String commentId;
  final int replyCount;
  final String userId;
  final String content;
  final bool archive;
  final DateTime commentTime;
  final DateTime createTime;
  final DateTime updateTime;
  final String commentType;
  final String stickerUrl;
  final int podcoins;

  const StoryComment({
    required this.storyId,
    required this.commentId,
    required this.replyCount,
    required this.userId,
    required this.content,
    required this.archive,
    required this.commentTime,
    required this.createTime,
    required this.updateTime,
    required this.commentType,
    required this.stickerUrl,
    required this.podcoins,
  });

  factory StoryComment.fromJson(Map<String, dynamic> json) {
    return StoryComment(
      storyId: _string(json['storyId']),
      commentId: _string(json['commentId']),
      replyCount: _int(json['replyCount']),
      userId: _string(json['userId']),
      content: _string(json['content']),
      archive: _bool(json['archive']),
      commentTime: _dateTime(json['commentTime']),
      createTime: _dateTime(json['createTime']),
      updateTime: _dateTime(json['updateTime']),
      commentType: _string(json['commentType']),
      stickerUrl: _string(json['stickerUrl']),
      podcoins: _int(json['podcoins']),
    );
  }
}

class CommentUser {
  final String userId;
  final String avatarUrl;
  final String username;
  final String nickname;
  final String gender;
  final String email;
  final String selfDescription;

  const CommentUser({
    required this.userId,
    required this.avatarUrl,
    required this.username,
    required this.nickname,
    required this.gender,
    required this.email,
    required this.selfDescription,
  });

  factory CommentUser.fromJson(Map<String, dynamic> json) {
    return CommentUser(
      userId: _string(json['userId']),
      avatarUrl: _string(json['avatarUrl']),
      username: _string(json['username']),
      nickname: _string(json['nickname']),
      gender: _string(json['gender']),
      email: _string(json['email']),
      selfDescription: _string(json['selfDescription']),
    );
  }
}

class CommentReplyThread {
  final CommentUser user;
  final CommentReply reply;

  const CommentReplyThread({required this.user, required this.reply});

  factory CommentReplyThread.fromJson(Map<String, dynamic> json) {
    return CommentReplyThread(
      user: CommentUser.fromJson(_map(json['user'])),
      reply: CommentReply.fromJson(_map(json['reply'])),
    );
  }
}

class CommentReply {
  final String replyId;
  final String commentId;
  final String userId;
  final String replyType;
  final String content;
  final bool archive;
  final DateTime replyTime;

  const CommentReply({
    required this.replyId,
    required this.commentId,
    required this.userId,
    required this.replyType,
    required this.content,
    required this.archive,
    required this.replyTime,
  });

  factory CommentReply.fromJson(Map<String, dynamic> json) {
    return CommentReply(
      replyId: _string(json['replyId']),
      commentId: _string(json['commentId']),
      userId: _string(json['userId']),
      replyType: _string(json['replyType']),
      content: _string(json['content']),
      archive: _bool(json['archive']),
      replyTime: _dateTime(json['replyTime']),
    );
  }
}

Map<String, dynamic> _map(dynamic value) {
  return value is Map<String, dynamic> ? value : <String, dynamic>{};
}

String _string(dynamic value) {
  return value?.toString() ?? '';
}

int _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

bool _bool(dynamic value) {
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  if (value is int) return value == 1;
  return false;
}

DateTime _dateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}
