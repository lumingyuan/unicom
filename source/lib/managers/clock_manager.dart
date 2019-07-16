import 'dart:async';
import '../models/model.dart';
import './http_manager.dart';
import './user_manager.dart';
import 'package:intl/intl.dart';
import 'package:unicom_attendance/global.dart';
import 'package:jaemobird_permissions/jaemobird_permissions.dart';
import 'package:baidu_location/baidu_location.dart';
import 'package:latlong/latlong.dart';

/// 当前时间打卡状态
///
enum NowClockState {
  NowClockState_Unable, //不能打卡
  NowClockState_BeforeIn, //只能补卡，缺卡状态
  NowClockState_Normal, //能正常打卡
  NowClockState_Late, //迟到卡
  NowClockState_Early, //早退卡
  NowClockState_AfterOut, //在离岗时间之外（算能正常打卡）
}

///
///  打卡管理器，打卡操作和逻辑判断都在本对象中实现，外部只需调用打卡接口
///
class ClockManager {
  static ClockManager _instance = new ClockManager();
  static ClockManager get instance {
    return _instance;
  }

  static const int LOCAL_RESPONSE_CODE = -888;

  /// 当前时间
  DateTime get now {
    int timestamp = DateTime.now().millisecondsSinceEpoch +
        HttpManager.instance.serverTimeDelta;
    DateTime t = new DateTime.fromMillisecondsSinceEpoch(timestamp);
    return t;
  }

  bool isToday(DateTime date) {
    DateTime nowDate = now;
    return nowDate.year == date.year &&
        nowDate.month == date.month &&
        nowDate.day == date.day;
  }

  NowClockState nowClockStateAt(ClockTime time) {
    Schedule setting = UserManager.instance.currentCompanyModel?.schedule;
    if (setting == null) {
      return NowClockState.NowClockState_Unable;
    }
    NowClockState state = NowClockState.NowClockState_Unable;
    DateFormat fmt = new DateFormat('HH:mm');
    int nowMintue = now.hour * 60 + now.minute;
    time.earlyDuration = time.earlyDuration ?? 0;
    DateTime inDate = fmt.parse(time.clockIn);
    DateTime outDate = fmt.parse(time.clockOut);
    int inMinute = inDate.hour * 60 + inDate.minute;
    int outMinute = outDate.hour * 60 + outDate.minute;
    if (nowMintue < (inMinute - time.earlyDuration ?? 0)) {
      //超出早到时间
      state = NowClockState.NowClockState_BeforeIn;
    } else if (nowMintue >= (inMinute - time.earlyDuration) &&
        nowMintue <= (inMinute + setting.lateComputeTime)) {
      //正常
      state = NowClockState.NowClockState_Normal;
    } else if (nowMintue >= (inMinute + setting.lateComputeTime) &&
        nowMintue <= (inMinute + setting.lateDuration)) {
      //迟到
      state = NowClockState.NowClockState_Late;
    } else if (nowMintue >= (inMinute + setting.lateDuration) &&
        nowMintue < outMinute) {
      //早退
      state = NowClockState.NowClockState_Early;
    } else {
      //??
      state = NowClockState.NowClockState_AfterOut;
    }
    return state;
  }

  NowClockState get nowClockState {
    NowClockState state = NowClockState.NowClockState_Unable;
    Schedule setting = UserManager.instance.currentCompanyModel?.schedule;
    do {
      //数据有效性验证
      if (!isToday(now) ||
          setting == null ||
          setting.times == null ||
          setting.times.length == 0) {
        break;
      }
      for (int i = 0; i < setting.times.length; ++i) {
        NowClockState tempState = nowClockStateAt(setting.times[i]);
        if (state == NowClockState.NowClockState_AfterOut &&
            tempState == NowClockState.NowClockState_BeforeIn) {
          //未到下个考勤到岗时间，不继续执行
          break;
        }
        state = tempState;
        if (state != NowClockState.NowClockState_AfterOut) {
          // 在当前打卡时间点内。不继续往下执行。
          break;
        }
      }
      if (state == NowClockState.NowClockState_AfterOut) {
        state = NowClockState.NowClockState_Normal;
      }
    } while (false);
    return state;
  }

  /// 自动打卡
  ///   返回null，不能打卡
  void autoClock() async {
    if (!Setting.autoClock) {
      lLog('没有打卡自动打卡');
      return;
    }

    //登录判断
    if (!UserManager.instance.isLogin) {
      lLog('自动打卡：未登录');
      return;
    }
    // 公司信息判断
    CompanyDataModel company = UserManager.instance.currentCompanyModel;
    if (company == null) {
      lLog('自动打卡：没有基础数据');
      return;
    }
    //时间判断
    NowClockState state = nowClockState;
    if (state != NowClockState.NowClockState_Normal &&
        state != NowClockState.NowClockState_AfterOut) {
      lLog('不允许自动打卡：$state');
      return;
    }

    // 定位判断
    bool hasPermission = await JaemobirdPermissions.checkPermission(
        Permission.WhenInUseLocation);
    // 没有权限不往下执行
    if (!hasPermission) {
      return;
    }
    BaiduLocation loc = await BaiduLocationClient.getLocation();
    if (loc.error != null) {
      lLog('自动打卡：定位失败${loc.error}');
      return;
    }

    //判断地理位置
    bool locEnable = false;
    String addr = "";
    List<ClockLocation> settingLocs =
        UserManager.instance.currentCompanyModel?.schedule?.locations;
    if (settingLocs != null && settingLocs.length > 0) {
      for (int i = 0; i < settingLocs.length; ++i) {
        List latlngStr = settingLocs[i].gps.split(',');
        if (latlngStr?.length == 2) {
          double lat = double.tryParse(latlngStr[0]);
          double long = double.tryParse(latlngStr[1]);
          Distance distance = new Distance();
          double meter = distance.as(LengthUnit.Meter,
              new LatLng(loc.latitude, loc.longitude), new LatLng(lat, long));
          lLog(
              '实际:(${loc.latitude}, ${loc.longitude}), $meter, 设置:($latlngStr), ${settingLocs[i].range}');
          if (meter < settingLocs[i].range) {
            locEnable = true;
            addr = settingLocs[i].address;
            break;
          }
        }
      }
    }
    lLog('地理位置判断：$locEnable');
    if (!locEnable) {
      lLog('自动打卡：当前位置不在考勤打卡范围内');
      return;
    }

    ResponseModel ret = await clock(loc.latitude, loc.longitude,
        isEmpty(addr) ? loc.locationDescribe : addr,
        flag: 1);
    if (ret.isSuccess) {
      DateFormat dft = new DateFormat('HH:mm:ss');
      String timeStr = dft.format(this.now);
      if (state == NowClockState.NowClockState_Normal) {
        ToastUtil.shortToast(null, '签到成功\n$timeStr', true);
      } else {
        ToastUtil.shortToast(null, '签退成功\n$timeStr', true);
      }
    }
  }

  ///返回错误提示语 返回空为位置有效
  Future<String> _checkLocation() async {
    // 定位判断
    bool hasPermission = await JaemobirdPermissions.checkPermission(
        Permission.WhenInUseLocation);
    // 没有权限不往下执行
    if (!hasPermission) {
      return '没有定位权限';
    }
    BaiduLocation loc = await BaiduLocationClient.getLocation();
    if (loc.error != null) {
      return '定位获取失败';
    }

    //判断地理位置
    bool locEnable = false;
    List<ClockLocation> settingLocs =
        UserManager.instance.currentCompanyModel?.schedule?.locations;
    if (settingLocs != null && settingLocs.length > 0) {
      for (int i = 0; i < settingLocs.length; ++i) {
        List latlngStr = settingLocs[i].gps.split(',');
        if (latlngStr?.length == 2) {
          double lat = double.tryParse(latlngStr[0]);
          double long = double.tryParse(latlngStr[1]);
          Distance distance = new Distance();
          double meter = distance.as(LengthUnit.Meter,
              new LatLng(loc.latitude, loc.longitude), new LatLng(lat, long));
          lLog(
              '实际:(${loc.latitude}, ${loc.longitude}), $meter, 设置:($latlngStr), ${settingLocs[i].range}');
          if (meter < settingLocs[i].range) {
            locEnable = true;
            break;
          }
        }
      }
    }
    if (!locEnable) {
      return '当前位置不在考勤打卡范围内';
    }
    return '';
  }

  /// 打卡
  Future<ResponseModel> clock(double latitude, double longitude, String address,
      {int flag = 0, String remark = '', bool checkLocation = false}) async {
    if (checkLocation) {
      //检查地理位置
      String msg = await _checkLocation();
      if (isNotEmpty(msg)) {
        return ResponseModel(-999, msg, null);
      }
    }
    Map<String, dynamic> params = {
      'jobId': UserManager.instance.currentJobId,
      'locationGps': '$latitude,$longitude',
      'locationAddress': '$address',
      'flag': flag,
      'remark': remark,
    };
    return await HttpManager.instance.post('submitClockData', params: params);
  }
}
