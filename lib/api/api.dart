import 'dart:convert';

import 'package:actpod_studio/utils/cookies_util.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

String userId = '';

class DioClient {
  static const String _baseUrl =
      'https://gateway-1033518616359.asia-east1.run.app';
  static const Duration _timeout = Duration(seconds: 20);

  static Dio get instance => Dio(BaseOptions(baseUrl: _baseUrl));

  static Future<Response> handelPost(String path, Map<String, dynamic> data) {
    return _request(method: 'POST', path: path, data: data);
  }

  static Future<Response> handelGet(String path, Map<String, dynamic> data) {
    return _request(method: 'GET', path: path, queryParameters: data);
  }

  static Future<Response> handelPostWithToken(
    String path,
    Map<String, dynamic> data,
  ) {
    return _request(method: 'POST', path: path, data: data, withToken: true);
  }

  static Future<Response> handelGetWithToken(
    String path,
    Map<String, dynamic> data,
  ) {
    return _request(
      method: 'GET',
      path: path,
      queryParameters: data,
      withToken: true,
    );
  }

  static Future<Response> _request({
    required String method,
    required String path,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    bool withToken = false,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (withToken &&
          (CookieUtils.getCookie('userToken')?.isNotEmpty ?? false))
        'userToken': CookieUtils.getCookie('userToken')!,
    };

    http.Response rawResponse;
    if (method == 'POST') {
      rawResponse = await http
          .post(
            uri,
            headers: headers,
            body: jsonEncode(data ?? const <String, dynamic>{}),
          )
          .timeout(_timeout);
    } else {
      rawResponse = await http.get(uri, headers: headers).timeout(_timeout);
    }

    final parsedData = _parseBody(rawResponse.body);
    final response = Response(
      requestOptions: RequestOptions(
        path: path,
        method: method,
        headers: headers,
        baseUrl: _baseUrl,
      ),
      data: parsedData,
      statusCode: rawResponse.statusCode,
      headers: Headers.fromMap(
        rawResponse.headers.map((key, value) => MapEntry(key, <String>[value])),
      ),
      statusMessage: rawResponse.reasonPhrase,
    );

    if (rawResponse.statusCode >= 400) {
      throw DioError(
        requestOptions: response.requestOptions,
        response: response,
        type: DioErrorType.response,
        error: parsedData,
      );
    }

    return response;
  }

  static Uri _buildUri(String path, Map<String, dynamic>? queryParameters) {
    final baseUri = Uri.parse(_baseUrl);
    final resolved = baseUri.resolve(path);
    if (queryParameters == null || queryParameters.isEmpty) return resolved;

    return resolved.replace(
      queryParameters: queryParameters.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      ),
    );
  }

  static dynamic _parseBody(String body) {
    if (body.isEmpty) return <String, dynamic>{};
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }
}
