import 'package:unicom_attendance/global.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../choose_user/approval_users_view.dart';
import 'package:unicom_attendance/common/ui/single_picker.dart';

class LeaveVC extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LeaveVCState();
}

class _LeaveVCState extends State<LeaveVC> {
  DateTime _beginDate;
  DateTime _endDate;
  ApprovalConfigModel _config;
  TextEditingController _reasonController = new TextEditingController();
  LeaveTypes _leaveType;
  double _workTime; // 请假工时，

  @override
  void initState() {
    super.initState();

    requestConfig();
  }

  bool get submitEnable {
    return _leaveType != null &&
        _beginDate != null &&
        _endDate != null &&
        isNotEmpty(_reasonController.text);
  }

  String get worktimeDesc {
    if (_leaveType != null && _workTime != null) {
      String str = _workTime.toString();
      if (_workTime.ceil() == _workTime.floor()) {
        str = _workTime.ceil().toString();
      }
      return '$str ${_leaveType.unitType == 0 ? '小时' : '天'}';
    }
    return '';
  }

  requestConfig() async {
    ResponseModel ret =
        await HttpManager.instance.post('loadApprovalData', params: {
      "approvalId":
          "${UserManager.instance.currentCompanyModel.leavelApprovalId}",
      "approvalType": "0"
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
    if (_beginDate == null || _endDate == null || _leaveType == null) {
      return;
    }
    DateFormat dft = DateFormat('yyyy-MM-dd HH:mm');
    ResponseModel ret =
        await HttpManager.instance.post('calculateWorkingTime', params: {
      'jobId': UserManager.instance.currentJobId,
      'unitType': _leaveType.unitType,
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
  onLeaveTypePress() {
    if (_config == null ||
        _config.leaveTypes == null ||
        _config.leaveTypes.length == 0) {
      return;
    }
    SinglePicker.show(
        context,
        _config.leaveTypes.map((LeaveTypes type) {
          return type.leaveTypeName;
        }).toList(), (int index) {
      _leaveType = _config.leaveTypes.elementAt(index);
      _beginDate = null;
      _endDate = null;
      _workTime = null;
      setState(() {});
      requestWorktime();
    });
  }

  //选择开始时间
  onBeginTimePress() async {
    if (_leaveType == null) {
      ToastUtil.shortToast(context, '请先选择请假类型');
      return;
    }
    DateTime date =
        await DateTimePicker.show(context, _leaveType?.unitType ?? 0);
    if (date != null) {
      _beginDate = date;
      setState(() {});
      requestWorktime();
    }
  }

  // 选择结束时间
  onEndTimePress() async {
    if (_leaveType == null) {
      ToastUtil.shortToast(context, '请先选择请假类型');
      return;
    }
    DateTime date =
        await DateTimePicker.show(context, _leaveType?.unitType ?? 0);
    if (date != null) {
      _endDate = date;
      setState(() {});
      requestWorktime();
    }
  }

  //提交按钮点击
  onSubmitPress() async {
    //判断时间是否正确
    if ((_leaveType.unitType == 0 &&
            _endDate.millisecondsSinceEpoch >
                _beginDate.millisecondsSinceEpoch) ||
        (_leaveType.unitType == 1 &&
            (_endDate.millisecondsSinceEpoch >=
                _beginDate.millisecondsSinceEpoch))) {
      Map<String, dynamic> leaveMap = {
        'leaveTypeId': _leaveType.leaveTypeId,
        'leaveTypeName': _leaveType.leaveTypeName,
        'beginTime': DateFormat('yyyy-MM-dd HH:mm').format(_beginDate),
        'endTime': DateFormat('yyyy-MM-dd HH:mm').format(_endDate),
        'unitType': _leaveType.unitType,
        'reason': _reasonController.text,
        'duration': _workTime
      };

      Map<String, dynamic> approvalMap = {
        'jobId': UserManager.instance.currentJobId,
        'approvalId':
            UserManager.instance.currentCompanyModel.leavelApprovalId ?? 0,
        'approvalType': 0,
        'approvalData': json.encode(leaveMap),
      };
      ResponseModel ret = await HttpManager.instance
          .post('submitApprovalData', params: approvalMap);
      if (ret.isSuccess) {
        ToastUtil.shortToast(context, '提交请假申请成功，请等待审核');
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
      if (_leaveType?.unitType == 1) {
        beginStr = DateFormat('yyyy年MM月dd日').format(_beginDate) +
            ' ${_beginDate.hour < 12 ? '上午' : '下午'}';
      }
    }
    if (_endDate != null) {
      endStr = fmt.format(_endDate);
      if (_leaveType?.unitType == 1) {
        endStr = DateFormat('yyyy年MM月dd日').format(_endDate) +
            ' ${_endDate.hour < 12 ? '上午' : '下午'}';
      }
    }
    String leaveStr = _leaveType?.leaveTypeName ?? "请选择";
    return Scaffold(
        appBar: newAppBar(context, '请假申请'),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: Material(
            color: Global.kBackgroundColor,
            child: Container(
              child: ListView(
                children: <Widget>[
                  Container(height: 10),
                  buildListItem('请假类型', '$leaveStr',
                      flag: true, hasForward: true, onPress: onLeaveTypePress),
                  Container(height: 10),
                  buildListItem('开始时间', '$beginStr',
                      flag: true, onPress: onBeginTimePress, hasForward: true),
                  Container(height: 1),
                  buildListItem('结束时间', '$endStr',
                      flag: true, onPress: onEndTimePress, hasForward: true),
                  Container(height: 1),
                  buildListItem('合计时长', '$worktimeDesc'),
                  Container(height: 10),
                  buildListItem('请假理由', '', flag: true),
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
