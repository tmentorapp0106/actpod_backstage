library;

import 'live_host_member.dart';

class LiveHostChatMessage {
  final String userId;
  final String nickname;
  final String avatarUrl;
  final String content;
  final String type;
  final bool isHost;

  const LiveHostChatMessage({
    required this.userId,
    required this.nickname,
    required this.avatarUrl,
    required this.content,
    this.type = 'text',
    this.isHost = false,
  });

  factory LiveHostChatMessage.fromJson(Map<String, dynamic> json) {
    return LiveHostChatMessage(
      userId: json['userId']?.toString() ?? json['from']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '',
      avatarUrl: json['userAvatarUrl']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      type: json['params'] is List && (json['params'] as List).isNotEmpty
          ? (json['params'] as List).first.toString()
          : 'text',
      isHost: json['isHost'] == true,
    );
  }

  LiveHostChatMessage fillMember(LiveHostMember? member) {
    if (member == null) return this;
    return LiveHostChatMessage(
      userId: userId,
      nickname: nickname.isEmpty ? member.nickname : nickname,
      avatarUrl: avatarUrl.isEmpty ? member.avatarUrl : avatarUrl,
      content: content,
      type: type,
      isHost: isHost,
    );
  }

  LiveHostChatMessage markHost({
    required String nickname,
    required String avatarUrl,
  }) {
    return LiveHostChatMessage(
      userId: userId,
      nickname: this.nickname.isEmpty ? nickname : this.nickname,
      avatarUrl: this.avatarUrl.isEmpty ? avatarUrl : this.avatarUrl,
      content: content,
      type: type,
      isHost: true,
    );
  }
}
