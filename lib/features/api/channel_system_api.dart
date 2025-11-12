import 'package:actpod_studio/features/api/api.dart';
import 'package:dio/dio.dart';

class ChannelApi {
  Future<Response> getUserChannels(String userId) async {
    Response response = await DioClient.handelGet("/channel/user/$userId", {});
    return response;
  }
}
