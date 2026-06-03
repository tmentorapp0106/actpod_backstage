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
    final data = json['data'] ?? json; // 進到內層 data

    return UserInfo(
      userId: data['userId'] ?? '',
      name: data['nickname'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      email: data['email'] ?? '',
    );
  }
  String toString() {
    return 'UserInfo(id: $userId, name: $name, email: $email, avatarUrl: $avatarUrl)';
  }

  UserInfo copyWith({
    String? userId,
    String? name,
    String? avatarUrl,
    String? email,
  }) {
    return UserInfo(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      email: email ?? this.email,
    );
  }
}
