import 'package:actpod_studio/api/api.dart';
import 'package:actpod_studio/api/response/channel_response/get_user_channels.dart';

class ChannelApi {
  Future<GetUserChannelsResponse> getUserChannels(String userId) async {
    final response = await DioClient.handelGet("/channel/user/$userId", {});
    return GetUserChannelsResponse.fromResponse(response);
  }
}
