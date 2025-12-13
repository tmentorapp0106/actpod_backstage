class UserInfo {
  final String userId;
  final String name;
  final String avatarUrl;
  final String email;
  const UserInfo({
    required this.userId,
    required this.name,
    required this.avatarUrl,
    required this.email,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
  final data = json['data'] ?? {}; // 進到內層 data

  return UserInfo(
    userId: json['userId'] ?? '',
    name: json['nickname'] ?? '',
    avatarUrl: json['avatarUrl'] ?? '',
    email: json['email'] ?? '',
  );
}
 String toString() {
    return 'UserInfo(id: $userId, name: $name, email: $email, avatarUrl: $avatarUrl)';
  }
}