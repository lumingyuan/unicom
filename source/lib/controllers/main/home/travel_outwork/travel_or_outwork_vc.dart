import 'package:unicom_attendance/global.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../choose_user/approval_users_view.dart';
import 'package:flutter_location_picker/flutter_location_picker.dart';

class TravelOrOutworkVC extends StatefulWidget {
  final bool isTravel; //false 外出  true出差
  TravelOrOutworkVC(this.isTravel);

  @override
  State<StatefulWidget> createState() => new _TravelOrOutworkVCState();
}

class _TravelOrOutworkVCState extends State<TravelOrOutworkVC> {
  DateTime _beginDate;
  DateTime _endDate;
  ApprovalConfigModel _config;
  TextEditingController _reasonController = new TextEditingController();
  double _workTime; // 出差工时，
  String _address; //外出地点

  @override
  void initState() {
    super.initState();

    requestConfig();
  }

  bool get submitEnable {
    return _beginDate != null &&
        _endDate != null &&
        isNotEmpty(_reasonController.text);
  }

  String get worktimeDesc {
    if (_workTime != null) {
      String str = _workTime.toString();
      if (_workTime.ceil() == _workTime.floor()) {
        str = _workTime.ceil().toString();
      }
      return '$str ${_config?.unitType == 0 ? '小时' : '天'}';
    }
    return '';
  }

  requestConfig() async {
    int approvalId = UserManager.instance.currentCompanyModel.travelApprovalId;
    if (!widget.isTravel) {
      approvalId = UserManager.instance.currentCompanyModel.outApprovalId;
    }
    ResponseModel ret = await HttpManager.instance.post('loadApprovalData',
        params: {
          "approvalId": approvalId,
          "approvalType": widget.isTravel ? 3 : 2
        });
    if (ret.isSuccess) {
      _config = ApprovalConfigModel.fromJson(ret.data);
      if (mounted) {
        setState(() {});
      }
    } else {
      ToastUtil.shortToast(context, ret.message);
      Future.delayed(Duration(seconds: 1)).then((_) {
        Navigator.pop(context);
      });
    }
  }

  requestWorktime() async {
    if (_beginDate == null || _endDate == null || _config == null) {
      return;
    }
    DateFormat dft = DateFormat('yyyy-MM-dd HH:mm');
    ResponseModel ret =
        await HttpManager.instance.post('calculateWorkingTime', params: {
      'jobId': UserManager.instance.currentJobId,
      'unitType': _config.unitType,
      'beginTime': dft.format(_beginDate),
      'endTime': dft.format(_endDate)
    });
    if (ret.isSuccess) {
      _workTime = ret.data['workingTime'];
      setState(() {});
    } else {
      lLog(ret.message);
    }
  }

  //选择请假类型
  onAddressPress() {
    List<String> list = ['浙江', '台州市', '椒江区'];
    if (_address != null) {
      list = _address.split(' ');
    }
    LocationPicker.showPicker(
      context,
      showTitleActions: true,
      initialProvince: list[0],
      initialCity: list[1],
      initialTown: list[2],
      onChanged: (p, c, t) {
        print('$p $c $t');
      },
      onConfirm: (p, c, t) async {
        _address = '$p $c $t';
        setState(() {});
      },
    );
  }

  //选择开始时间
  onBeginTimePress() async {
    if (_config == null) {
      return;
    }
    DateTime date = await DateTimePicker.show(context, _config?.unitType ?? 0);
    if (date != null) {
      _beginDate = date;
      setState(() {});
      requestWorktime();
    }
  }

  // 选择结束时间
  onEndTimePress() async {
    if (_config == null) {
      return;
    }
    DateTime date = await DateTimePicker.show(context, _config?.unitType ?? 0);
    if (date != null) {
      _endDate = date;
      setState(() {});
      requestWorktime();
    }
  }

  //提交按钮点击
  onSubmitPress() async {
    //判断时间是否正确
    if ((_config?.unitType == 0 && _endDate.isAfter(_beginDate)) ||
        (_config?.unitType == 1 &&
            (_endDate.millisecondsSinceEpoch >=
                _beginDate.millisecondsSinceEpoch))) {
      Map<String, dynamic> travelMap = {
        'destination': _address,
        'beginTime': DateFormat('yyyy-MM-dd HH:mm').format(_beginDate),
        'endTime': DateFormat('yyyy-MM-dd HH:mm').format(_endDate),
        'unitType': _config?.unitType,
        'reason': _reasonController.text,
        'duration': _workTime
      };

      int approvalId =
          UserManager.instance.currentCompanyModel.travelApprovalId;
      if (!widget.isTravel) {
        approvalId = UserManager.instance.currentCompanyModel.outApprovalId;
      }
      Map<String, dynamic> approvalMap = {
        'jobId': UserManager.instance.currentJobId,
        'approvalId': approvalId,
        'approvalType': widget.isTravel ? 3 : 2,
        'approvalData': json.encode(travelMap),
      };
      ResponseModel ret = await HttpManager.instance
          .post('submitApprovalData', params: approvalMap);
      if (ret.isSuccess) {
        if (widget.isTravel) {
          ToastUtil.shortToast(context, '提交出差申请成功，请等待审核');
        } else {
          ToastUtil.shortToast(context, '提交外出申请成功，请等待审核');
        }
        Navigator.maybePop(context);
      } else {
        ToastUtil.shortToast(context, ret.message);
      }
    } else {
      ToastUtil.shortToast(context, '结束时间不能早于开始时间');
    }
  }

  Widget buildListItem(String title, String content,
      {bool flag = false, VoidCallback onPress, bool hasForward = false}) {
    return MyListTile(
      Row(
        children: <Widget>[
          Container(
            width: 24,
            child: Offstage(
              offstage: !flag,
              child: Center(
                child: Text(
                  '＊',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
          Text('$title')
        ],
      ),
      trailing: isEmpty(content) ? null : Text('$content'),
      onPressed: onPress,
      hasForward: hasForward,
    );
  }

  @override
  Widget build(BuildContext context) {
    DateFormat fmt = DateFormat('yyyy年MM月dd日 HH:mm');
    String beginStr = '请选择';
    String endStr = '请选择';
    if (_beginDate != null) {
      beginStr = fmt.format(_beginDate);
      if (_config?.unitType == 1) {
        beginStr = DateFormat('yyyy年MM月dd日').format(_beginDate) +
            ' ${_beginDate.hour < 12 ? '上午' : '下午'}';
      }
    }
    if (_endDate != null) {
      endStr = fmt.format(_endDate);
      if (_config?.unitType == 1) {
        endStr = DateFormat('yyyy年MM月dd日').format(_endDate) +
            ' ${_endDate.hour < 12 ? '上午' : '下午'}';
      }
    }
    String addressStr = _address ?? "请选择";
    return Scaffold(
        appBar: newAppBar(context, widget.isTravel ? '出差申请' : '外出申请'),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: Material(
            color: Global.kBackgroundColor,
            child: Container(
              child: ListView(
                children: <Widget>[
                  Offstage(
                    offstage: !widget.isTravel,
                    child: Column(
                      children: <Widget>[
                        Container(height: 10),
                        buildListItem('出差地点', '$addressStr',
                            flag: true,
                            hasForward: true,
                            onPress: onAddressPress),
                      ],
                    ),
                  ),
                  Container(height: 10),
                  buildListItem('开始时间', '$beginStr',
                      flag: true, onPress: onBeginTimePress, hasForward: true),
                  Container(height: 1),
                  buildListItem('结束时间', '$endStr',
                      flag: true, onPress: onEndTimePress, hasForward: true),
                  Container(height: 1),
                  buildListItem('合计时长', '$worktimeDesc'),
                  Container(height: 10),
                  buildListItem(widget.isTravel ? '出差理由' : '外出理由', '',
                      flag: true),
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(left: 25, right: 25, bottom: 30),
                    child: TextField(
                      controller: _reasonController,
                      onChanged: (_) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(0),
                        hintText: '请输入...',
                      ),
                      maxLines: 4,
                      maxLength: 1000,
                    ),
                  ),
                  Container(height: 10),
                  buildListItem('审批人', '', flag: true),
                  ApprovalUsersView(_config?.approvers),
                  Container(
                    width: kScreenWidth,
                    margin: EdgeInsets.only(
                        left: 15, right: 15, top: 50, bottom: 10),
                    child: newCommonButton(
                        '提交申请', submitEnable ? onSubmitPress : null),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
