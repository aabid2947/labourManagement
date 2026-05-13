// File: lib/core/network/api_interceptor.dart
// Purpose: Dio interceptor — attaches auth token (when stored) and logs in dev builds.
// Used by: core/network/dio_client.dart.

import 'package:dio/dio.dart';

import '../config/env.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // TODO(api): read token from AuthStorage and attach as Bearer header.
    // final token = await AuthStorage().readToken();
    // if (token != null) options.headers['Authorization'] = 'Bearer $token';
    if (Env.isDev) {
      // ignore: avoid_print
      print('[API] ${options.method} ${options.uri}');
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (Env.isDev) {
      // ignore: avoid_print
      print('[API:ERR] ${err.requestOptions.uri} -> ${err.message}');
    }
    handler.next(err);
  }
}
