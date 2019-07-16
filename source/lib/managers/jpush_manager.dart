import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:unicom_attendance/global.dart';
import 'dart:io' show Platform;

class JPushManager {
  static JPushManager _instance = new JPushManager();
  static JPushManager get instance {
    return _instance;
  }

  JPush _jPush = new JPush();
  JPush get jPush {
    return _jPush;
  }

  void init() {
    _jPush.addEventHandler(
      // 接收通知回调方法。
      onReceiveNotification: (Map<String, dynamic> message) async {
        print("推送 onReceiveNotification: $message");
      },
      // 点击通知回调方法。
      onOpenNotification: (Map<String, dynamic> message) async {
        print("推送 onOpenNotification: $message");
        if (message['data'] != null) {
          Map<String, dynamic> data = json.decode(message['data']);
          int approvalId = data['approvalRecordId'] as int;
          int operate = data['operateType'] as int;
          if (approvalId > 0) {
            Global.eventBus.fire(EventOpenNotification(approvalId, operate));
          }
        }
      },
      // 接收自定义消息回调方法。
      onReceiveMessage: (Map<String, dynamic> message) async {
        print("推送 onReceiveMessage: $message");
      },
    );

    _jPush.setup(
        appKey: '39f9e8b1de7fda61fdcd8b14',
        channel: Platform.isIOS ? 'appstore' : 'android',
        production: Global.inProduction,
        debug: true);

    if (Platform.isIOS) {
      _jPush.applyPushAuthority(new NotificationSettingsIOS(
        sound: true,
        alert: true,
        badge: true,
      ));
    }

    // Future.delayed(Duration(seconds: 2)).then((_) {
    //   lLog('极光推送 getRegistrationID');
    //   _jPush.getRegistrationID().then((rid) {
    //     lLog('极光推送 $rid');
    //   });
    // });
  }

  void setAlias(String alias) async {
    try {
      var ret = await _jPush.setAlias(alias);
      lLog('setAlias ' + ret.toString());
    } catch (e) {
      lLog(e.toString());
    }
  }

  void deleteAlias() async {
    try {
      var ret = await _jPush.deleteAlias();
      lLog('deleteAlias ' + ret.toString());
    } catch (e) {
      lLog(e.toString());
    }
  }
}
