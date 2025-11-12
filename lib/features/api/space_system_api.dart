import 'package:actpod_studio/features/api/api.dart';
import 'package:dio/dio.dart';

class SpaceApi {
  Future<Response> getSpaces() async {
    Response response = await DioClient.handelGet("/space", {});
    return response;
  }
}