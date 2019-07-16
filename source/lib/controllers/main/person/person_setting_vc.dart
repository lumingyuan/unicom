import 'package:unicom_attendance/global.dart';
import 'package:flutter/cupertino.dart';
import './about_us_vc.dart';
import './person_change_pass_vc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:package_info/package_info.dart';

class PersonSettingVC extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _PersonSettingVCState();
}

class _PersonSettingVCState extends State<PersonSettingVC> {
  bool _autoClockIn = false;

  String _version = '';

  @override
  void initState() {
    super.initState();

    _autoClockIn = Setting.autoClock;

    PackageInfo.fromPlatform().then((PackageInfo info) {
      setState(() {
        _version = info.version;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  onVersionTap() async {
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
        } else {
          ToastUtil.shortToast(context, '已是最新版本');
        }
      } else if (model.android != null && Platform.isAndroid) {
        if ((model.ios.buildNumber ?? 0) > localBuild) {
          // 安卓需要更新
        }
      }
    } else {
      ToastUtil.shortToast(context, ret.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Global.kBackgroundColor,
      appBar: newAppBar(context, '设置'),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.only(top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MyListTile(
                    Text('自动签到'),
                    padding: EdgeInsets.only(left: 15),
                    hasForward: false,
                    trailing: CupertinoSwitch(
                      value: Setting.autoClock,
                      onChanged: (bool val) {
                        setState(() {
                          Setting.autoClock = val;
                        });
                        Setting.saveBool(Setting.kAutoClock, _autoClockIn);
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 15, top: 10, bottom: 20),
                    child: Text('开启自动签到功能后当打开APP的时候自动进行签到',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                  MyListTile(
                    Text('修改密码'),
                    padding: EdgeInsets.only(left: 15, right: 5),
                    hasForward: true,
                    onPressed: () {
                      NavigatorUtil.pushVC(context, new PersonChangePassVC());
                    },
                  ),
                  Container(
                    height: 10,
                  ),
                  MyListTile(
                    Text('关于我们'),
                    padding: EdgeInsets.only(left: 15, right: 5),
                    hasForward: true,
                    onPressed: () {
                      NavigatorUtil.pushVC(context, new AboutUsVS());
                    },
                  ),
                  Divider(color: Colors.transparent, height: 1),
                  MyListTile(Text('当前版本'),
                      padding: EdgeInsets.only(left: 15, right: 5),
                      hasForward: false,
                      onPressed: onVersionTap,
                      trailing: Text(isEmpty(_version) ? '' : 'v$_version',
                          style: TextStyle(color: Colors.grey))),
                ],
              ),
              Spacer(),
              Container(
                  width: kScreenWidth,
                  padding: EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                  child: newCommonButton('退 出', () {
                    Global.eventBus.fire(new EventLogout(1));
                  }))
            ],
          ),
        ),
      ),
    );
  }
}
