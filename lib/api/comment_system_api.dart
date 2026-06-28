import 'package:actpod_studio/api/api.dart';
import 'package:actpod_studio/api/response/comment_response/batch_get_stat.dart';

class CommentApi {
  Future<BatchGetStoryStatResponse> batchGetStoryStat(
    List<String> storyIds,
  ) async {
    final data = {"storyIds": storyIds};

    final response = await DioClient.handelPostWithToken(
      "/comment/storyStat/batchGet",
      data,
    );
    return BatchGetStoryStatResponse.fromResponse(response);
  }
}
