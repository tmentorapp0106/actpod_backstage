import 'package:actpod_studio/features/api/api.dart';
import 'package:dio/dio.dart';

class UserApi {
  Future<Response> thirdPartyCreateUserOrLogin(
    String firebaseToken,
    String? email,
    String nickname,
  ) async {
    var postData = {
      "firebaseToken": firebaseToken,
      "thirdPartyEmail": email,
      "thirdPartyNickname": nickname,
    };

    Response response = await DioClient.handelPost(
      "/user/signupOrLoginWithThirdParty/v2",
      postData,
    );

    return response;
  }

  Future<dynamic> getUserInfo() async {
    Response response = await DioClient.handelGetWithToken("/user", {});
    return response.data;
  }
}
