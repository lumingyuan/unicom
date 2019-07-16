import 'dart:io';

import 'package:common_utils/common_utils.dart';
import 'package:unicom_attendance/global.dart';
import 'package:flutter/cupertino.dart';
import '../main/mainpage_vc.dart';
import './forget_pass_vc.dart';
import 'package:device_info/device_info.dart';

class LoginVC extends StatefulWidget {
  static final String sName = 'login';

  @override
  State<StatefulWidget> createState() {
    return new _LoginVCState();
  }
}

class _LoginVCState extends State<LoginVC> {
  final FocusNode _accountFocusNode = new FocusNode();
  final FocusNode _codeFocusNode = new FocusNode();
  final TextEditingController _accountCtrl = new TextEditingController();
  final TextEditingController _codeCtrl = new TextEditingController();

  int _countDown = 0;
  TimerUtil _timer;

  bool get codeButtonEnable {
    if (isEmpty(_accountCtrl.text?.trim())) {
      return false;
    }
    return _countDown == 0;
  }

  bool get loginBtnEnable {
    return isNotEmpty(_codeCtrl.text) && isNotEmpty(_accountCtrl.text);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
    print('login 释放');
    if (_timer != null) {
      _timer.cancel();
    }
  }

  onUnableLoginPress() async {
    NavigatorUtil.pushVC(context, new ForgetPassVC());
  }

  onCodePress() async {
    var mobile = _accountCtrl.text?.trim();
    String deviceId = await UtilsMethodChannel.getDeviceId();
    ResponseModel ret = await HttpManager.instance.post('sendSmsCodeOfLogin',
        params: {'mobile': mobile, 'deviceCode': deviceId});
    if (ret.isSuccess) {
      if (mounted) {
        setState(() {
          _countDown = 120;
        });
      }

      _timer = TimerUtil(mTotalTime: 120 * 1000);
      _timer.setOnTimerTickCallback((int t) {
        if (mounted) {
          setState(() {
            _countDown = (t / 1000).ceil();
          });
        }
      });
      _timer.startCountDown();
    } else {
      if (ret.code == 0) {
        await showAlertDialog(context, '提示', ret.message, cancel: false);
      } else {
        ToastUtil.shortToast(context, ret.message);
      }
    }
  }

  onLoginPress() async {
    String account = _accountCtrl.text?.trim();
    String code = _codeCtrl.text;

    if (isEmpty(account) || isEmpty(code)) {
      ToastUtil.shortToast(context, '请输入帐号或密码');
      return;
    }

    // ToastUtil.showLoading('正在登录...');
    String deviceId = await UtilsMethodChannel.getDeviceId();
    lLog('设备号：$deviceId');
    bool isPhysicalDevice = true;
    var deviceInfo = '';
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await DeviceInfoPlugin().iosInfo;
      isPhysicalDevice = iosInfo?.isPhysicalDevice ?? true;
      deviceInfo =
          '${iosInfo?.name};${iosInfo?.isPhysicalDevice};${iosInfo?.utsname?.nodename};${iosInfo?.utsname?.machine}';
    } else {
      AndroidDeviceInfo android = await DeviceInfoPlugin().androidInfo;
      isPhysicalDevice = android?.isPhysicalDevice ?? true;
      deviceInfo = '${android?.model};${android?.isPhysicalDevice}';
    }
    if (!isPhysicalDevice && Global.inProduction) {
      Toast.hideLoading();
      Toast.showToast('不支持虚拟机登录考勤系统');
      return;
    }
    ResponseModel ret = await HttpManager.instance.post('login2', params: {
      "mobile": account,
      "smsCode": code,
      "deviceCode": deviceId,
      'deviceInfo': deviceInfo
    });

    if (ret.isSuccess) {
      HttpManager.instance.setToken(ret.data['token']);

      JPushManager.instance.setAlias(deviceId + account);

      //获取用户资料
      if (!(await UserManager.instance.requestUser())) {
        ToastUtil.hideLoading();
        ToastUtil.shortToast(context, '获取用户信息失败，请重新再试');
        return;
      }
      ToastUtil.hideLoading();

      Navigator.of(context).pushReplacementNamed(MainpageVC.sName);
    } else {
      ToastUtil.hideLoading();
      ToastUtil.shortToast(context, ret.message);
    }
  }

  //输入变化
  onInputChanged(String changed) {
    setState(() {});
  }

  Widget buildAccountWidget() {
    return new Container(
      margin: EdgeInsets.only(top: 80),
      height: 50,
      child: CupertinoTextField(
        prefix: ImageUtil.image('account_ico.png'),
        clearButtonMode: OverlayVisibilityMode.editing,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        keyboardType: TextInputType.number,
        autocorrect: false,
        obscureText: false,
        placeholder: '请输入手机号',
        controller: _accountCtrl,
        focusNode: _accountFocusNode,
        maxLength: 11,
        onChanged: onInputChanged,
        decoration: BoxDecoration(
          border: Border(
              bottom:
                  BorderSide(width: 0.0, color: Global.themeData.dividerColor)),
        ),
      ),
    );
  }

  Widget buildCode() {
    return Container(
      margin: EdgeInsets.only(top: 30),
      height: 50,
      child: Row(
        children: <Widget>[
          Expanded(
            child: CupertinoTextField(
              prefix: ImageUtil.image('code_ico.png'),
              clearButtonMode: OverlayVisibilityMode.editing,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              keyboardType: TextInputType.number,
              autocorrect: false,
              obscureText: false,
              placeholder: '请输入验证码',
              controller: _codeCtrl,
              focusNode: _codeFocusNode,
              maxLength: 11,
              onChanged: onInputChanged,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 0.0,
                    color: Global.themeData.dividerColor,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 20,
            color: Theme.of(context).dividerColor,
          ),
          Container(
            width: 80,
            height: 40,
            margin: EdgeInsets.only(right: 10, left: 5),
            child: FlatButton(
              onPressed: codeButtonEnable ? onCodePress : null,
              padding: EdgeInsets.zero,
              child: Text(
                _countDown > 0 ? '$_countDown 秒' : '获取验证码',
                style: TextStyle(
                    fontSize: 14,
                    color: codeButtonEnable
                        ? Theme.of(context).accentColor
                        : Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            _accountFocusNode.unfocus();
            _codeFocusNode.unfocus();
          },
          behavior: HitTestBehavior.translucent,
          child: SingleChildScrollView(
            child: Container(
              width: kScreenWidth,
              height: kScreenHeight - kStateBarHeight - kSafeAreaMarginBottom,
              child: Stack(children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 28),
                  margin: EdgeInsets.only(top: 50),
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: ImageUtil.image('login_logo.png'),
                      ),
                      buildAccountWidget(),
                      buildCode(),
                      new Container(
                        margin: EdgeInsets.only(top: 30),
                        width: kScreenWidth - 20,
                        child: newCommonButton(
                            '登 录', loginBtnEnable ? onLoginPress : null),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
