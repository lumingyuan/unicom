import 'package:unicom_attendance/global.dart';

import './person_info_vc.dart';
import './person_setting_vc.dart';
import './face_recognition_vc.dart';
import 'car_manager_vc.dart';

class PersonVC extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _PersonVCState();
  }
}

class _PersonVCState extends State<PersonVC> {
  StreamSubscription<EventCompanyChanged> companyListener;
  StreamSubscription<UserChangedEvent> userListener;

  @override
  void initState() {
    super.initState();

    companyListener = Global.eventBus
        .on<EventCompanyChanged>()
        .listen((EventCompanyChanged companyChanged) {
      lLog('listen EventCompanyChanged:${companyChanged.jobId}');
      //刷新
      if (mounted) {
        setState(() {});
      }
    });

    userListener =
        Global.eventBus.on<UserChangedEvent>().listen((UserChangedEvent event) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  dispose() {
    super.dispose();

    companyListener.cancel();
    userListener.cancel();

    print('person_vc 释放');
  }

  buildUserWidget() {
    UserModel user = UserManager.instance.userModel;
    return AspectRatio(
      aspectRatio: 750 / 320,
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ImageUtil.image('person_head_bg.png', fit: BoxFit.fill),
              ),
              Positioned(
                left: 15,
                top: 30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('${user?.name ?? "未设置"}',
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                    Container(height: 8),
                    Text(
                        '${UserManager.instance.currentCompanyModel?.companyName ?? ""}',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ],
                ),
              ),
              Positioned(
                right: 15,
                top: 30,
                child: Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.white,
                          offset: Offset(-0.5, -0.5),
                          spreadRadius: 0,
                          blurRadius: 3),
                      BoxShadow(
                          color: Colors.white,
                          offset: Offset(0.5, 0.5),
                          spreadRadius: 0,
                          blurRadius: 3),
                    ],
                  ),
                  child: ClipOval(
                    child: ImageUtil.imageFromUrl(
                        '${Global.appDomain}${user?.logo}',
                        placeholder:
                            ImageUtil.image('def_head.png', fit: BoxFit.fill)),
                  ),
                ),
              )
            ],
          )),
    );
  }

  Widget buildCell(Image icon, String title, VoidCallback onPressed) {
    return MyListTile(
      Container(
        child: Text('$title',
            style: TextStyle(fontSize: 17, color: Color(0xff696969))),
        margin: EdgeInsets.only(left: 15),
      ),
      leading: icon,
      hasForward: true,
      onPressed: onPressed,
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: AppBar(
          brightness: Brightness.light,
          elevation: 0,
        ),
      ),
      body: Column(
        children: <Widget>[
          buildUserWidget(),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(top: 20),
              color: Global.kBackgroundColor,
              child: ListView(
                children: <Widget>[
                  Divider(height: 1),
                  buildCell(ImageUtil.image('person_info_ico.png'), '我的信息', () {
                    NavigatorUtil.pushVC(context, new PersonInfoVC());
                  }),
                  Container(
                      height: 0.5,
                      color: Global.themeData.dividerColor,
                      margin: EdgeInsets.only(left: 15)),
                  buildCell(ImageUtil.image('person_face_ico.png'), '人脸打卡照片管理',
                      () {
                    NavigatorUtil.pushVC(context, new FaceRecognitionVC());
                  }),
                  Container(
                      height: 0.5,
                      color: Global.themeData.dividerColor,
                      margin: EdgeInsets.only(left: 15)),
                  buildCell(ImageUtil.image('person_car_ico.png'), '车牌管理', () {
                    NavigatorUtil.pushVC(context, new CarManagerVC());
                  }),
                  Container(
                      height: 0.5,
                      color: Global.themeData.dividerColor,
                      margin: EdgeInsets.only(left: 15)),
                  buildCell(ImageUtil.image('person_setting_ico.png'), '设置',
                      () {
                    NavigatorUtil.pushVC(context, new PersonSettingVC());
                  }),
                  Divider(height: 1),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
