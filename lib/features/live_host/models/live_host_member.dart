library;

class LiveHostMember {
  final String userId;
  final String nickname;
  final String avatarUrl;
  final bool isHandsUp;
  final bool isSpeaking;

  const LiveHostMember({
    required this.userId,
    required this.nickname,
    required this.avatarUrl,
    this.isHandsUp = false,
    this.isSpeaking = false,
  });

  factory LiveHostMember.fromJson(Map<String, dynamic> json) {
    return LiveHostMember(
      userId: json['userId']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString() ?? '',
      isHandsUp: json['isHandsUp'] == true,
      isSpeaking: json['isSpeaking'] == true,
    );
  }

  LiveHostMember copyWith({bool? isHandsUp, bool? isSpeaking}) {
    return LiveHostMember(
      userId: userId,
      nickname: nickname,
      avatarUrl: avatarUrl,
      isHandsUp: isHandsUp ?? this.isHandsUp,
      isSpeaking: isSpeaking ?? this.isSpeaking,
    );
  }
}
