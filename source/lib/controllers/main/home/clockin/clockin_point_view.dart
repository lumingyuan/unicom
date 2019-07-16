import 'package:unicom_attendance/global.dart';
import 'package:unicom_attendance/managers/clock_manager.dart';

class ClockinPointView extends StatelessWidget {
  final bool isFirstPoint; //是否是第一个结点
  final bool isEndPoint; //是否是最后一个结点
  final int workState; //0正常 1请假 2外勤

  final Color lineColor = Colors.grey;

  final ClockRecord recordModel;
  final DateTime date;

  final VoidCallback onUpdateClock;
  final VoidCallback onPatchClock;

  ClockinPointView(
    this.date,
    this.recordModel, {
    this.isEndPoint = false,
    this.isFirstPoint = false,
    this.onPatchClock,
    this.onUpdateClock,
    this.workState = 0,
  });

  Color get pointColor {
    return isCurrentPoint ? Global.kTintColor : lineColor;
  }

  //是否是当前打卡结点
  bool get isCurrentPoint {
    if (ClockManager.instance.isToday(date) && this.recordModel != null) {
      Schedule setting = UserManager.instance.currentCompanyModel?.schedule;
      if (setting == null) {
        return false;
      }
      NowClockState state = NowClockState.NowClockState_Unable;
      int index = 0;
      for (int i = 0; i < setting.times.length; ++i) {
        ClockTime time = setting.times[i];
        if (recordModel.type == 0 && recordModel.settingTime == time.clockIn ||
            recordModel.type == 1 && recordModel.settingTime == time.clockOut) {
          index = i;
          state = ClockManager.instance.nowClockStateAt(time);
          break;
        }
      }
      if (recordModel.type == 0) {
        //到岗结点
        if (state == NowClockState.NowClockState_Normal ||
            state == NowClockState.NowClockState_Late) {
          return true;
        }
      }
      if (recordModel.type == 1) {
        //离岗结点
        if (state == NowClockState.NowClockState_Early) {
          return true;
        } else if (state == NowClockState.NowClockState_AfterOut) {
          // 判断是否进入下个上班打卡时间
          if (index == setting.times.length - 1) {
            return true;
          }
          if (index + 1 < setting.times.length) {
            NowClockState nextState =
                ClockManager.instance.nowClockStateAt(setting.times[index + 1]);
            if (nextState == NowClockState.NowClockState_BeforeIn) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  //是否过了打卡时间的结点
  bool get isPassPoint {
    DateTime now = ClockManager.instance.now;
    if (date.millisecondsSinceEpoch <
        (new DateTime(now.year, now.month, now.day)).millisecondsSinceEpoch) {
      return true;
    }

    if (recordModel.state != 0) {
      return true;
    } else {
      if (!isCurrentPoint) {
        int nowMinute = now.hour * 60 + now.minute;
        DateTime point = new DateFormat('HH:mm').parse(recordModel.settingTime);
        if (nowMinute > (point.minute + point.hour * 60)) {
          return true;
        }
      }
    }
    return false;
  }

  String get time {
    String str = '';
    if (recordModel != null) {
      str = recordModel.type == 0 ? "上班时间：" : "下班时间：";
      if (isNotEmpty(recordModel.settingTime)) {
        DateTime date = DateFormat('HH:mm').parse(recordModel.settingTime);
        str += DateFormat('HH:mm').format(date);
      }
    }
    return str;
  }

  String get clockTime {
    String str = '打卡时间 ';
    if (isNotEmpty(recordModel?.clockTime)) {
      DateTime date = DateFormat('HH:mm:ss').parse(recordModel.clockTime);
      str += DateFormat('HH:mm').format(date);
    } else if (recordModel?.state == 0) {
      str += '未打卡';
    } else if (recordModel?.state == 4) {
      str = '';
    }
    return str;
  }

  void onRemarkPress() async {
    ResponseModel ret = await HttpManager.instance.post('loadClockRecordRemark',
        params: {'clockRecordId': recordModel.clockRecordId});
    if (ret.isSuccess) {
      showAlertDialog(
          Global.kMainpageKey.currentContext, '打卡备注', ret.data['remark'],
          cancel: false);
    }
  }

  List<Widget> buildStateRowWidgets() {
    List<Widget> widgets = new List();

    int state = recordModel?.state;
    if (state == 4) {
      // 当前结点处于审核状态（出差、请假等） 不显示
      return widgets;
    } else {
      /// 打卡状态（0：缺卡；1：正常；2：迟到；3：早退）
      String stateImg;
      if (recordModel?.flag == 3) {
        stateImg = 'state_outwork.png';
      } else {
        List<String> states = [
          "state_lack.png",
          'state_normal.png',
          'state_late.png',
          'state_early.png'
        ];
        if (state >= 0 && state < states.length) {
          stateImg = states[state];
        }
      }
      if (isNotEmpty(stateImg)) {
        widgets.add(ImageUtil.image(stateImg));
      }

      if (isPassPoint && state != 1 && !isCurrentPoint) {
        //申请补卡
        widgets.add(
          SizedBox(
            width: 68,
            child: new FlatButton(
              padding: EdgeInsets.all(0),
              textColor: Global.kTintColor,
              child: Text('申请补卡', style: TextStyle(fontSize: 13)),
              onPressed: onPatchClock,
            ),
          ),
        );
      }

      if (recordModel?.clockRecordId != null &&
          recordModel?.clockRecordId != 0) {
        //查看备注
        widgets.add(
          SizedBox(
            width: 68,
            child: new FlatButton(
              padding: EdgeInsets.all(0),
              textColor: Global.kTintColor,
              child: Text('查看备注', style: TextStyle(fontSize: 13)),
              onPressed: onRemarkPress,
            ),
          ),
        );
      }

      if (isCurrentPoint &&
          ((state == 3 || state == 1) && recordModel.type == 1)) {
        //更新打卡
        widgets.add(
          SizedBox(
              width: 68,
              child: new FlatButton(
                padding: EdgeInsets.all(0),
                textColor: Global.kTintColor,
                child: Text(
                  '更新打卡',
                  style: TextStyle(fontSize: 13),
                ),
                onPressed: onUpdateClock,
              )),
        );
      }
      return widgets;
    }
  }

  Widget buildLine() {
    return Column(
      children: <Widget>[
        Container(
          width: isFirstPoint ? 0 : 1.0,
          height: 10,
          color: lineColor,
        ),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: pointColor),
        ),
        Expanded(
          child: Container(
            width: isEndPoint ? 0 : 1.0,
            color: lineColor,
          ),
        )
      ],
    );
  }

  // 打卡类型 0手动打卡  1自动打卡 2无感打卡 3外勤打卡 4车牌打卡 5闸机打卡
  Widget buildClockType() {
    bool offstage = recordModel?.flag == 0 || recordModel?.flag == null;
    String text = '';
    if (recordModel?.flag == 1) {
      text = '自动打卡';
    } else if (recordModel?.flag == 2) {
      text = '无感打卡';
    } else if (recordModel?.flag == 3) {
      text = '外勤打卡';
    } else if (recordModel?.flag == 4) {
      text = '车牌打卡';
    } else if (recordModel?.flag == 5) {
      text = '闸机打卡';
    }
    return Offstage(
      offstage: offstage,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          border: Border.all(color: Global.kTintColor),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          '$text',
          style: TextStyle(
            fontSize: 12,
            color: Global.kTintColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        PositionedDirectional(
          top: 0,
          bottom: 0,
          child: SizedBox(width: 40.0, child: buildLine()),
        ),
        Container(
          margin: const EdgeInsetsDirectional.only(start: 40, end: 10, top: 5),
          constraints: BoxConstraints(minHeight: 116),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Row(
                  children: <Widget>[
                    Text('$time'),
                    Container(width: 10),
                    buildClockType(),
                    Container(width: 10),
                    Offstage(
                      offstage: workState == 0,
                      child: ImageUtil.image(workState == 1
                          ? 'state_leave.png'
                          : 'state_outwork.png'),
                    ),
                  ],
                ),
              ),
              Offstage(
                offstage: !isPassPoint,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        '$clockTime',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Offstage(
                      offstage: isEmpty(recordModel?.locationAddress),
                      child: Container(
                        margin: EdgeInsets.only(top: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(right: 5, top: 3),
                              child: ImageUtil.image('loc_grey_ico.png'),
                            ),
                            Expanded(
                              child: Text('${recordModel?.locationAddress}'),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 6),
                      height: 24,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: buildStateRowWidgets(),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
