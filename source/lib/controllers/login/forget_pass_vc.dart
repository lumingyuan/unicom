import 'package:unicom_attendance/global.dart';
import 'package:common_utils/common_utils.dart';

class ForgetPassVC extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ForgetPassVCState();
}

class _ForgetPassVCState extends State<ForgetPassVC> {
  final TextEditingController _passController = new TextEditingController();
  final TextEditingController _repeatController = new TextEditingController();
  final TextEditingController _mobileController = new TextEditingController();
  final TextEditingController _codeController = new TextEditingController();

  final FocusNode _passNode = new FocusNode();
  final FocusNode _repeatNode = new FocusNode();
  final FocusNode _mobileNode = new FocusNode();
  final FocusNode _codeNode = new FocusNode();

  int _currentStep = 0; //0验证步骤， 1设置步骤

  int _countDown = 0;

  String mobile;
  String smsCode;

  bool get codeButtonEnable {
    if (isEmpty(_mobileController.text?.trim())) {
      return false;
    }
    return _countDown == 0;
  }

  bool get buttonEnable {
    if ((_currentStep == 0 &&
            isNotEmpty(_mobileController.text?.trim()) &&
            isNotEmpty(_codeController.text?.trim())) ||
        (_currentStep == 1 &&
            isNotEmpty(_passController.text) &&
            isNotEmpty(_repeatController.text))) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
  }

  onCodePress() async {
    mobile = _mobileController.text?.trim();
    ResponseModel ret = await HttpManager.instance
        .post('sendSmsCodeOfForgetPassword', params: {'mobile': mobile});
    if (ret.isSuccess) {
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
    } else {
      ToastUtil.shortToast(context, ret.message);
    }
  }

  onConfirmPress() async {
    if (_currentStep == 0) {
      _mobileNode.unfocus();
      _codeNode.unfocus();

      mobile = _mobileController.text.trim();
      //校验验证码
      HttpManager.instance.post('confirmSmsCodeOfForgetPassword', params: {
        'smsCode': '${_codeController.text}'
      }).then((ResponseModel ret) {
        if (ret.isSuccess) {
          smsCode = _codeController.text.trim();
          setState(() {
            _currentStep = 1;
          });
        } else {
          ToastUtil.shortToast(context, ret.message);
        }
      });
    } else {
      if (_passController.text == _repeatController.text) {
        if (!Global.passwordReg.hasMatch(_passController.text)) {
          ToastUtil.shortToast(context, '密码不符合规则');
          return;
        }

        //重置密码
        HttpManager.instance.post('submitPasswordOfForgetPassword', params: {
          'smsCode': '$smsCode',
          'mobile': mobile,
          'password': _passController.text
        }).then((ResponseModel ret) {
          if (ret.isSuccess) {
            ToastUtil.shortToast(context, '重设密码成功，请重新登录', true);
            Navigator.maybePop(context);
            Global.eventBus.fire(EventLogout(3));
          } else {
            ToastUtil.shortToast(context, ret.message);
          }
        });
      } else {
        ToastUtil.shortToast(context, '两次输入的密码不一致');
      }
    }
  }

  Widget newTextField(
      String hintText, TextEditingController ctrl, FocusNode node,
      {TextInputType inputType = TextInputType.text,
      bool obscureText = false,
      int maxLength = 20}) {
    return Container(
      height: 50,
      child: new CupertinoTextField(
        style: TextStyle(fontSize: 16, color: Color(0xff303030)),
        controller: ctrl,
        maxLength: maxLength,
        maxLines: 1,
        focusNode: node,
        obscureText: obscureText,
        keyboardType: inputType,
        placeholder: hintText,
        onChanged: (String val) => setState(() {}),
        decoration: BoxDecoration(color: Colors.transparent),
      ),
    );
  }

  Widget buildCodeIfNeed() {
    return _currentStep != 0
        ? Container()
        : Row(children: [
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
                  _countDown > 0 ? '$_countDown 秒' : '发送验证码',
                  style: TextStyle(
                      fontSize: 14,
                      color: codeButtonEnable
                          ? Theme.of(context).accentColor
                          : Colors.grey),
                ),
              ),
            ),
          ]);
  }

  Widget buildContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 15),
              width: 100,
              child: Text(_currentStep == 0 ? '登录账号' : '新密码'),
            ),
            Expanded(
              child: _currentStep == 0
                  ? newTextField('请输入登录帐号', _mobileController, _mobileNode,
                      maxLength: 11, inputType: TextInputType.number)
                  : newTextField('请输入密码', _passController, _passNode,
                      obscureText: true),
            )
          ],
        ),
        Divider(height: 1),
        _currentStep == 0
            ? Container()
            : Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Text(
                  '* 请输入8位以上20位以内数字+字母+字符组合的密码',
                  style: TextStyle(color: Color(0xff999999), fontSize: 12),
                ),
              ),
        Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 15),
              width: 100,
              child: Text(_currentStep == 0 ? '验证码' : '确认密码'),
            ),
            Expanded(
              child: _currentStep == 0
                  ? newTextField('请输入验证码', _codeController, _codeNode,
                      inputType: TextInputType.number)
                  : newTextField('请再次输入密码', _repeatController, _repeatNode,
                      obscureText: true),
            ),
            buildCodeIfNeed()
          ],
        ),
        Divider(height: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: newAppBar(context, '找回密码'),
      body: Material(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.only(top: 20),
          children: <Widget>[
            buildContent(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 50),
              child: newCommonButton(_currentStep == 0 ? '下一步' : '重设密码',
                  buttonEnable ? onConfirmPress : null),
            )
          ],
        ),
      ),
    );
  }
}
