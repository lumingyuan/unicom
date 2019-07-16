import 'package:dio/dio.dart';
import 'dart:async';
import 'package:unicom_attendance/setting.dart';
import 'package:quiver/strings.dart';
import 'package:unicom_attendance/global.dart' show Global, EventLogout, lLog;
import 'package:unicom_attendance/models/response_model.dart';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';

class HttpManager {
  static HttpManager _instance = new HttpManager();
  static HttpManager get instance {
    return _instance;
  }

  HttpManager() {
    print('httpmanager new ');
  }

  Dio _dio;

  String _token;
  void setToken(String token) {
    _token = token;
    Setting.saveString(Setting.kToken, _token);
    _dio.options.headers['token'] = _token;
  }

  //初始化
  void init() async {
    _token = await Setting.getString(Setting.kToken);

    Options op = Options(
      baseUrl: Global.appDomain,
      connectTimeout: 30 * 1000,
      receiveTimeout: 30 * 1000,
      responseType: ResponseType.PLAIN,
      contentType: ContentType.parse('application/x-www-form-urlencoded'),
      headers: {"token": "$_token"},
    );
    _dio = new Dio(op);
  }

  //更新token
  Future<bool> updateToken() async {
    if (isEmpty(_token)) {
      return false;
    }
    ResponseModel ret = await post('checkToken', params: {'token': _token});
    if (ret.isSuccess) {
      return true;
    } else {
      return false;
    }
  }

  int serverTimeDelta = 0;
  void updateServerTiemDelta(DateTime serverTime) {
    if (serverTime != null) {
      DateTime now = DateTime.now();
      int delta = now.millisecondsSinceEpoch -
          (serverTime.millisecondsSinceEpoch + 500); //由于网络延迟，加上0.5秒
      if (delta == 0) {
        serverTimeDelta = 0;
      } else {
        if (serverTimeDelta == 0 || delta.abs() < serverTimeDelta.abs()) {
          serverTimeDelta = delta;
        }
      }
    }
  }

  ///
  ///  post请求
  ///
  Future<ResponseModel> post(String path, {Map<String, dynamic> params}) async {
    ResponseModel ret;
    try {
      String url = Global.appDomain + '$path';
      lLog('[POST] $url');
      lLog('[Params] $params');

      Response<String> response = await _dio.post(path, data: params);
      lLog('[Resp] ${response.statusCode} | ${response.data}');

      //获取服务器时间
      DateTime date = DateFormat("EEE, dd MMM yyyy HH:mm:ss")
          .parse(response.headers.value(HttpHeaders.dateHeader), true);
      updateServerTiemDelta(date);

      if (response.statusCode == 200) {
        ret = ResponseModel.fromJson(json.decode(response.data));
        if (ret.code == 0) {
          //token失效
          Global.eventBus.fire(new EventLogout(2));
        }
      } else {
        lLog('${response.toString()}');
        ret = ResponseModel(response.statusCode, '服务器被火星人劫持了～', null);
      }
    } on DioError catch (e) {
      print('${e.toString()}, ${e.response}');
      ret = ResponseModel(-999, '服务器被火星人劫持了～', null);
    } catch (e) {
      print('${e.toString()}');
      ret = ResponseModel(-999, '服务器被外星人劫持了～', null);
    }
    return ret;
  }

  ///
  ///   get 请求
  ///
  Future<dynamic> get(String url) async {}
}
