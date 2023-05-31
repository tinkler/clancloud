import 'package:Clan/api/model/mqtt/user.dart';
import 'package:Clan/pages/signin/signin_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
// config file
// baseUrl
// basePicUrl
import '../const/hive.dart';
import './http_config.dart';

class D {
  static D? _instance;

  late Dio dio;
  bool initialized = false;

  static D get instance {
    _instance ??= D._init();
    if (!_instance!.initialized) _instance!._iniDio();
    return _instance!;
  }

  D._init();

  _iniDio() {
    _instance!.initialized = true;
    _instance!.dio = Dio(
      BaseOptions(baseUrl: baseUrl),
    );
    _instance!.dio.interceptors.add(_TokenInterceptor());
  }

  initErrorInterceptor(GlobalKey<NavigatorState> navigatorKey) {
    _instance!.dio.interceptors.add(_ErrorInterceptor(navigatorKey));
  }
}

class _TokenInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    Hive.openBox<String>(boxSys).then((sysBox) {
      var token = sysBox.get(boxValSysToken);
      if (token != null && token.isNotEmpty) {
        options = options.copyWith(headers: {'Authorization': 'Bearer $token'});
      }
      super.onRequest(options, handler);
    });
  }
}

class _ErrorInterceptor extends Interceptor {
  final GlobalKey<NavigatorState> navigatorKey;
  bool _isRefreshing = false;

  _ErrorInterceptor(this.navigatorKey);

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data['code'] != 0) {
      handler.reject(_ModelError.fromDioError(
          DioError(
            requestOptions: response.requestOptions,
          ),
          (response.data['cn_message'] as String).isNotEmpty
              ? response.data['message']
              : ''));
      return;
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response != null) {
      switch (err.response!.statusCode) {
        case 404:
          handler.resolve(Response(
            requestOptions: err.requestOptions,
            data: {
              'code': 1,
              'message': '远程服务器未响应',
            },
          ));
          return;
        case 401:
          var sysBox = await Hive.openBox<String>(boxSys);
          var token = sysBox.get(boxValSysToken);
          var deviceToken = sysBox.get(boxValSysDeviceToken);
          if (deviceToken != null &&
              deviceToken.isNotEmpty &&
              token != null &&
              token.isNotEmpty &&
              !_isRefreshing) {
            _isRefreshing = true;
            var auth = Auth()
              ..deviceToken = deviceToken
              ..token = token;
            try {
              await auth.quickSignin();
              await sysBox.put(boxValSysToken, auth.token);
              await sysBox.put(boxValSysDeviceToken, auth.deviceToken);
              RequestOptions options = err.response!.requestOptions;
              var newResponse = await D.instance.dio.request(options.path,
                  options: Options(
                    method: options.method,
                    headers: options.headers
                      ..addAll({'Authorization': 'Bearer ${auth.token}'}),
                    responseType: options.responseType,
                    contentType: options.contentType,
                    extra: options.extra,
                    sendTimeout: options.sendTimeout,
                    receiveTimeout: options.receiveTimeout,
                    validateStatus: options.validateStatus,
                    receiveDataWhenStatusError:
                        options.receiveDataWhenStatusError,
                    followRedirects: options.followRedirects,
                    maxRedirects: options.maxRedirects,
                    requestEncoder: options.requestEncoder,
                    responseDecoder: options.responseDecoder,
                    listFormat: options.listFormat,
                    // path: options.path,
                    // baseUrl: options.baseUrl,
                    // queryParameters: options.queryParameters,
                    // onReceiveProgress: options.onReceiveProgress,
                    // onSendProgress: options.onSendProgress,
                    // cancelToken: options.cancelToken,
                    // extra: options.extra,
                    // responseType: options.responseType,
                    // contentType: options.contentType,
                    // validateStatus: options.validateStatus,
                    // receiveDataWhenStatusError:
                    //     options.receiveDataWhenStatusError,
                    // followRedirects: options.followRedirects,
                    // maxRedirects: options.maxRedirects,
                    // requestEncoder: options.requestEncoder,
                    // responseDecoder: options.responseDecoder,
                    // listFormat: options.listFormat,
                  ),
                  data: options.data,
                  queryParameters: options.queryParameters);
              handler.resolve(newResponse);
              return;
            } on Exception {
              navigatorKey.currentState!
                  .pushReplacementNamed(SigninPage.routeName);
              return;
            } finally {
              _isRefreshing = false;
            }
          }
      }
    }
    super.onError(err, handler);
  }
}

class _ModelError extends DioError {
  _ModelError.fromDioError(DioError dioError, String message)
      : super(
            requestOptions: dioError.requestOptions,
            response: dioError.response,
            error: dioError.error,
            type: dioError.type,
            message: message);

  @override
  String toString() {
    if (message != null) {
      return message!;
    }
    return super.toString();
  }
}
