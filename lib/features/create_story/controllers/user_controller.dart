import 'package:actpod_studio/features/api/user_system_api.dart';
import 'package:actpod_studio/features/create_story/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class UserController extends AsyncNotifier<UserInfo?> {
  @override
  Future<UserInfo?> build() async {
    final res = await UserApi().getUserInfo(); // ← 這裡呼叫你的 API
    // print('User info response: $res'); // 👈 加這行
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
