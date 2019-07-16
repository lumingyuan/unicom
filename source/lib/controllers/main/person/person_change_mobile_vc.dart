import 'package:unicom_attendance/global.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';

class PersonChangeMobileVC extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _PersonChangeMobileVCState();
}

class _PersonChangeMobileVCState extends State<PersonChangeMobileVC> {
  final TextEditingController _passController = new TextEditingController();
  final TextEditingController _mobileController = new TextEditingController();
  final TextEditingController _codeController = new TextEditingController();

  final FocusNode _passNode = new FocusNode();
  final FocusNode _mobileNode = new FocusNode();
  final FocusNode _codeNode = new FocusNode();

  int _currentStep = 0;
  int _countDown = 0;

  String _oldPassword;

  bool get codeButtonEnable {
    if (isEmpty(_mobileController.text)) {
      return false;
    }
    return _countDown == 0;
  }

  bool get buttonEnable {
    if ((_currentStep == 0 && isNotEmpty(_passController.text)) ||
        (_currentStep == 1 &&
            isNotEmpty(_mobileController.text) &&
            isNotEmpty(_codeController.text)) ||
        _currentStep == 2) {
      return true;
    }
    return false;
  }

  String get buttonTitle {
    List titles = ['下一步', '更换', '重新登录'];
    return titles[_currentStep];
  }

  @override
  void initState() {
    super.initState();
  }

  onForgetPass() {}

  onButtonPress() {
    if (_currentStep == 0) {
      //验证原密码
      HttpManager.instance.post('checkPassword', params: {
        'mobile': UserManager.instance.userModel.mobile,
        'password': '${_passController.text}'
      }).then((ResponseModel ret) {
        if (ret.isSuccess) {
          _oldPassword = _passController.text;
          setState(() {
            _currentStep = 1;
          });
        } else {
          ToastUtil.shortToast(context, ret.message);
        }
      });
    } else if (_currentStep == 1) {
      //更换手机号
      _mobileNode.unfocus();
      _codeNode.unfocus();
      //校验验证码
      HttpManager.instance.post('submitMobileOfChangeMobile', params: {
        'password': _oldPassword,
        'smsCode': '${_codeController.text}'
      }).then((ResponseModel ret) {
        if (ret.isSuccess) {
          setState(() {
            _currentStep = 2;
          });
        } else {
          ToastUtil.shortToast(context, ret.message);
        }
      });
    } else if (_currentStep == 2) {
      //重新登录
      Global.eventBus.fire(new EventLogout(4));
    }
    setState(() {});
  }

  onCodePress() async {
    ResponseModel ret =
        await HttpManager.instance.post('sendSmsCodeOfChangeMobile', params: {
      'oldMobile': UserManager.instance.userModel.mobile,
      'newMobile': '${_mobileController.text}'
    });
    if (ret.isSuccess) {
      setState(() {
        setState(() {
          _countDown = 60;
        });

        TimerUtil timer = TimerUtil(mTotalTime: 60 * 1000);
        timer.setOnTimerTickCallback((int t) {
          setState(() {
            _countDown = (t / 1000).ceil();
          });
        });
        timer.startCountDown();
      });
    } else {
      ToastUtil.shortToast(context, ret.message);
    }
  }

  onTextFieldChange(String changed) {
    setState(() {});
  }

  Widget buildStepper() {
    List<String> steps = ['验证原密码', '验证新手机', '更换成功'];
    List<Widget> stepWidgets = new List();
    int curStepIndex = _currentStep;
    for (int i = 0; i < steps.length; ++i) {
      bool isFirst = i == 0;
      bool isLast = i == steps.length - 1;
      Color color = Colors.grey;
      String img = "stepper_n.png";
      if (curStepIndex >= i) {
        color = Theme.of(context).accentColor;
        img = "stepper_h.png";
      }
      stepWidgets.add(new Expanded(
        child: Column(
          children: <Widget>[
            Expanded(
                child: Row(children: [
              Expanded(
                flex: 1,
                child: Container(
                  height: isFirst ? 0 : 2,
                  color: color,
                ),
              ),
              ImageUtil.image(img),
              Expanded(
                child: Container(
                  height: isLast ? 0 : 2,
                  color: color,
                ),
              ),
            ])),
            Text(
              '${steps[i]}',
              style: TextStyle(
                  color: curStepIndex == i ? Global.kDefTextColor : Colors.grey,
                  fontSize: 15),
            )
          ],
        ),
      ));
    }
    return Container(
      height: 80,
      width: kScreenWidth,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Row(
        children: stepWidgets,
      ),
    );
  }

  Widget buildContent() {
    Widget content;
    if (_currentStep == 0) {
      // 验证密码
      content = new Container(
        width: kScreenWidth,
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 88,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 15),
                  child: Text('登录密码'),
                ),
                Expanded(
                  child: Container(
                    height: 50,
                    child: CupertinoTextField(
                      maxLines: 1,
                      maxLength: 20,
                      onChanged: onTextFieldChange,
                      focusNode: _passNode,
                      controller: _passController,
                      obscureText: true,
                      style: TextStyle(color: Colors.black87, fontSize: 14),
                      placeholder: '请输入登录账号密码',
                      decoration: BoxDecoration(border: Border()),
                    ),
                  ),
                )
              ],
            ),
            Divider(
              height: 1,
            ),
            Container(
              height: 40,
            )
          ],
        ),
      );
    } else if (_currentStep == 1) {
      //验证新手机
      content = new Container(
        width: kScreenWidth,
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 88,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 15),
                  child: Text('新手机号'),
                ),
                Expanded(
                  child: Container(
                    height: 50,
                    child: CupertinoTextField(
                      maxLines: 1,
                      maxLength: 11,
                      onChanged: onTextFieldChange,
                      controller: _mobileController,
                      focusNode: _mobileNode,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.black87, fontSize: 14),
                      placeholder: '请输入新手机号',
                      decoration: BoxDecoration(
                        border: Border(),
                      ),
                    ),
                  ),
                )
              ],
            ),
            Divider(
              height: 1,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 88,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 15),
                  child: Text('验证码'),
                ),
                Expanded(
                  child: Container(
                    height: 50,
                    child: CupertinoTextField(
                      onChanged: onTextFieldChange,
                      focusNode: _codeNode,
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      placeholder: '请输入验证码',
                      style: TextStyle(color: Colors.black87, fontSize: 14),
                      decoration: BoxDecoration(border: Border()),
                    ),
                  ),
                ),
                Container(
                  width: 80,
                  height: 40,
                  margin: EdgeInsets.only(right: 10, left: 5),
                  child: FlatButton(
                    onPressed: codeButtonEnable ? onCodePress : null,
                    padding: EdgeInsets.zero,
                    child: Text(
                      _countDown > 0 ? '$_countDown 秒' : '发送验证码',
                      style: TextStyle(
                          fontSize: 14,
                          color: codeButtonEnable
                              ? Theme.of(context).accentColor
                              : Colors.grey),
                    ),
                  ),
                )
              ],
            ),
            Divider(
              height: 1,
            ),
          ],
        ),
      );
    } else if (_currentStep == 2) {
      content = Container(
        width: kScreenWidth,
        height: 200,
        child: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ImageUtil.image('mobile_change_success.png'),
            Container(
              height: 10,
            ),
            Text(
              '更换成功',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold),
            )
          ],
        )),
      );
    }

    return Column(
      children: <Widget>[
        content,
        new Container(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 30),
            width: kScreenWidth,
            child: newCommonButton(
                buttonTitle, buttonEnable ? onButtonPress : null)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: newAppBar(context, '更换手机号'),
        backgroundColor: Colors.white,
        body: WillPopScope(
          child: SafeArea(
            child: GestureDetector(
              onTap: () {
                _passNode.unfocus();
                _codeNode.unfocus();
                _mobileNode.unfocus();
              },
              behavior: HitTestBehavior.translucent,
              child: SingleChildScrollView(
                child: Container(
                  width: kScreenWidth,
                  height: kScreenHeight -
                      kStateBarHeight -
                      kToolbarHeight -
                      kSafeAreaMarginBottom,
                  child: Stack(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          buildStepper(),
                          buildContent(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          onWillPop: () async {
            if (_currentStep == 2) {
              //跳到登录页面
              Global.eventBus.fire(new EventLogout(4));
              return false;
            } else {
              return await showAlertDialog(context, '温馨提示', '确定要退出更换手机号吗？');
            }
          },
        ));
  }
}
