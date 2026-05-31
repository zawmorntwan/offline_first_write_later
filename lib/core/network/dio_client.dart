import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioClient {
  final Dio _dio;

  DioClient() : _dio = Dio() {
    _dio.options
      ..baseUrl = 'https://jsonplaceholder.typicode.com'
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 15)
      ..responseType = ResponseType.json;

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
      );
    }
  }

  Dio get dio => _dio;
}
