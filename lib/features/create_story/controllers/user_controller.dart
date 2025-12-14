import 'package:actpod_studio/features/api/api.dart';
import 'package:actpod_studio/features/api/channel_system_api.dart';
import 'package:actpod_studio/features/api/user_system_api.dart';
import 'package:actpod_studio/features/create_story/models/channel_model.dart';
import 'package:actpod_studio/features/create_story/models/user_model.dart';
import 'package:actpod_studio/main.dart';
import 'package:actpod_studio/utils/cookies_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserController extends Notifier<UserInfo?> {
  @override
  UserInfo? build() {
    return UserInfo(userId: '', name: '', avatarUrl: '', email: '');
  }

  Future<void> login(
    String thirdPartyUserToker,
    String? email,
    String displayname,
  ) async {
    final Response = await UserApi().thirdPartyCreateUserOrLogin(
      thirdPartyUserToker,
      email,
      displayname ?? "",
    );
    String userToken = Response.data['data']['userToken'] ?? '';
    CookieUtils.setCookie("userToken", userToken);
    hasLogin = true;
  }

  Future<void> getUserInfo() async {
    UserApi api = UserApi();
    final response = await api.getUserInfo();
    final userInfo = UserInfo.fromJson(response);
    state = userInfo;
    print('User info in controller: ${state?.name}');
  }


  void clear() {
    state = null;
  }
}

final userControllerProvider = NotifierProvider<UserController, UserInfo?>(
  UserController.new,
);
