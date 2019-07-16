import 'package:unicom_attendance/global.dart';
import './clockin_bottom_view.dart';
import './clockin_top_view.dart';
import './clockin_point_view.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:unicom_attendance/managers/clock_manager.dart';
import '../patch_clockin/patch_clockin_vc.dart';
import './clockin_approval_view.dart';

class ClockinVC extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ClockinVCState();
}

enum PermissionState {
  PermissionState_None,
  PermissionState_Denied, //权限拒绝
  PermissionState_NeverAsk, //询问用户是否允许
  PermissionState_Ok, //允许
}

class _ClockinVCState extends State<ClockinVC> {
  DayClockRecordModel clockRecord;
  DateTime _selectDate;

  bool get bottomViewEnable {
    if (ClockManager.instance.isToday(_selectDate)) {
      List<ClockRecord> records = clockRecord?.clockRecord ?? new List();
      if (records.length > 0) {
        // 如果当天最后一次打卡不是正常状态， 不显示打卡
        if (records.last.state != 0 && records.last.state != 4) {
          return false;
        }
      }
      return true;
    } else {
      return false;
    }
  }

  // 是否外勤打卡
  bool get isInOutworkState {
    if (clockRecord?.approvalRecordsData != null) {
      for (ApprovalRecordsData data in clockRecord.approvalRecordsData) {
        if (data.clockState == 1) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();

    _selectDate = ClockManager.instance.now;

    requestClockRecord();
  }

  @override
  void didUpdateWidget(ClockinVC oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void requestClockRecord() async {
    ToastUtil.showLoading('加载中...');
    ResponseModel ret =
        await HttpManager.instance.post('loadAttendanceRecordByDate', params: {
      'date': DateFormat('yyyy-MM-dd').format(_selectDate),
      'jobId': UserManager.instance.currentJobId
    });
    ToastUtil.hideLoading();
    if (ret.isSuccess) {
      clockRecord = DayClockRecordModel.fromJson(ret.data);
      if (mounted) {
        setState(() {});
      }
    } else {
      clockRecord = null;
      if (mounted) {
        setState(() {});
      }
      ToastUtil.shortToast(context, ret.message);
    }
  }

  ///选择日期
  onDatePress() {
    Picker picker = new Picker(
        height: 150,
        itemExtent: 30,
        hideHeader: false,
        adapter: new DateTimePickerAdapter(
            type: PickerDateTimeType.kYMD,
            yearEnd: _selectDate.year + 1,
            isNumberMonth: true,
            yearSuffix: "年",
            monthSuffix: "月",
            daySuffix: "日"),
        title: new Text("选择日期"),
        confirmText: '确定',
        cancelText: '取消',
        onConfirm: (Picker picker, List value) {
          _selectDate = DateTime.tryParse(picker.adapter.toString());
          setState(() {});
          requestClockRecord();
        },
        onSelect: (Picker picker, int index, List<int> selecteds) {
          print("$index, $selecteds, ${picker.adapter.toString()}");
        });
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: picker.makePicker(),
          );
        });
  }

  //补卡
  onPatchClock(ClockRecord clock) {
    String groupName = this.clockRecord.attendanceGroupName;
    String date = '${this.clockRecord.date} ${clock.settingTime}';
    //跳转到补卡界面
    NavigatorUtil.pushVC(
        context,
        new PatchClockinVC(
          attendanceGroupName: groupName,
          clockTime: date,
        ));
  }

  // 获取当前工作状态，返回1为请假  2为外勤 0为正常
  int getWorkStateWithClockRecord(ClockRecord clock) {
    if (this.clockRecord?.approvalRecordsData != null) {
      for (ApprovalRecordsData record in this.clockRecord.approvalRecordsData) {
        DateFormat dft = new DateFormat('yyyy-MM-dd HH:mm');
        DateTime begin = dft.parse(record.beginTime);
        DateTime end = dft.parse(record.endTime);
        DateTime now =
            dft.parse('${this.clockRecord.date} ${clock.settingTime}');
        if (record.unitType == 1) {
          end = end.add(Duration(hours: 12));
        }
        if (now.isAfter(begin) && now.isBefore(end)) {
          return record.approvalType.contains('请假') ? 1 : 2;
        }
      }
    }
    return 0;
  }

  ///更新打卡
  onUpdateClock() async {
    Global.eventBus.fire(new EventUpdateClock());
  }

  Widget buildContent() {
    if (this.clockRecord != null &&
        isNotEmpty(this.clockRecord.attendanceGroupName) &&
        this.clockRecord.clockRecord != null &&
        this.clockRecord.clockRecord.length > 0 &&
        this.clockRecord.dayType == 1) {
      List<Widget> widgets = new List();
      widgets.add(new Container(
          child: Text('打卡记录时间和位置'),
          padding: EdgeInsets.only(top: 20, bottom: 10)));

      //申请记录
      if (this.clockRecord != null &&
          this.clockRecord.approvalRecordsData != null) {
        for (ApprovalRecordsData record
            in this.clockRecord?.approvalRecordsData) {
          widgets.add(new ClockinApprovalView(record));
        }
      }

      int count = this.clockRecord.clockRecord.length;
      for (int i = 0; i < count; ++i) {
        widgets.add(new ClockinPointView(
          _selectDate,
          this.clockRecord.clockRecord[i],
          isFirstPoint: i == 0,
          isEndPoint: i == count - 1,
          onPatchClock: () {
            onPatchClock(this.clockRecord.clockRecord[i]);
          },
          onUpdateClock: onUpdateClock,
          workState:
              getWorkStateWithClockRecord(this.clockRecord.clockRecord[i]),
        ));
      }
      return ListView(
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 100),
        children: widgets,
      );
    } else {
      String txt = '未加入考勤组';
      if (this.clockRecord != null &&
          isNotEmpty(this.clockRecord.attendanceGroupName)) {
        //有考勤组，但没有打卡数据
        txt = '无考勤记录';
      } else if (this.clockRecord?.dayType == 0) {
        txt = '今天你休息～';
      }
      return Container(
        margin: EdgeInsets.only(top: 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ImageUtil.image('no_data.png'),
            Text(
              '$txt',
              style: TextStyle(color: Color(0xff696969), fontSize: 20),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    CompanyDataModel company = UserManager.instance.currentCompanyModel;
    return Scaffold(
      appBar: newAppBar(context, '${company?.companyName ?? ""}', elevation: 0),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                ClockinTopView(
                    new DateFormat('yyyy-MM-dd').format(_selectDate),
                    UserManager.instance.userModel?.name ?? "",
                    clockRecord?.attendanceGroupName ?? "无",
                    onDatePress),
                Expanded(
                  child: buildContent(),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Offstage(
                offstage: !bottomViewEnable,
                child: ClockinBottomView(() {
                  requestClockRecord();
                }, isInOutworkState),
              ),
            )
          ],
        ),
      ),
    );
  }
}
