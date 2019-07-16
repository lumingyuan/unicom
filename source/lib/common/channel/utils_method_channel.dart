import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:unicom_attendance/managers/jpush_manager.dart';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

///
/// 工具集合
///   一些flutter不方便实现的功能（如：aes加密解密等），需要调用平台的实现
///
///

class UtilsMethodChannel {
  static const platform = const MethodChannel('com.unicom.attendance/utils');

  static Future<String> getDeviceId() async {
    String data = "";
    if (Platform.isIOS) {
      try {
        data = await platform.invokeMethod('getDeviceId');
      } on PlatformException catch (e) {
        print("UtilsMethodChannel error:" + e.message);
      }
    } else {
      data = await JPushManager.instance.jPush.getRegistrationID();
    }

    return hex.encode(md5.convert(new Utf8Encoder().convert(data)).bytes).substring(8,24);
  }

  static Future<Null> test() async {
    try {
      await platform.invokeMethod('test');
    } on PlatformException catch (e) {
      print("native_utils error:" + e.message);
    }
  }
}
