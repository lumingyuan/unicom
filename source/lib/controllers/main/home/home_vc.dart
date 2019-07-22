import 'package:unicom_attendance/controllers/main/home/qr_code/qr_code_vc.dart';
import 'package:unicom_attendance/global.dart';

import './patch_clockin/patch_clockin_vc.dart';
import './clockin/clockin_vc.dart';
import './leave/leave_vc.dart';
import './approval/approval_vc.dart';
import './clockin_statistics/clockin_statistics_vc.dart';
import './approval/apply_record_vc.dart';
import './travel_outwork/travel_or_outwork_vc.dart';

class HomeVC extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _HomeVCState();
  }
}

class FuncParams {
  int tag;
  String title;
  Image icon;
  bool showNew;
  int badgeNum;
  FuncParams(this.title, this.icon, this.tag,
      {this.badgeNum = 0, this.showNew = false});
}

class _HomeVCState extends State<HomeVC> with WidgetsBindingObserver {
  final List<FuncParams> funcParams = [
    new FuncParams('考勤打卡', ImageUtil.image('home_clock_ico.png'), 0,
        showNew: false),
    new FuncParams('考勤统计', ImageUtil.image('home_statistics_ico.png'), 1,
        showNew: false),
    new FuncParams('申请记录', ImageUtil.image('home_apply_ico.png'), 2),
    new FuncParams('审批', ImageUtil.image('home_approval_ico.png'), 3),
    new FuncParams('补卡', ImageUtil.image('home_patch_ico.png'), 4),
    new FuncParams('请假', ImageUtil.image('home_leave_ico.png'), 5),
    new FuncParams('出差', ImageUtil.image('home_travel_ico.png'), 6),
    new FuncParams('外出', ImageUtil.image('home_outwork_ico.png'), 7),
    new FuncParams('一码通', ImageUtil.image('home_qrcode_ico.png'), 8),
  ];

  StreamSubscription _baseEvent;

  /// 其他企业是否有通知
  bool get hasCompanyNotify {
    List<CompanyDataModel> companys =
        UserManager.instance.userModel.companys ?? new List();
    if (companys.length > 0) {
      for (int i = 0; i < companys.length; ++i) {
        if (companys[i].jobId != Setting.currentJobId) {
          if (companys[i].unapproveRecordCount > 0 ||
              companys[i].approvalRecordCount > 0) {
            return true;
          }
        }
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _baseEvent = Global.eventBus
        .on<EventCompanyChanged>()
        .listen((EventCompanyChanged companyChanged) {
      lLog('listen EventCompanyChanged:${companyChanged.jobId}');
      //刷新
      if (mounted) {
        setState(() {});
      }
    });

    Global.eventBus.on<EventUpdateBaseData>().listen((event) {
      requestBaseData();
    });

    requestBaseData().then((_) {
      ClockManager.instance.autoClock();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();

    _baseEvent.cancel();
  }

  /// app前后台切换事件
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      requestBaseData().then((_) {
        //自动打卡
        ClockManager.instance.autoClock();
      });
    }
    lLog('$state');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    lLog('home didChangeDependencies');
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    lLog('home didUpdateWidget');
  }

  //请求基础数据
  Future<Null> requestBaseData() async {
    ResponseModel ret = await HttpManager.instance.post('loadBaseData',
        params: isNotEmpty(Setting.numUpdateTime)
            ? {'updateTime': Setting.numUpdateTime}
            : null);
    if (ret.isSuccess) {
      List<CompanyDataModel> companys = getCompanyDataModelList(ret.data);
      if (companys != null) {
        UserManager.instance.userModel.companys = companys;
        UserManager.instance.update();

        if (mounted) {
          setState(() {});
        }
      }
    } else {
      ToastUtil.shortToast(context, ret.message);
    }
  }

  onFuncPress(int tag) async {
    switch (tag) {
      case 0: //打卡
        NavigatorUtil.pushVC(context, new ClockinVC());
        break;
      case 1: //统计
        NavigatorUtil.pushVC(context, new ClockinStatisticsVC());
        break;
      case 2: //申请记录
        NavigatorUtil.pushVC(context, new ApplyRecordVC());
        break;
      case 3: //审批
        NavigatorUtil.pushVC(context, new ApprovalVC());
        break;
      case 4: //补卡
        if (UserManager.instance.currentCompanyModel.clockApprovalId > 0) {
          NavigatorUtil.pushVC(context, new PatchClockinVC());
        } else {
          ToastUtil.shortToast(context, '所在考勤组未开通该功能，请联系管理员');
        }
        break;
      case 5: //请假
        if (UserManager.instance.currentCompanyModel.leavelApprovalId > 0) {
          NavigatorUtil.pushVC(context, new LeaveVC());
        } else {
          ToastUtil.shortToast(context, '所在考勤组未开通该功能，请联系管理员');
        }
        break;
      case 6: //出差
        if (UserManager.instance.currentCompanyModel.travelApprovalId > 0) {
          NavigatorUtil.pushVC(context, new TravelOrOutworkVC(true));
        } else {
          ToastUtil.shortToast(context, '所在考勤组未开通该功能，请联系管理员');
        }
        break;
      case 7: //外出
        if (UserManager.instance.currentCompanyModel.outApprovalId > 0) {
          NavigatorUtil.pushVC(context, new TravelOrOutworkVC(false));
        } else {
          ToastUtil.shortToast(context, '所在考勤组未开通该功能，请联系管理员');
        }
        break;
      case 8: //一码通
        NavigatorUtil.pushVC(context, new QRCodeVC());
        break;
      default:
        break;
    }
  }

  // 公司列表选择
  onCompanySelected(int companyId) {
    Setting.currentJobId = companyId;
    Setting.saveInt(Setting.kCurrentJobId, Setting.currentJobId);
    Global.eventBus.fire(new EventCompanyChanged(companyId));
  }

  Widget buildTitle() {
    List<CompanyDataModel> companys =
        UserManager.instance.userModel.companys ?? new List();

    Widget companyWidget = Container(
      height: kToolbarHeight,
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: <Widget>[
          Text('${UserManager.instance.currentCompanyModel?.companyName ?? ""}',
              style: TextStyle(fontSize: 20, color: Colors.black87)),
          Offstage(
            offstage: companys.length <= 1,
            child: Icon(
              Icons.expand_more,
              color: Colors.black87,
              size: 30,
            ),
          ),
        ],
      ),
    );
    return Material(
        color: Colors.white,
        child: Container(
          child: Row(
            children: <Widget>[
              companys.length > 1
                  ? PopupMenuButton<int>(
                      child: companyWidget,
                      offset: Offset(0, kToolbarHeight),
                      itemBuilder: (context) {
                        List<PopupMenuItem<int>> items = new List();
                        if (companys.length > 0) {
                          for (int i = 0; i < companys.length; ++i) {
                            items.add(new PopupMenuItem<int>(
                                value: companys[i].jobId,
                                child: ListTile(
                                  title: Text('${companys[i].companyName}'),
                                )));
                          }
                        }
                        return items;
                      },
                      onSelected: onCompanySelected,
                    )
                  : companyWidget,
              Offstage(
                offstage: !hasCompanyNotify,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    border: Border.all(color: Colors.white, width: 1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '其他企业有通知',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Widget insertBadgeIfNeed(Widget content, FuncParams param) {
    if (!param.showNew && (param.badgeNum ?? 0) > 0) {
      return Badge(
        value: '${param.badgeNum}',
        borderSize: 0,
        textStyle: TextStyle(fontSize: 12, color: Colors.white),
        minSize: 15,
        positionRight: -6,
        positionTop: -8,
        child: content,
      );
    }
    return content;
  }

  Widget buildFuncWidget(FuncParams param, Size size) {
    return InkWell(
      child: Container(
        width: size.width,
        height: size.height,
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 8),
              child: insertBadgeIfNeed(
                  Stack(overflow: Overflow.visible, children: [
                    Container(
                      child: param.icon,
                    ),
                    Positioned(
                      right: -12,
                      top: -8,
                      child: param.showNew
                          ? ImageUtil.image('badge_new.png')
                          : Container(),
                    ),
                  ]),
                  param),
            ),
            Container(height: 8),
            Text('${param.title}'),
          ],
        ),
      ),
      onTap: () {
        print('${param.title}_${param.tag}');
        onFuncPress(param.tag);
      },
    );
  }

  Widget buildContent() {
    double itemWidth = kScreenWidth / 4;
    double itemHeight = itemWidth;

    CompanyDataModel model = UserManager.instance.currentCompanyModel;
    if (model != null) {
      funcParams[2].badgeNum = model.approvalRecordCount;
      funcParams[3].badgeNum = model.unapproveRecordCount;
    }

    return Material(
      color: Colors.white,
      child: Container(
        child: RefreshIndicator(
          onRefresh: requestBaseData,
          child: ListView(
            children: <Widget>[
              Container(
                width: kScreenWidth,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                child: AspectRatio(
                  aspectRatio: 698 / 209,
                  child: ImageUtil.image('home_head_bg.png', fit: BoxFit.fill),
                ),
              ),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                childAspectRatio: itemWidth / itemHeight,
                children: funcParams.map((FuncParams item) {
                  return buildFuncWidget(item, Size(itemWidth, itemHeight));
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: buildTitle(),
        titleSpacing: 0,
        elevation: 0.5,
        brightness: Brightness.light,
      ),
      body: buildContent(),
    );
  }
}
