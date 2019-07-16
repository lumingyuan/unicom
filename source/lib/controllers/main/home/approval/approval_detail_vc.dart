import 'package:unicom_attendance/global.dart';
import './approval_stepper_view.dart';

class EventApprovalChanged {
  final int approvalId;
  EventApprovalChanged(this.approvalId);
}

class ApprovalDetailVC extends StatefulWidget {
  final int approvalId;

  ApprovalDetailVC(this.approvalId);

  @override
  State<StatefulWidget> createState() => new _ApprovalDetailVCState();
}

class _ApprovalDetailVCState extends State<ApprovalDetailVC> {
  ApprovalDetailModel _model;

  bool get showBottom {
    return _model != null &&
        _model?.recordState != 2 &&
        _model?.currentApprover?.jobId == UserManager.instance.currentJobId;
  }

  @override
  void initState() {
    super.initState();

    requestDetail(true);
  }

  Future<Null> requestDetail([bool showLoading = false]) async {
    if (showLoading) {
      ToastUtil.showLoading('获取详情...');
    }
    ResponseModel ret = await HttpManager.instance.post(
        'loadApprovalRecordDetail',
        params: {'approvalRecordId': widget.approvalId});
    await Future.delayed(Duration(seconds: 1));
    if (showLoading) {
      ToastUtil.hideLoading();
    }
    if (ret.isSuccess) {
      _model = ApprovalDetailModel.fromJson(ret.data);
      if (_model.approveRecord == null) {
        _model.approveRecord = new List();
      }
      _model.approveRecord.insert(
          0,
          ApproveRecord(
              _model.jobId,
              _model.userName,
              _model.approveRecord.length == 0 ? 2 : 1,
              _model.createTime,
              null));
      if (_model.recordState == 0 && _model.currentApprover != null) {
        _model.approveRecord.add(ApproveRecord(_model.currentApprover.jobId,
            _model.currentApprover.userName, 2, '', null));
      }
      setState(() {});
    } else {
      ToastUtil.shortToast(context, ret.message);
    }
  }

  ///
  /// 审核操作请求
  void requestApproval(bool agree, {String reason = ''}) async {
    ResponseModel ret =
        await HttpManager.instance.post('submitApproveData', params: {
      'jobId': UserManager.instance.currentJobId,
      'approvalRecordId': widget.approvalId,
      'approveState': agree ? 1 : 0,
      'rejectReason': reason,
    });
    if (ret.isSuccess) {
      ToastUtil.shortToast(context, '操作成功', true);
      this.requestDetail(); //刷新当前页面

      Global.eventBus.fire(new EventApprovalChanged(widget.approvalId));
    } else {
      ToastUtil.shortToast(context, ret.message);
    }
  }

  String get title {
    if (_model == null) {
      return "";
    }
    List<String> titles = ['请假申请', '补卡申请', '外出申请', '出差申请', '照片更换申请', '车牌更换申请'];
    return titles[_model.approvalType];
  }

  void onAgreePress() async {
    bool ret = await showAlertDialog(context, '同意提醒', '是否同意该审批？');
    if (ret) {
      requestApproval(true);
    }
  }

  void onRefusePress() async {
    String text = await showInputDialog(
        context, '拒绝提醒', '登记拒绝理由（选填），最多可输入100字。',
        maxLength: 100);
    if (text != null) {
      lLog('$text');
      requestApproval(false, reason: text);
    }
  }

  Widget buildState() {
    List<String> stateImgs = [
      'state_wait.png',
      'state_agreen.png',
      'state_refuse.png'
    ];
    List<String> stateTitles = ['等待处理', '审核通过', '审核被拒绝'];
    List<Color> stateColors = [
      Colors.blue[400],
      Colors.green[400],
      Colors.red[400]
    ];
    int state = _model?.recordState ?? 0;
    return Column(
      children: <Widget>[
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Row(
            children: <Widget>[
              ImageUtil.image(stateImgs[state]),
              Container(
                width: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${stateTitles[state]}',
                    style: TextStyle(color: stateColors[state], fontSize: 18),
                  ),
                  Container(height: 6),
                  Offstage(
                    offstage: _model?.recordState != 0,
                    child: Text(
                      '已提交申请，等待上级处理',
                      style: TextStyle(color: Color(0xff919191), fontSize: 14),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
        ImageUtil.image('color_line.png',
            width: kScreenWidth, fit: BoxFit.fill),
      ],
    );
  }

  Widget buildContentItem(String title, String content,
      {double width = 70, Widget contenWidget}) {
    return Container(
      height: contenWidget == null ? 34 : null,
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: width,
            child: Text(
              '$title',
              style: TextStyle(fontSize: 15, color: Color(0xff919191)),
            ),
          ),
          contenWidget == null
              ? Text(
                  '$content',
                  style: TextStyle(fontSize: 15, color: Global.kDefTextColor),
                )
              : contenWidget
        ],
      ),
    );
  }

  Widget buildReason() {
    if (_model == null ||
        _model.approvalType == 4 ||
        _model.approvalType == 5) {
      return Container();
    }
    List<String> titles = ['请假理由', '补卡理由', '外出理由', '出差理由'];
    int index = _model?.approvalType ?? 0;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      alignment: Alignment.topLeft,
      child: RichText(
        text: TextSpan(
            text: '${titles[index]}：  ',
            style: TextStyle(fontSize: 15, color: Color(0xff919191)),
            children: [
              TextSpan(
                  text: '${_model.reason}',
                  style: TextStyle(fontSize: 15, color: Global.kDefTextColor)),
            ]),
      ),
    );
  }

  Widget buildApplyContent() {
    List<Widget> contents = new List();
    if (_model != null) {
      contents.add(buildContentItem('申请人', '${_model.userName}'));
      contents.add(buildContentItem('所在部门', '${_model.departmentName}'));
      if (_model.approvalType == 0) {
        contents.add(buildContentItem('请假类型', '${_model.leaveType}'));
        contents.add(buildContentItem('申请时间', '${_model.createTime}'));
        contents.add(Divider(height: 10));
        contents.add(buildContentItem(
            '开始时间', formateDate(_model.unitType, _model.beginTime)));
        contents.add(buildContentItem(
            '结束时间', formateDate(_model.unitType, _model.endTime)));
        contents.add(buildContentItem(
            '请假时长', '${_model.duration}${_model.unitType == 0 ? '时' : '天'}'));

        contents.add(Divider(height: 10));
        contents.add(buildReason());
      } else if (_model.approvalType == 1) {
        contents.add(buildContentItem('申请时间', '${_model.createTime}'));
        contents.add(Divider(height: 10));
        contents.add(buildContentItem('补卡班次', '${_model.scheduleName}'));
        contents.add(buildContentItem('补卡时间', '${_model.clockTime}'));

        contents.add(Divider(height: 10));
        contents.add(buildReason());
      } else if (_model.approvalType == 2) {
        contents.add(buildContentItem('申请时间', '${_model.createTime}'));
        contents.add(Divider(height: 10));
        contents.add(buildContentItem(
            '开始时间', formateDate(_model.unitType, _model.beginTime)));
        contents.add(buildContentItem(
            '结束时间', formateDate(_model.unitType, _model.endTime)));
        contents.add(buildContentItem(
            '累计时长', '${_model.duration}${_model.unitType == 0 ? '时' : '天'}'));

        contents.add(Divider(height: 10));
        contents.add(buildReason());
      } else if (_model.approvalType == 3) {
        contents.add(buildContentItem('申请时间', '${_model.createTime}'));
        contents.add(Divider(height: 10));
        contents.add(buildContentItem('出差地点', '${_model.destination}'));
        contents.add(buildContentItem(
            '开始时间', formateDate(_model.unitType, _model.beginTime)));
        contents.add(buildContentItem(
            '结束时间', formateDate(_model.unitType, _model.endTime)));
        contents.add(buildContentItem(
            '累计时长', '${_model.duration}${_model.unitType == 0 ? '时' : '天'}'));

        contents.add(Divider(height: 10));
        contents.add(buildReason());
      } else if (_model.approvalType == 4) {
        contents.add(buildContentItem('申请时间', '${_model.createTime}'));
        contents.add(Divider(height: 10));
        contents.add(
          buildContentItem(
            '新照片',
            '',
            contenWidget: Expanded(
              child: Container(
                margin: EdgeInsets.only(right: 80),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ImageUtil.imageFromUrl(
                        Global.appDomain + _model.identifyImage,
                        fit: BoxFit.fill),
                  ),
                ),
              ),
            ),
          ),
        );
      } else if (_model.approvalType == 5) {
        contents.add(buildContentItem('申请时间', '${_model.createTime}'));
        contents.add(Divider(height: 10));
        contents.add(buildContentItem('旧车牌', '${_model.oldCarCode}'));
        contents.add(buildContentItem('新车牌', '${_model.carCode}'));
        contents.add(buildContentItem(
            '新车牌持有人', isEmpty(_model.reason) ? '无' : '${_model.reason}',
            width: 100));
      }
    }
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      color: Colors.white,
      child: Column(
        children: contents,
      ),
    );
  }

  Widget buildStepper() {
    if (_model == null) {
      return Container();
    } else {
      List<Widget> steppers = new List();
      for (int i = 0; i < _model.approveRecord.length; ++i) {
        steppers.add(ApprovalStepperView(_model.approveRecord[i], i == 0,
            i == _model.approveRecord.length - 1,
            isSelf: _model.jobId == _model.approveRecord[i].jobId));
      }
      return Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: steppers,
        ),
      );
    }
  }

  Widget buildBottomBtns() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Color(0xfff0f0f0),
            offset: Offset(0, -2),
            blurRadius: 4,
            spreadRadius: 2),
      ]),
      padding: EdgeInsets.only(
          left: 10, right: 10, top: 10, bottom: 10 + kSafeAreaMarginBottom),
      child: Row(
        children: <Widget>[
          Expanded(
            child: OutlineButton(
              borderSide: BorderSide(color: Colors.blue),
              textColor: Colors.blue,
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('拒绝')),
              onPressed: onRefusePress,
            ),
          ),
          Container(
            width: 20,
          ),
          Expanded(
            child: FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onPressed: onAgreePress,
              color: Global.kTintColor,
              disabledColor: Colors.grey,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('同意', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: newAppBar(context, '$title'),
      body: Container(
        color: Global.kBackgroundColor,
        child: Column(
          children: <Widget>[
            Expanded(
              child: RefreshIndicator(
                onRefresh: requestDetail,
                child: ListView(
                  children: <Widget>[
                    buildState(),
                    buildApplyContent(),
                    Container(
                      height: 10,
                    ),
                    buildStepper(),
                  ],
                ),
              ),
            ),
            Offstage(
              offstage: !showBottom,
              child: buildBottomBtns(),
            )
          ],
        ),
      ),
    );
  }
}
