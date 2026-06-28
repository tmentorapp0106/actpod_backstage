import 'package:actpod_studio/api/api.dart';
import 'package:actpod_studio/api/response/voice_message_response/batch_get_stat.dart';

class VoiceMessageApi {
  Future<BatchGetVoiceMessageResponse> batchGetVoiceMessageStat(
    List<String> storyIds,
  ) async {
    final data = {"storyIdList": storyIds};

    final response = await DioClient.handelPostWithToken(
      "/voiceMessage/stat/batchGet",
      data,
    );
    return BatchGetVoiceMessageResponse.fromResponse(response);
  }
}
