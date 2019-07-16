import 'package:unicom_attendance/global.dart';
import 'package:latlong/latlong.dart';
import 'package:baidu_location/baidu_location.dart';
import 'package:jaemobird_permissions/jaemobird_permissions.dart';
import 'dart:io';
import './clockin_remark_dailog.dart';

class ClockinBottomView extends StatefulWidget {
  final VoidCallback onClockinSuccess; //打卡成功回调
  final bool isInOutworkState;

  ClockinBottomView(this.onClockinSuccess, this.isInOutworkState);

  @override
  State<StatefulWidget> createState() => new _ClockinBottomViewState();
}

enum LocationState {
  LocationState_None, //初始化状态，显示未开启定位
  LocationState_Locating, //有定位权限，正在定位
  LocationState_Failed, //定位失败
  LocationState_Success, //定位成功
  LocationState_Out, //考勤范围之外
}

class _ClockinBottomViewState extends State<ClockinBottomView> {
  LocationState _state = LocationState.LocationState_None; //定位状态
  BaiduLocation _location;
  String _serverAddress;
  StreamSubscription<EventUpdateClock> _eventListener;

  Timer _timer; //时间显示定时器

  set locationState(LocationState state) {
    _state = state;
    if (mounted) {
      setState(() {});
    }
  }

  //位置信息文本
  String get address {
    if (_state == LocationState.LocationState_Success ||
        _state == LocationState.LocationState_Out) {
      return isEmpty(_serverAddress)
          ? _location?.locationDescribe
          : _serverAddress;
    } else if (_state == LocationState.LocationState_Failed) {
      return "获取定位信息失败";
    } else if (_state == LocationState.LocationState_Locating) {
      return "正在定位";
    } else {
      return "未开启定位";
    }
  }

  //定位按钮标题
  String get locationButtonTitle {
    String title = "开启定位";
    switch (_state) {
      case LocationState.LocationState_None:
        title = "开启定位";
        break;
      case LocationState.LocationState_Locating:
        title = "正在定位";
        break;
      case LocationState.LocationState_Success:
      case LocationState.LocationState_Failed:
      case LocationState.LocationState_Out:
        title = "刷新定位";
        break;
    }
    return title;
  }

  //打卡按钮主标题
  String get clockInTitle {
    String title = "无法打卡";
    NowClockState state = ClockManager.instance.nowClockState;
    if (state == NowClockState.NowClockState_Unable ||
        state == NowClockState.NowClockState_BeforeIn) {
      title = "无法打卡";
    } else {
      if (widget.isInOutworkState) {
        title = '外勤打卡';
      } else {
        if (_state == LocationState.LocationState_Success) {
          title = "签到";
        } else if (_state == LocationState.LocationState_Out) {
          title = '无法打卡';
        }
      }
    }
    return title;
  }

  bool get clockBtnEnable {
    NowClockState state = ClockManager.instance.nowClockState;
    if (state == NowClockState.NowClockState_Unable ||
        state == NowClockState.NowClockState_BeforeIn) {
      return false;
    }
    if (widget.isInOutworkState) {
      return _state == LocationState.LocationState_Success ||
          _state == LocationState.LocationState_Out;
    } else {
      return _state == LocationState.LocationState_Success;
    }
  }

  ///打卡按钮副标题
  String get clockInSubTitle {
    String title = '';
    NowClockState state = ClockManager.instance.nowClockState;
    if (state == NowClockState.NowClockState_Unable ||
        state == NowClockState.NowClockState_BeforeIn) {
      title = "未到考勤时间";
    } else {
      if (!widget.isInOutworkState) {
        if (_state == LocationState.LocationState_None) {
          title = '未开启定位权限';
        } else if (_state == LocationState.LocationState_Failed) {
          title = '请重新获取定位';
        } else if (_state == LocationState.LocationState_Out) {
          title = '当前位置在考勤范围外';
        }
      }
    }
    return title;
  }

  @override
  void initState() {
    super.initState();

    //定时器，用于显示当前事件
    _timer = new Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (mounted) {
        setState(() {});
      }
    });

    //开始定位，如果没有权限会弹出权限授予界面，然后定位
    _state = LocationState.LocationState_None;
    onLocationBtnPress(isPress: false);

    _eventListener =
        Global.eventBus.on<EventUpdateClock>().listen((EventUpdateClock event) {
      requestClockin(update: true);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _eventListener.cancel();

    super.dispose();
  }

  /// 打卡 update:更新打卡
  void requestClockin(
      {String remark = '', int flag = 0, bool update = false}) async {
    ToastUtil.showLoading('请稍后...');
    // 等待定位完成
    if (update) {
      await _updateLocation();
      if (_state != LocationState.LocationState_Success) {
        ToastUtil.hideLoading();
        if (_state == LocationState.LocationState_Out) {
          ToastUtil.shortToast(context, '当前不在考勤范围内，更新失败');
        } else if (_state == LocationState.LocationState_Failed) {
          ToastUtil.shortToast(context, '无法获取到当前地理位置');
        } else {
          ToastUtil.shortToast(context, '获取地理位置失败');
        }
        return;
      }
    }

    if (_location == null) {
      ToastUtil.hideLoading();
      return;
    }
    ResponseModel ret = await ClockManager.instance.clock(
        _location.latitude,
        _location.longitude,
        isEmpty(_serverAddress) ? _location.locationDescribe : _serverAddress,
        remark: remark,
        flag: flag);
    ToastUtil.hideLoading();
    if (ret.isSuccess) {
      if (widget.onClockinSuccess != null) {
        widget.onClockinSuccess();
      }
      ToastUtil.shortToast(context, update ? '更新打卡成功' : '打卡成功', true);
    } else {
      ToastUtil.shortToast(context, ret.message);
    }
  }

  /// 请求打卡
  void onClockPress() async {
    if (_location == null) return;
    if (widget.isInOutworkState) {
      // 外勤打卡
      String remark = await ClockinRemarkDialog.show(
          context,
          '外勤打卡',
          isEmpty(_serverAddress) ? _location.locationDescribe : _serverAddress,
          ClockManager.instance.now,
          '请填写打卡备注（选填）（最多可输入200字）');
      if (remark != null) {
        requestClockin(remark: remark, flag: 3);
      }
    } else {
      NowClockState state = ClockManager.instance.nowClockState;
      if (state == NowClockState.NowClockState_Early) {
        // 早退打卡
        String remark = await ClockinRemarkDialog.show(
            context,
            '确定要打早退卡吗？',
            isEmpty(_serverAddress)
                ? _location.locationDescribe
                : _serverAddress,
            ClockManager.instance.now,
            '请填写打卡备注（选填）（最多可输入200字）');
        if (remark != null) {
          requestClockin(remark: remark);
        }
      } else {
        requestClockin();
      }
    }
  }

  Future<BaiduLocation> _updateLocation() async {
    bool hasPermission = await JaemobirdPermissions.checkPermission(
        Permission.WhenInUseLocation);
    // 没有权限不往下执行
    if (!hasPermission) {
      return null;
    }

    //开始定位
    if (mounted) {
      setState(() {
        locationState = LocationState.LocationState_Locating;
      });
    }

    _location = await BaiduLocationClient.getLocation();
    lLog('$_location');

    //判断距离
    bool isOut = true;
    List<ClockLocation> settingLocs =
        UserManager.instance.currentCompanyModel?.schedule?.locations;
    if (settingLocs != null && settingLocs.length > 0) {
      for (int i = 0; i < settingLocs.length; ++i) {
        List latlngStr = settingLocs[i].gps.split(',');
        if (latlngStr?.length == 2) {
          double lat = double.tryParse(latlngStr[0]);
          double long = double.tryParse(latlngStr[1]);
          Distance distance = new Distance();
          double meter = distance.as(
              LengthUnit.Meter,
              new LatLng(_location.latitude, _location.longitude),
              new LatLng(lat, long));
          lLog(
              '实际:(${_location.latitude}, ${_location.longitude}), $meter, 设置:($latlngStr), ${settingLocs[i].range}');
          if (meter < settingLocs[i].range) {
            _serverAddress = settingLocs[i].address;
            isOut = false;
            break;
          }
        }
      }
    }

    if (_location.error == null) {
      locationState = isOut
          ? LocationState.LocationState_Out
          : LocationState.LocationState_Success;
    } else {
      locationState = LocationState.LocationState_Failed;
    }
    if (mounted) {
      setState(() {});
    }
    return _location;
  }

  void onLocationBtnPress({bool isPress = true}) async {
    if (_state == LocationState.LocationState_None) {
      PermissionStatus status = await JaemobirdPermissions.getPermissionStatus(
          Permission.WhenInUseLocation);
      bool denied = false;
      if (Platform.isIOS) {
        if (status == PermissionStatus.notDetermined) {
          // ios 如果没有提示过，可以请求权限
          denied = await JaemobirdPermissions.requestPermission(
                  Permission.WhenInUseLocation) ==
              PermissionStatus.denied;
        } else if (status == PermissionStatus.denied) {
          // 如果是拒绝状态否则只能打开设置界面去获取定位权限
          if (isPress) {
            denied = await JaemobirdPermissions.openSettings();
          }
        } else {
          // do nothing
        }
      } else {
        if (status == PermissionStatus.denied) {
          // android 如果拒绝状态，请求权限
          denied = await JaemobirdPermissions.requestPermission(
                  Permission.WhenInUseLocation) ==
              PermissionStatus.denied;
        }
      }

      //用户还是拒绝定位权限，不能打卡
      if (denied) {
        ToastUtil.shortToast(context, '必须有定位权限才能考勤哦～');
        return;
      } else {
        _updateLocation();
      }
    } else if (_state == LocationState.LocationState_Locating) {
      // locating, do nothing
    } else if (_state == LocationState.LocationState_Failed ||
        _state == LocationState.LocationState_Success) {
      _updateLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    DateFormat fmt = DateFormat('HH:mm:ss');
    String timeStr = fmt.format(DateTime.now());
    return Container(
      color: Colors.black.withOpacity(0.8),
      padding: EdgeInsets.only(bottom: kSafeAreaMarginBottom + 10, top: 10),
      child: Column(
        children: <Widget>[
          Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            ImageUtil.image('time_ico.png'),
                            Container(width: 10),
                            Text('$timeStr',
                                style: TextStyle(color: Colors.white))
                          ],
                        ),
                        Container(height: 8),
                        Row(
                          children: <Widget>[
                            ImageUtil.image('loc_ico.png'),
                            Container(width: 10),
                            Expanded(
                              child: Text(
                                '$address',
                                style: TextStyle(color: Colors.white),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  FlatButton(
                    textColor: Colors.white,
                    onPressed: onLocationBtnPress,
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                    child: Column(
                      children: <Widget>[
                        ImageUtil.image('relocate_ico.png'),
                        Container(height: 6),
                        Text('$locationButtonTitle',
                            style: TextStyle(fontSize: 12))
                      ],
                    ),
                  ),
                ],
              )),
          Container(
            width: kScreenWidth,
            height: 56,
            margin: EdgeInsets.only(top: 6),
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: RaisedButton(
              onPressed: clockBtnEnable ? onClockPress : null,
              color: Global.kTintColor,
              disabledColor: Colors.grey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text('$clockInTitle',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                  isEmpty(clockInSubTitle)
                      ? Container(
                          height: 0,
                        )
                      : Text('$clockInSubTitle',
                          style:
                              TextStyle(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
