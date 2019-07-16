import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class NavigatorUtil {
  static pushVC(BuildContext context, Widget vc, {bool needLogin = false}) async {
    // if (needLogin && !UserManager.shareInstance().isLogin) {
    //   //检查是否登陆，未登录将跳转到登录页面
    //   goLogin(context);
    //   return;
    // }
   return await Navigator.push(
        context,
        new CupertinoPageRoute(
            builder: (context) => vc, fullscreenDialog: false));
  }
}
