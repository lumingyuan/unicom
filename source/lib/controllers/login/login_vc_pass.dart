import 'package:unicom_attendance/global.dart';
import 'package:flutter/cupertino.dart';
import '../main/mainpage_vc.dart';
import './forget_pass_vc.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class LoginVC extends StatefulWidget {
  static final String sName = 'login';

  @override
  State<StatefulWidget> createState() {
    return new _LoginVCState();
  }
}

class _LoginVCState extends State<LoginVC> {
  bool _showPassword = false; //是否显示密码

  final FocusNode _accountFocusNode = new FocusNode();
  final FocusNode _passFocusNode = new FocusNode();
  final TextEditingController _accountCtrl = new TextEditingController();
  final TextEditingController _passCtrl = new TextEditingController();

  bool get loginBtnEnable {
    return isNotEmpty(_passCtrl.text) && isNotEmpty(_accountCtrl.text);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
    print('login 释放');
  }

  onUnableLoginPress() async {
    String id = await UtilsMethodChannel.getDeviceId();
    print('$id');

    NavigatorUtil.pushVC(context, new ForgetPassVC());
  }

  onLoginPress() async {
    String account = _accountCtrl.text?.trim();
    String pass = _passCtrl.text;

    if (isEmpty(account) || isEmpty(pass)) {
      ToastUtil.shortToast(context, '请输入帐号或密码');
      return;
    }

    print('$account, $pass');

    ToastUtil.showLoading('正在登录...');
    String deviceId = await UtilsMethodChannel.getDeviceId();
    lLog('设备号：$deviceId');
    ResponseModel ret = await HttpManager.instance.post('login', params: {
      "mobile": account,
      "password":
          md5.convert(new Utf8Encoder().convert('$pass$account')).toString(),
      "deviceCode": deviceId //deviceId
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

  Widget buildPassWidget() {
    return Container(
      margin: EdgeInsets.only(top: 30),
      height: 50,
      child: CupertinoTextField(
        obscureText: !_showPassword,
        prefix: ImageUtil.image('pass_ico.png'),
        suffix: new IconButton(
          icon: ImageUtil.image(
              _showPassword ? 'open_eye_ico.png' : 'close_eye_ico.png'),
          onPressed: () {
            _showPassword = !_showPassword;
            setState(() {});
          },
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        maxLines: 1,
        maxLength: 20,
        controller: _passCtrl,
        focusNode: _passFocusNode,
        onChanged: onInputChanged,
        placeholder: '密码',
        decoration: BoxDecoration(
          border: Border(
              bottom:
                  BorderSide(width: 0.0, color: Global.themeData.dividerColor)),
        ),
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
            _passFocusNode.unfocus();
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
                      buildPassWidget(),
                      new Container(
                        margin: EdgeInsets.only(top: 30),
                        width: kScreenWidth - 20,
                        child: newCommonButton(
                            '登 录', loginBtnEnable ? onLoginPress : null),
                      ),
                      Container(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FlatButton(
                          padding: EdgeInsets.all(0),
                          onPressed: onUnableLoginPress,
                          child: Text(
                            '无法登录?',
                            style: TextStyle(color: Colors.blue[600]),
                          ),
                        ),
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
