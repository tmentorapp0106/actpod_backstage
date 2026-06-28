class GetStoriesByUserIdRes {
  String code;
  String message;
  List<StoryItem>? storyList;

  GetStoriesByUserIdRes(this.code, this.message, this.storyList);

  factory GetStoriesByUserIdRes.fromJson(Map<String, dynamic> json) {
    return GetStoriesByUserIdRes(
      json["code"],
      json["message"],
      json["data"]?.map<StoryItem>((json) => StoryItem.fromJson(json)).toList(),
    );
  }
}

class StoryItem {
  String username;
  String collaboratorName;
  String storyId;
  String spaceName;
  String channelId;
  String channelName;
  String channelImageUrl;
  String voiceMessageStatus;
  int voiceMessageCount;
  int likesCount;
  String userId;
  String collaboratorId;
  String userAvatarUrl;
  String collaboratorAvatarUrl;
  String storyUrl;
  String storyName;
  String storyDescription;
  int storyLength;
  int totalLength;
  String storyImageUrl;
  List<String> storyImageUrls;
  DateTime storyUploadTime;
  Review review;
  int count;
  bool locked;
  bool isPremium;
  int price;
  String contentRating;
  DateTime releaseTime;

  StoryItem(
    this.username,
    this.collaboratorName,
    this.storyId,
    this.spaceName,
    this.channelId,
    this.channelName,
    this.channelImageUrl,
    this.voiceMessageStatus,
    this.voiceMessageCount,
    this.likesCount,
    this.userId,
    this.collaboratorId,
    this.userAvatarUrl,
    this.collaboratorAvatarUrl,
    this.storyUrl,
    this.storyName,
    this.storyDescription,
    this.storyLength,
    this.totalLength,
    this.storyImageUrl,
    this.storyImageUrls,
    this.storyUploadTime,
    this.review,
    this.count,
    this.locked,
    this.isPremium,
    this.price,
    this.contentRating,
    this.releaseTime,
  );

  factory StoryItem.fromJson(Map<String, dynamic>? json) {
    json ??= {};

    return StoryItem(
      _string(json["userName"]),
      _string(json["collaboratorName"]),
      _string(json["storyId"]),
      _string(json["spaceName"]),
      _string(json["channelId"]),
      _string(json["channelName"]),
      _string(json["channelImageUrl"]),
      _string(json["voiceMessageStatus"]),
      _int(json["voiceMessageCount"]),
      _int(json["likesCount"]),
      _string(json["userId"]),
      _string(json["collaboratorId"]),
      _string(json["userAvatarUrl"]),
      _string(json["collaboratorAvatarUrl"]),
      _string(json["storyUrl"]),
      _string(json["storyName"]),
      _string(json["storyDescription"]),
      _int(json["storyLength"]),
      _int(json["totalLength"]),
      _string(json["storyImageUrl"]),
      _stringList(json["storyImageUrls"]),
      _dateTime(json["storyUploadTime"]),
      Review.fromJson(json["review"] as Map<String, dynamic>?),
      _int(json["count"]),
      _bool(json["locked"]),
      _bool(json["isPremium"]),
      _int(json["price"]),
      json["contentRating"] ?? "general",
      _dateTime(json["releaseTime"]),
    );
  }

  static String _string(dynamic value) {
    if (value == null) return "";
    return value.toString();
  }

  static int _int(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _bool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == "true";
    }
    if (value is int) return value == 1;
    return false;
  }

  static List<String> _stringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  static DateTime _dateTime(dynamic value) {
    if (value == null) return DateTime.now();

    if (value is DateTime) return value;

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return DateTime.now();
  }
}

class Review {
  final String status;
  final String comment;

  Review({required this.status, required this.comment});

  factory Review.fromJson(Map<String, dynamic>? json) {
    json ??= {};

    return Review(
      status: json["status"]?.toString() ?? "",
      comment: json["comment"]?.toString() ?? "",
    );
  }
}
