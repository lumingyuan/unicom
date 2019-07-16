import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:event_bus/event_bus.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

export './common/common.dart';
export 'package:quiver/strings.dart';
export 'dart:async';
export 'dart:convert';
export 'dart:math';
export 'package:event_bus/event_bus.dart';
export 'package:flutter/material.dart';
export 'package:flutter/cupertino.dart' hide RefreshCallback;
export 'package:unicom_attendance/managers/user_manager.dart';
export 'package:unicom_attendance/managers/http_manager.dart';
export 'package:unicom_attendance/managers/clock_manager.dart';
export 'package:unicom_attendance/managers/jpush_manager.dart';
export 'package:unicom_attendance/setting.dart';
export 'package:intl/intl.dart' hide TextDirection;
export 'package:unicom_attendance/models/model.dart';

//屏幕宽高
final double kScreenWidth = MediaQueryData.fromWindow(window).size.width;
final double kScreenHeight = MediaQueryData.fromWindow(window).size.height;
//手机状态栏高度
final double kStateBarHeight = MediaQueryData.fromWindow(window).padding.top;
//距离底部的安全高度
final double kSafeAreaMarginBottom =
    MediaQueryData.fromWindow(window).padding.bottom;
//缩放比例
final double kScale = MediaQueryData.fromWindow(window).size.width / 375;

void lLog(String str) {
  print(str);
}

// 登出事件
class EventLogout {
  int reason; //1正常点击退出按钮  2token过期 3更换密码  4更换手机号
  EventLogout(this.reason);
}

//公司切换事件
class EventCompanyChanged {
  int jobId;
  EventCompanyChanged(this.jobId);
}

//刷新基础数据事件
class EventUpdateBaseData {}

//发起打开通知事件
class EventUpdateClock {}

//跳转申请详细页面
class EventOpenNotification {
  int approvalId;
  int operate; //0自己的申请 1审核别人
  EventOpenNotification(this.approvalId, this.operate);
}

class Global {
  static ThemeData themeData = new ThemeData(
      primaryColor: Colors.white,
      primaryIconTheme: IconThemeData(color: kTintColor),
      primaryColorBrightness: Brightness.light,
      accentColor: kTintColor,
      platform: TargetPlatform.iOS);

  static String get appDomain {
    // return 'http://112.1.71.198:9090/AttendanceInterfaceService/app/';

    return 'http://attendance.woqiche.cn:9010/AttendanceInterfaceService/app/';
  }

  static const bool inProduction =
      const bool.fromEnvironment("dart.vm.product");

  static final Color kTintColor = new Color(0xff4998fd);
  static final Color kDefTextColor = new Color(0xff696969);
  static final Color kBackgroundColor = themeData.scaffoldBackgroundColor;

  static EventBus eventBus = new EventBus();

  static JPush jpush = new JPush();

  static final GlobalKey kMainpageKey = new GlobalKey();

  // 密码正则， 必须包含字母，数字，字符，长度8-20
  static final RegExp passwordReg = new RegExp(
      '^(?=.*[A-Za-z])(?=.*\\d)(?=.*[\$@\$!%*#?&._-])[A-Za-z\\d\$@\$!%*#?&._-]{8,20}\$');
}
