import 'package:unicom_attendance/global.dart';
import 'package:flutter/cupertino.dart';

import 'package:unicom_attendance/controllers/login/forget_pass_vc.dart';

class PersonChangePassVC extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _PersonChangePassVCState();
}

class _PersonChangePassVCState extends State<PersonChangePassVC> {
  final TextEditingController _passController = new TextEditingController();
  final TextEditingController _newPassController = new TextEditingController();
  final TextEditingController _repeatController = new TextEditingController();

  final FocusNode _passNode = new FocusNode();
  final FocusNode _newPassNode = new FocusNode();
  final FocusNode _repeatNode = new FocusNode();

  int _currentStep = 0;

  bool get buttonEnable {
    if ((_currentStep == 0 && isNotEmpty(_passController.text)) ||
        (_currentStep == 1 &&
            isNotEmpty(_newPassController.text) &&
            isNotEmpty(_repeatController.text)) ||
        _currentStep == 2) {
      return true;
    }
    return false;
  }

  String get buttonTitle {
    List titles = ['下一步', '重设', '重新登录'];
    return titles[_currentStep];
  }

  @override
  void initState() {
    super.initState();
  }

  onButtonPress() {
    if (_currentStep == 0) {
      _passNode.unfocus();
      //验证原密码
      HttpManager.instance.post('checkPassword', params: {
        'mobile': UserManager.instance.userModel.mobile,
        'password': '${_passController.text}'
      }).then((ResponseModel ret) {
        if (ret.isSuccess) {
          setState(() {
            _currentStep = 1;
          });
        } else {
          ToastUtil.shortToast(context, ret.message);
        }
      });
    } else if (_currentStep == 1) {
      if (_newPassController.text == _repeatController.text) {
        if (!Global.passwordReg.hasMatch(_newPassController.text)) {
          ToastUtil.shortToast(context, '密码不符合规则');
          return;
        }
        //更换密码
        _newPassNode.unfocus();
        _repeatNode.unfocus();
        //设置密码
        HttpManager.instance.post('submitPasswordOfChangePassword', params: {
          'mobile': UserManager.instance.userModel.mobile,
          'password': '${_newPassController.text}'
        }).then((ResponseModel ret) {
          if (ret.isSuccess) {
            setState(() {
              _currentStep = 2;
            });
          } else {
            ToastUtil.shortToast(context, ret.message);
          }
        });
      } else {
        ToastUtil.shortToast(context, '两次输入的密码不一致');
      }
    } else if (_currentStep == 2) {
      //重新登录
      Global.eventBus.fire(new EventLogout(3));
    }
  }

  onTextFieldChange(String changed) {
    setState(() {});
  }

  Widget buildStepper() {
    List<String> steps = ['验证原密码', '输入新密码', '修改成功'];
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      onChanged: onTextFieldChange,
                      focusNode: _passNode,
                      controller: _passController,
                      obscureText: true,
                      placeholder: '请输入登录账号密码',
                      decoration: BoxDecoration(),
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
              padding: EdgeInsets.only(left: 80),
              child: FlatButton(
                padding: EdgeInsets.all(0),
                onPressed: () {
                  NavigatorUtil.pushVC(context, new ForgetPassVC());
                },
                child: Text(
                  '忘记密码?',
                  style: TextStyle(color: Colors.blue[600]),
                ),
              ),
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
                  child: Text('新密码'),
                ),
                Expanded(
                  child: Container(
                    height: 50,
                    child: CupertinoTextField(
                      maxLines: 1,
                      maxLength: 20,
                      onChanged: onTextFieldChange,
                      controller: _newPassController,
                      focusNode: _newPassNode,
                      obscureText: true,
                      placeholder: '请输入新密码',
                      decoration: BoxDecoration(),
                    ),
                  ),
                )
              ],
            ),
            Divider(
              height: 1,
            ),
            Container(
              width: kScreenWidth,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Text(
                '* 请输入8位以上20位以内数字+字母+字符组合的密码',
                style: TextStyle(color: Color(0xff999999), fontSize: 12),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 88,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 15),
                  child: Text('确认密码'),
                ),
                Expanded(
                  child: Container(
                    height: 50,
                    child: CupertinoTextField(
                      maxLines: 1,
                      maxLength: 20,
                      onChanged: onTextFieldChange,
                      focusNode: _repeatNode,
                      controller: _repeatController,
                      obscureText: true,
                      placeholder: '再次确认新密码',
                      decoration: BoxDecoration(),
                    ),
                  ),
                ),
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
            ImageUtil.image('pass_change_success.png'),
            Container(
              height: 10,
            ),
            Text(
              '修改成功',
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
        appBar: newAppBar(context, '修改密码'),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: GestureDetector(
            onTap: () {
              _passNode.unfocus();
              _repeatNode.unfocus();
              _newPassNode.unfocus();
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
        ));
  }
}
