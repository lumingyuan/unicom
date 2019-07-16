import 'package:unicom_attendance/global.dart';
import './login_vc.dart';
import '../main/mainpage_vc.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class SplashVC extends StatefulWidget {
  static final String sName = '/';

  @override
  State<StatefulWidget> createState() {
    return new _SplashVCState();
  }
}

class _SplashVCState extends State<SplashVC> {
  @override
  void initState() {
    super.initState();

    loadInitData();
  }

  loadInitData() async {
    int beginTime = DateTime.now().millisecond;
    // 获取用户信息
    await UserManager.instance.init();

    //检查更新
    await checkUpdate();

    ///等待token更新
    /// 本地token不存在。或者token返回false
    /// 延期成功返回true
    bool tokenAvailiable = await HttpManager.instance.updateToken();

    //超过2秒立即跳转，没超过延迟到2秒跳转
    int delta = 2000 - (DateTime.now().millisecond - beginTime);
    if (delta < 0) {
      delta = 0;
    }
    //延迟跳转
    Future.delayed(Duration(milliseconds: delta), () {
      if (tokenAvailiable && UserManager.instance.userModel != null) {
        // token有效并有用户信息跳转到主页
        Navigator.of(context).pushReplacementNamed(MainpageVC.sName);
      } else {
        //跳转到登录页
        Navigator.of(context).pushReplacementNamed(LoginVC.sName);
      }
    });
  }

  checkUpdate() async {
    PackageInfo info = await PackageInfo.fromPlatform();
    ResponseModel ret = await HttpManager.instance.post('loadAppVersion');
    if (ret.isSuccess) {
      VersionModel model = VersionModel.fromJson(ret.data);
      int localBuild = int.tryParse(info.buildNumber);
      if (model.ios != null && Platform.isIOS) {
        if ((model.ios.buildNumber ?? 0) > localBuild) {
          // ios需要更新
          bool update = false;
          if (model.ios.forceUpdate > 0) {
            update = await showAlertDialog(context, '新版本通知', '发现新版，现在就去更新？',
                cancel: false, confirmText: '立即更新');
          } else {
            update = await showAlertDialog(context, '新版本通知', '发现新版，现在就去更新？');
          }
          if (update) {
            await launch(
                'itms-services://?action=download-manifest&url=${model.ios.plist}');
          }
        }
      } else if (model.android != null && Platform.isAndroid) {
        if ((model.ios.buildNumber ?? 0) > localBuild) {
          // 安卓需要更新
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          fit: BoxFit.fill,
          image: ImageUtil.assetImage('splash_bg.png'),
        )),
      ),
    );
  }
}
