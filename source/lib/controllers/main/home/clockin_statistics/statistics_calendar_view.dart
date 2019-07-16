import 'package:unicom_attendance/global.dart';
import 'package:flutter_picker/flutter_picker.dart';
import '../clockin/clockin_point_view.dart';
import '../patch_clockin/patch_clockin_vc.dart';
import 'package:date_utils/date_utils.dart';
import '../clockin/clockin_approval_view.dart';
import './statistics_list_cell.dart';

class StatisticsCalendarView extends StatefulWidget {
  final bool patchClockFlag; //从补卡申请界面进入标识，默认false
  final DateTime date;
  StatisticsCalendarView(this.date, [this.patchClockFlag = false]);

  @override
  State<StatefulWidget> createState() => new _StatisticsCalendarViewState();
}

class _StatisticsCalendarViewState extends State<StatisticsCalendarView>
    with AutomaticKeepAliveClientMixin {
  DateTime _selectedDate;
  DayClockRecordModel clockRecord;
  List<DayStateModel> dayStates;
  StreamSubscription _dateClickEvent;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.date;
    requestClockRecord();
    requestMonthDayState();

    _dateClickEvent = Global.eventBus
        .on<EventStatisticsDateClick>()
        .listen((EventStatisticsDateClick event) {
      if (event.date != null) {
        lLog('${event.date}');
        onDateUpdated(event.date);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_dateClickEvent != null) {
      _dateClickEvent.cancel();
    }
  }

  void requestClockRecord() async {
    ResponseModel ret =
        await HttpManager.instance.post('loadAttendanceRecordByDate', params: {
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'jobId': UserManager.instance.currentJobId
    });
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
    }
  }

  void requestMonthDayState() async {
    ResponseModel ret = await HttpManager.instance
        .post('loadAttendanceRecordDataOfMonth', params: {
      'month': DateFormat('yyyy-MM').format(_selectedDate),
      'jobId': UserManager.instance.currentJobId,
      'lackType': widget.patchClockFlag ? 1 : 0
    });
    if (ret.isSuccess) {
      dayStates = getDayStateModelList(ret.data);
      if (mounted) {
        setState(() {});
      }
    } else {
      dayStates = null;
      if (mounted) {
        setState(() {});
      }
    }
  }

  onDateUpdated(DateTime newDate) {
    bool updateState = (newDate.year != _selectedDate?.year ||
        newDate.month != _selectedDate.month);
    if (mounted) {
      setState(() {
        _selectedDate = newDate;
      });
    }
    requestClockRecord();
    if (updateState) {
      requestMonthDayState();
    }
  }

  ///选择日期
  onDatePress() {
    Picker picker = new Picker(
        height: 150,
        itemExtent: 30,
        hideHeader: false,
        adapter: new DateTimePickerAdapter(
            type: PickerDateTimeType.kYM,
            yearEnd: ClockManager.instance.now.year + 1,
            isNumberMonth: true,
            yearSuffix: "年",
            monthSuffix: "月"),
        title: new Text("选择年月"),
        confirmText: '确定',
        cancelText: '取消',
        onConfirm: (Picker picker, List value) {
          DateTime t = DateTime.tryParse(picker.adapter.toString());
          onDateUpdated(t);
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

  Widget buildDatePopupMenu() {
    DateFormat fmt = new DateFormat('yyyy年MM月');
    return Container(
      width: kScreenWidth,
      margin: EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          color: Color(0xfff0f0f0),
          offset: Offset(0, 1),
          blurRadius: 0.5,
        )
      ]),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FlatButton(
            onPressed: onDatePress,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('${fmt.format(this._selectedDate)}',
                    style: TextStyle(fontSize: 16, color: Global.kTintColor)),
                Container(width: 8),
                ImageUtil.image('expand_more.png')
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildPatchTitle() {
    return Container(
      height: 60,
      width: kScreenWidth,
      padding: EdgeInsets.only(left: 15),
      color: Colors.lightBlue[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 30,
            alignment: Alignment.bottomLeft,
            child: Text('考勤组：${(this.clockRecord?.attendanceGroupName) ?? ""}',
                style: TextStyle(fontSize: 15)),
          ),
          Container(
            height: 20,
            alignment: Alignment.centerLeft,
            child: Text('考勤事件: 09:00-11:00 13:00-16:30',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          )
        ],
      ),
    );
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
      if (this.clockRecord?.approvalRecordsData != null) {
        for (ApprovalRecordsData record
            in this.clockRecord.approvalRecordsData) {
          widgets.add(new ClockinApprovalView(record));
        }
      }

      int count = this.clockRecord.clockRecord.length;
      for (int i = 0; i < count; ++i) {
        widgets.add(new ClockinPointView(
          _selectedDate,
          this.clockRecord.clockRecord[i],
          isFirstPoint: i == 0,
          isEndPoint: i == count - 1,
          workState:
              getWorkStateWithClockRecord(this.clockRecord.clockRecord[i]),
          onPatchClock: () {
            //补卡
            String groupName = this.clockRecord.attendanceGroupName;
            String date =
                '${this.clockRecord.date} ${this.clockRecord.clockRecord[i].settingTime}';
            if (widget.patchClockFlag) {
              //返回时间，并退出
              Map data = {'date': date, 'groupName': groupName};
              Navigator.of(context).pop(data);
            } else {
              //跳转到补卡界面
              NavigatorUtil.pushVC(
                  context,
                  new PatchClockinVC(
                    attendanceGroupName: groupName,
                    clockTime: date,
                  ));
            }
          },
          onUpdateClock: null,
        ));
      }
      return ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
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
        margin: EdgeInsets.only(top: 100, bottom: 150),
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

  //日期选择事件
  onDateTimePicked(DateTime date) {
    print('$date');
    bool update =
        date.year != _selectedDate?.year || date.month != _selectedDate.month;
    setState(() {
      _selectedDate = date;
    });
    if (update) {
      requestMonthDayState();
    }
    requestClockRecord();
  }

  int dayOfState(DateTime day) {
    int state = 0;
    if (dayStates != null && dayStates.length > 0) {
      for (DayStateModel record in dayStates) {
        DateTime t = DateFormat('yyyy-MM-dd').parse(record.date);
        if (Utils.isSameDay(day, t)) {
          state = record.state == 0 ? 2 : 1;
          break;
        }
      }
    }
    return state;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: ListView(
        children: <Widget>[
          buildDatePopupMenu(),
          new CalendarPicker(
            initialCalendarDateOverride: _selectedDate,
            onDateSelected: onDateTimePicked,
            showPoint: true,
            stateFunc: dayOfState,
          ),
          //buildPatchTitle(),
          buildContent(),
        ],
      ),
    );
  }
}
