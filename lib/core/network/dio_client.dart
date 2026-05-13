// File: lib/core/network/dio_client.dart
// Purpose: Singleton Dio instance preconfigured with base URL, timeouts, and interceptors.
// Used by: every feature's api_service.

import 'package:dio/dio.dart';

import '../config/api_config.dart';
import 'api_interceptor.dart';

class DioClient {
  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        contentType: 'application/json',
      ),
    )..interceptors.add(ApiInterceptor());
  }

  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio _dio;
  Dio get dio => _dio;
}
