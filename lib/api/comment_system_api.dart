import 'package:actpod_studio/api/api.dart';
import 'package:actpod_studio/api/response/comment_response/batch_get_comments.dart';
import 'package:actpod_studio/api/response/comment_response/batch_get_stat.dart';
import 'package:actpod_studio/api/response/comment_response/comment_action.dart';

class CommentApi {
  Future<CommentActionResponse> deleteComment(String commentId) async {
    final data = {"commentId": commentId};

    final response = await DioClient.handelPostWithToken(
      "/comment/delete",
      data,
    );
    return CommentActionResponse.fromResponse(response);
  }

  Future<CreateCommentResponse> createComment(
    String storyId,
    String content,
    int sendTiming,
  ) async {
    final data = {
      "storyId": storyId,
      "content": content,
      "sendTiming": sendTiming,
    };

    final response = await DioClient.handelPostWithToken("/comment", data);
    return CreateCommentResponse.fromResponse(response);
  }

  Future<CommentActionResponse> createReply(
    String commentId,
    String storyId,
    String replyType,
    String content,
  ) async {
    final data = {
      "commentId": commentId,
      "storyId": storyId,
      "replyType": replyType,
      "content": content,
    };

    final response = await DioClient.handelPostWithToken(
      "/comment/reply",
      data,
    );
    return CommentActionResponse.fromResponse(response);
  }

  Future<BatchGetCommentsResponse> batchGetComments(
    List<String> storyIds,
  ) async {
    final data = {"storyIds": storyIds};

    final response = await DioClient.handelPostWithToken(
      "/comment/batchGet",
      data,
    );
    return BatchGetCommentsResponse.fromResponse(response);
  }

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
