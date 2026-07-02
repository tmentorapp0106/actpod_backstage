import 'package:actpod_studio/api/api.dart';
import 'package:actpod_studio/api/response/user_response/get_user_info.dart';
import 'package:actpod_studio/api/response/user_response/received_donation.dart';
import 'package:actpod_studio/api/response/user_response/search_user.dart';
import 'package:actpod_studio/api/response/user_response/third_party_create_user_or_login.dart';

class UserApi {
  Future<ThirdPartyCreateUserOrLoginResponse> thirdPartyCreateUserOrLogin(
    String thirdPartyUserId,
    String? email,
    String nickname,
  ) async {
    var postData = {
      "firebaseToken": thirdPartyUserId,
      "thirdPartyEmail": email,
      "thirdPartyNickname": nickname,
    };

    final response = await DioClient.handelPost(
      "/user/signupOrLoginWithThirdParty/v2",
      postData,
    );

    return ThirdPartyCreateUserOrLoginResponse.fromResponse(response);
  }

  Future<GetUserInfoResponse> getUserInfo() async {
    final response = await DioClient.handelGetWithToken("/user", {});
    return GetUserInfoResponse.fromResponse(response);
  }

  Future<SearchUserResponse> searchUser(String nickname) async {
    var postData = {"nickname": nickname};
    final response = await DioClient.handelPost("/user/search", postData);
    return SearchUserResponse.fromResponse(response);
  }

  Future<ReceivedDonationResponse> getReceivedDonation(String userId) async {
    final response = await DioClient.handelGetWithToken(
      "/coinsAndCash/donation/received/user/$userId",
      {},
    );
    return ReceivedDonationResponse.fromResponse(response);
  }
}
