class Channel {
  String channelId;
  String userId;
  String nickname;
  String userAvatarUrl;
  String channelDescription;
  String channelName;
  String channelImageUrl;
  int storyCount;
  DateTime createTime;

  Channel(
    this.channelId,
    this.userId,
    this.nickname,
    this.userAvatarUrl,
    this.channelDescription,
    this.channelName,
    this.channelImageUrl,
    this.storyCount,
    this.createTime
  );

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      json["channelId"],
      json["userId"],
      json["nickname"],
      json["userAvatarUrl"],
      json["channelDescription"],
      json["channelName"],
      json["channelImageUrl"],
      json["storyCount"],
      DateTime.parse(json["createTime"])
    );
  }
}