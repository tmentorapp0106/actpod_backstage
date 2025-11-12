import 'package:actpod_studio/features/api/user_system_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserInfo {
  final String name;
  final String avatarUrl;
  final String email;
  const UserInfo({
    required this.name,
    required this.avatarUrl,
    required this.email,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
  final data = json['data'] ?? {}; // 進到內層 data

  return UserInfo(
    name: data['nickname'] ?? '',
    avatarUrl: data['avatarUrl'] ?? '',
    email: data['email'] ?? '',
  );
}

}

class UserController extends AsyncNotifier<UserInfo?> {
  @override
  Future<UserInfo?> build() async {
    final res = await UserApi().getUserInfo(); // ← 這裡呼叫你的 API
    print('User info response: $res'); // 👈 加這行
    return UserInfo.fromJson(res);
  }

  Future<void> refreshUser() async {
    state = const AsyncLoading();
    state = AsyncData(await build());
  }

  void clear() {
    state = const AsyncData(null);
  }
}

final userControllerProvider =
    AsyncNotifierProvider<UserController, UserInfo?>(UserController.new);
