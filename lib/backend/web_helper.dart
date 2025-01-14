import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
// import 'package:flutter/foundation.dart';
import 'package:playboy/backend/constants.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:playboy/backend/storage.dart';

class WebHelper {
  static late final Dio dio;
  static late CookieManager cookieManager;
  CancelToken _cancelToken = CancelToken();

  static final WebHelper _instance = WebHelper._internal();
  factory WebHelper() => _instance;
  WebHelper._internal() {
    BaseOptions options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {'referer': 'https://www.bilibili.com'},
    );
    dio = Dio(options);
    dio.transformer = BackgroundTransformer();
  }

  Future<void> init() async {
    var cookiePath = '${AppStorage().dataPath}/cookies';
    cookieManager =
        CookieManager(PersistCookieJar(storage: FileStorage(cookiePath)));
    dio.interceptors.add(cookieManager);
    if ((await cookieManager.cookieJar
            .loadForRequest(Uri.parse(Constants.mainBase)))
        .isEmpty) {
      await dio.get(Constants.mainBase); //获取默认cookie
    }
  }

  get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    var response = await dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
    );
    return response;
  }

  post(
    String path, {
    Map<String, dynamic>? queryParameters,
    data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    var response = await dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
    );
    return response;
  }

  download(urlPath, savePath) async {
    Response response;
    response = await dio.download(urlPath, savePath,
        onReceiveProgress: (int count, int total) {
      // if (kDebugMode) {
      //   print("$count $total");
      // }
    });
    return response.data;
  }

  void cancel({required CancelToken token}) {
    _cancelToken.cancel("cancelled");
    _cancelToken = token;
  }

  Future<bool> isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }
}
