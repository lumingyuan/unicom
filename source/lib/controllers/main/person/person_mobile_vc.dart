import 'package:unicom_attendance/global.dart';
import './person_change_mobile_vc.dart';

class PersonMobileVC extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _PersonMobileVCState();
}

class _PersonMobileVCState extends State<PersonMobileVC> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: newAppBar(context, '手机号'),
      body: Container(
        color: Global.kBackgroundColor,
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('当前绑定手机号：',
                      style: TextStyle(color: Colors.grey, fontSize: 15)),
                  Container(
                    height: 10,
                  ),
                  Text('18806869807',
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 24,
                          fontWeight: FontWeight.w700)),
                  Container(
                    height: 20,
                  ),
                  Text('更换手机号后，登录手机号和企业信息中的号码均改变',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Container(
                    height: 30,
                  ),
                ],
              ),
            ),
            new Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              width: kScreenWidth - 20,
              height: 40,
              child: new RaisedButton(
                onPressed: () {
                  NavigatorUtil.pushVC(context, new PersonChangeMobileVC());
                },
                disabledColor: Color(0xffc5c5c5),
                color: Global.kTintColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '更换手机号',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
