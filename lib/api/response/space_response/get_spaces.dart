import 'package:actpod_studio/features/create_story/models/space_model.dart';
import 'package:dio/dio.dart';

class GetSpacesResponse {
  final String code;
  final String message;
  final List<Space> spaces;

  const GetSpacesResponse({
    required this.code,
    required this.message,
    required this.spaces,
  });

  factory GetSpacesResponse.fromResponse(Response response) {
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : <String, dynamic>{};
    final data = json['data'];

    return GetSpacesResponse(
      code: json['code'] is String ? json['code'] as String : '',
      message: json['message'] is String ? json['message'] as String : '',
      spaces: data is List
          ? data.whereType<Map<String, dynamic>>().map(Space.fromJson).toList()
          : const [],
    );
  }
}
