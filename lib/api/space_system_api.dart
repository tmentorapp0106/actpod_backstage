import 'package:actpod_studio/api/api.dart';
import 'package:actpod_studio/api/response/space_response/get_spaces.dart';

class SpaceApi {
  Future<GetSpacesResponse> getSpaces() async {
    final response = await DioClient.handelGet("/space", {});
    return GetSpacesResponse.fromResponse(response);
  }
}
