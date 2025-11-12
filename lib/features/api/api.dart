import 'dart:io';
import 'dart:typed_data';
import 'package:actpod_studio/features/create_story/models/channel_model.dart';
import 'package:actpod_studio/features/create_story/models/space_model.dart';
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart' as m;
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

String userToken = "";
String userId = "";
List<Space> spaces = [];
List<Channel> channels = [];


class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://apiv1.actpodapp.com',
      connectTimeout: const Duration(
        seconds: 15,
      ).inMilliseconds, // ✅ 用 inMilliseconds
      receiveTimeout: const Duration(seconds: 20).inMilliseconds, // ✅
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Dio get instance => _dio;

  static Future<Response> handelPost(
    String path,
    Map<String, dynamic> data,
  ) async {
    return await _dio.post(path, data: data);
  }

  static Future<Response> handelGet(
    String path,
    Map<String, dynamic> data,
  ) async {
    return await _dio.get(path, queryParameters: data);
  }

  static Future<Response> handelPostWithToken(
    String path,
    Map<String, dynamic> data,
  ) async {
    _dio.options.headers["userToken"] = userToken;
    return await _dio.post(path, data: data);
  }

  static Future<Response> handelGetWithToken(
    String path,
    Map<String, dynamic> data,
  ) async {
    _dio.options.headers["userToken"] = userToken;
    return await _dio.get(path, queryParameters: data);
  }
}
