import './global.dart';
import './controllers/login/splash_vc.dart';
import './controllers/login/login_vc.dart';
import './controllers/main/mainpage_vc.dart';
import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:baidu_location/baidu_location.dart';
import 'package:unicom_attendance/common/cupertino_localizations_delegate.dart';

void main() {
  //百度地图key初始化
  if (Platform.isIOS) {
    BaiduLocationClient.setApiKey('saSLCN8OG7elhUXlpT59mMCu3d8BIudU');
  } else if (Platform.isAndroid) {
    //安卓在android/build.gradle中配置
  }

  //推送初始化
  JPushManager.instance.init();

  //加载本地设置数据
  Setting.loadAll();

  //http初始化
  HttpManager.instance.init();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Global.themeData,
      routes: {
        SplashVC.sName: (context) => new SplashVC(),
        LoginVC.sName: (context) => new LoginVC(),
        MainpageVC.sName: (context) => new MainpageVC()
      },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        CupertinoLocalizationsDelegate(),
      ],
      supportedLocales: [
        const Locale('zh', 'CH'),
        const Locale('en', 'US'),
      ],
    );
  }
}
