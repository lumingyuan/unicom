import 'package:unicom_attendance/global.dart';

class AboutUsVS extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: newAppBar(context, '关于我们'),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(bottom: 30),
              child: ImageUtil.image('login_logo.png',
                  height: 120, width: 120, fit: BoxFit.cover),
            ),
            Text(
                '    联通考勤APP是台州联通（中国联合网络通信有限公司台州市分公司）出品的一站式考勤管理服务平台，为用户提供领先的人脸识别考勤服务，急速响应，告别刷卡。')
          ],
        ),
      ),
    );
  }
}
