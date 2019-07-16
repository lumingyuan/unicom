import 'package:unicom_attendance/global.dart';
import './home/home_vc.dart';
import './person/person_vc.dart';
import '../login/login_vc.dart';
import './home/approval/approval_detail_vc.dart';

class MainpageVC extends StatefulWidget {
  static final String sName = 'mainpage';

  @override
  State<StatefulWidget> createState() {
    return new _MainpageVCState();
  }
}

class _MainpageVCState extends State<MainpageVC> {
  int _currentIndex = 0;

  StreamSubscription _notifiyEvent;
  StreamSubscription _logoutEvent;

  @override
  void initState() {
    super.initState();

    _logoutEvent =
        Global.eventBus.on<EventLogout>().listen((EventLogout logout) {
      lLog('listen logout reason:${logout.reason}');

      //token置空
      HttpManager.instance.setToken('');

      JPushManager.instance.deleteAlias();

      //重新登录
      Navigator.of(context).pushNamedAndRemoveUntil(
          LoginVC.sName, (Route<dynamic> route) => false);
    });

    _notifiyEvent = Global.eventBus
        .on<EventOpenNotification>()
        .listen((EventOpenNotification event) {
      NavigatorUtil.pushVC(context, new ApprovalDetailVC(event.approvalId));
    });
  }

  @override
  void dispose() {
    super.dispose();
    _notifiyEvent.cancel();
    _logoutEvent.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        key: Global.kMainpageKey,
        body: SafeArea(
          top: false,
          child: IndexedStack(
            children: <Widget>[
              new HomeVC(),
              new PersonVC(),
            ],
            index: _currentIndex,
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          iconSize: 24,
          currentIndex: _currentIndex,
          fixedColor: Global.kTintColor,
          type: BottomNavigationBarType.fixed,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
                icon: ImageIcon(ImageUtil.assetImage('tab_home_ico_n.png')),
                activeIcon:
                    ImageIcon(ImageUtil.assetImage('tab_home_ico_h.png')),
                title: Text('首页', style: TextStyle(fontSize: 10))),
            BottomNavigationBarItem(
                icon: ImageIcon(ImageUtil.assetImage('tab_me_ico_n.png')),
                activeIcon: ImageIcon(ImageUtil.assetImage('tab_me_ico_h.png')),
                title: Text('我的', style: TextStyle(fontSize: 10)))
          ],
        ),
      ),
      onWillPop: () async {
        return false;
      },
    );
  }
}
