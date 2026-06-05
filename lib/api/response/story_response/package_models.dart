class PackagePrice {
  final String packagePriceId;
  final String priceType;
  final String lable;
  final int podcoins;
  final int twd;
  final bool isActive;

  const PackagePrice({
    required this.packagePriceId,
    required this.priceType,
    required this.lable,
    required this.podcoins,
    required this.twd,
    required this.isActive,
  });

  factory PackagePrice.fromJson(Map<String, dynamic> json) {
    return PackagePrice(
      packagePriceId: _string(json['packagePriceId']),
      priceType: _string(json['priceType']),
      lable: _string(json['lable']),
      podcoins: _int(json['podcoins']),
      twd: _int(json['twd']),
      isActive: _bool(json['isActive']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (packagePriceId.isNotEmpty) 'packagePriceId': packagePriceId,
      'priceType': priceType,
      'lable': lable,
      'podcoins': podcoins,
      'twd': twd,
      'isActive': isActive,
    };
  }
}

class PackageInfo {
  final String packageId;
  final String userId;
  final String packageName;
  final String packageDescription;
  final String packageImageUrl;
  final String channelId;
  final String spaceId;
  final String packageType;
  final List<PackagePrice> packagePrices;
  final DateTime? createTime;
  final DateTime? updateTime;
  final String nickname;
  final String avatarUrl;
  final String channelName;
  final String channelImageUrl;
  final String spaceName;
  final List<PackageStoryInfo> stories;

  const PackageInfo({
    required this.packageId,
    required this.userId,
    required this.packageName,
    required this.packageDescription,
    required this.packageImageUrl,
    required this.channelId,
    required this.spaceId,
    required this.packageType,
    required this.packagePrices,
    required this.createTime,
    required this.updateTime,
    required this.nickname,
    required this.avatarUrl,
    required this.channelName,
    required this.channelImageUrl,
    required this.spaceName,
    required this.stories,
  });

  factory PackageInfo.fromJson(Map<String, dynamic> json) {
    return PackageInfo(
      packageId: _string(json['packageId']),
      userId: _string(json['userId']),
      packageName: _string(json['packageName']),
      packageDescription: _string(json['packageDescription']),
      packageImageUrl: _string(json['packageImageUrl']),
      channelId: _string(json['channelId']),
      spaceId: _string(json['spaceId']),
      packageType: _string(json['packageType']),
      packagePrices: _packagePrices(json['packagePrices']),
      createTime: _dateTime(json['createTime']),
      updateTime: _dateTime(json['updateTime']),
      nickname: _string(json['nickname']),
      avatarUrl: _string(json['avatarUrl']),
      channelName: _string(json['channelName']),
      channelImageUrl: _string(json['channelImageUrl']),
      spaceName: _string(json['spaceName']),
      stories: _packageStories(json['stories']),
    );
  }
}

class PremiumPackage {
  final String packageId;
  final String userId;
  final String packageName;
  final String packageDescription;
  final String packageImageUrl;
  final String channelId;
  final String spaceId;
  final String packageType;
  final List<PackagePrice> packagePrices;
  final DateTime? createTime;
  final DateTime? updateTime;

  const PremiumPackage({
    required this.packageId,
    required this.userId,
    required this.packageName,
    required this.packageDescription,
    required this.packageImageUrl,
    required this.channelId,
    required this.spaceId,
    required this.packageType,
    required this.packagePrices,
    required this.createTime,
    required this.updateTime,
  });

  factory PremiumPackage.fromJson(Map<String, dynamic> json) {
    return PremiumPackage(
      packageId: _string(json['packageId']),
      userId: _string(json['userId']),
      packageName: _string(json['packageName']),
      packageDescription: _string(json['packageDescription']),
      packageImageUrl: _string(json['packageImageUrl']),
      channelId: _string(json['channelId']),
      spaceId: _string(json['spaceId']),
      packageType: _string(json['packageType']),
      packagePrices: _packagePrices(json['packagePrices']),
      createTime: _dateTime(json['createTime']),
      updateTime: _dateTime(json['updateTime']),
    );
  }
}

class PackageStoryInfo {
  final String storyId;
  final String userId;
  final String collaborator;
  final String spaceId;
  final String channelId;
  final String storyUrl;
  final int previewStartFrom;
  final int previewEndAt;
  final String previewUrl;
  final String storyName;
  final String storyDescription;
  final List<String> storyImageUrls;
  final int storyLength;
  final DateTime? storyUploadTime;
  final int count;
  final bool isPremium;
  final String packageId;
  final String packageNote;
  final String storyStatus;
  final Review review;
  final bool locked;
  final bool archive;
  final DateTime? updateTime;
  final DateTime? releaseTime;
  final String nickname;
  final String avatarUrl;
  final String collaboratorName;
  final String collaboratorAvatarUrl;
  final String channelName;
  final String channelImageUrl;
  final String spaceName;

  const PackageStoryInfo({
    required this.storyId,
    required this.userId,
    required this.collaborator,
    required this.spaceId,
    required this.channelId,
    required this.storyUrl,
    required this.previewStartFrom,
    required this.previewEndAt,
    required this.previewUrl,
    required this.storyName,
    required this.storyDescription,
    required this.storyImageUrls,
    required this.storyLength,
    required this.storyUploadTime,
    required this.count,
    required this.isPremium,
    required this.packageId,
    required this.packageNote,
    required this.storyStatus,
    required this.review,
    required this.locked,
    required this.archive,
    required this.updateTime,
    required this.releaseTime,
    required this.nickname,
    required this.avatarUrl,
    required this.collaboratorName,
    required this.collaboratorAvatarUrl,
    required this.channelName,
    required this.channelImageUrl,
    required this.spaceName,
  });

  factory PackageStoryInfo.fromJson(Map<String, dynamic> json) {
    return PackageStoryInfo(
      storyId: _string(json['storyId']),
      userId: _string(json['userId']),
      collaborator: _string(json['collaborator']),
      spaceId: _string(json['spaceId']),
      channelId: _string(json['channelId']),
      storyUrl: _string(json['storyUrl']),
      previewStartFrom: _int(json['previewStartFrom']),
      previewEndAt: _int(json['previewEndAt']),
      previewUrl: _string(json['previewUrl']),
      storyName: _string(json['storyName']),
      storyDescription: _string(json['storyDescription']),
      storyImageUrls: _stringList(json['storyImageUrls']),
      storyLength: _int(json['storyLength']),
      storyUploadTime: _dateTime(json['storyUploadTime']),
      count: _int(json['count']),
      isPremium: _bool(json['isPremium']),
      packageId: _string(json['packageId']),
      packageNote: _string(json['packageNote']),
      storyStatus: _string(json['storyStatus']),
      review: Review.fromJson(json['review']),
      locked: _bool(json['locked']),
      archive: _bool(json['archive']),
      updateTime: _dateTime(json['updateTime']),
      releaseTime: _dateTime(json['releaseTime']),
      nickname: _string(json['nickname']),
      avatarUrl: _string(json['avatarUrl']),
      collaboratorName: _string(json['collaboratorName']),
      collaboratorAvatarUrl: _string(json['collaboratorAvatarUrl']),
      channelName: _string(json['channelName']),
      channelImageUrl: _string(json['channelImageUrl']),
      spaceName: _string(json['spaceName']),
    );
  }
}

class Review {
  final Map<String, dynamic> data;

  const Review({required this.data});

  factory Review.fromJson(dynamic json) {
    return Review(data: json is Map<String, dynamic> ? json : const {});
  }
}

String _string(dynamic value) => value is String ? value : '';

int _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

bool _bool(dynamic value) => value is bool ? value : false;

DateTime? _dateTime(dynamic value) {
  if (value is String) return DateTime.tryParse(value);
  return null;
}

List<String> _stringList(dynamic value) {
  if (value is! List) return const [];
  return value.whereType<String>().toList();
}

List<PackagePrice> _packagePrices(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map<String, dynamic>>()
      .map(PackagePrice.fromJson)
      .toList();
}

List<PackageStoryInfo> _packageStories(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map<String, dynamic>>()
      .map(PackageStoryInfo.fromJson)
      .toList();
}
