import 'package:dio/dio.dart';
// config file
// baseUrl
// basePicUrl
import './http_config.dart';

class D {
  static D? _instance;

  late Dio dio;

  static D get instance {
    _instance ??= D._init();
    _instance!._iniDio();
    return _instance!;
  }

  D._init();

  _iniDio() {
    _instance!.dio = Dio(
      BaseOptions(baseUrl: baseUrl),
    );
  }
}
