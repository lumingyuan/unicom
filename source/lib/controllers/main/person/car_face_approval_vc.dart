import 'package:unicom_attendance/controllers/main/home/approval/approval_detail_vc.dart';
import 'package:unicom_attendance/global.dart';

class CarFaceApprovalVC extends StatefulWidget {
  final bool face;
  CarFaceApprovalVC({this.face = false});

  @override
  State<StatefulWidget> createState() => new _CarFaceApprovalVCState();
}

class _CarFaceApprovalVCState extends State<CarFaceApprovalVC> {
  List<Records> _records = new List();

  @override
  void initState() {
    super.initState();

    requestCarRecord();
  }

  Future<void> requestCarRecord() async {
    ResponseModel ret = await HttpManager.instance
        .post('loadConfigApprovalRecords', params: {
      'jobId': UserManager.instance.currentJobId,
      'approvalType': widget.face ? 4 : 5
    });
    if (ret.isSuccess) {
      _records.clear();
      _records =
          (ret.data as List).map((item) => Records.fromJson(item)).toList();
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime showDate;
    return Scaffold(
      backgroundColor: Global.kBackgroundColor,
      appBar: newAppBar(context, widget.face ? '照片审核记录' : '车牌审核记录'),
      body: RefreshIndicator(
        onRefresh: requestCarRecord,
        child: ListView.builder(
          itemBuilder: (context, index) {
            Records model = _records.elementAt(index);
            DateTime date =
                DateFormat('yyyy-MM-dd HH:mm:ss').parse(model.createTime);
            bool show = false;
            if (showDate == null ||
                showDate.year != date.year ||
                showDate.month != date.month ||
                showDate.day != date.day) {
              show = true;
            }
            if (show) {
              showDate = date;
            }
            return Column(
              children: <Widget>[
                show ? buildDate(date) : Container(),
                InkWell(
                  onTap: () {
                    NavigatorUtil.pushVC(
                      context,
                      new ApprovalDetailVC(model.approvalRecordId),
                    );
                  },
                  child: widget.face
                      ? buildFaceRecord(model)
                      : buildCarRecord(model),
                ),
              ],
            );
          },
          itemCount: _records.length,
        ),
      ),
    );
  }

  buildDate(DateTime date) {
    if (date == null) {
      return Container();
    }
    return new Container(
      margin: EdgeInsets.only(top: 10),
      height: 30,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Color.fromRGBO(200, 201, 202, 0.75),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${DateFormat('yyyy-MM-dd').format(date)}',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }

  buildCarRecord(Records record) {
    List<String> stateTitles = ['待审批', '已同意', '已拒绝'];
    List<Color> stateColors = [
      Colors.blue[400],
      Colors.green[400],
      Colors.red[400]
    ];
    bool showApproval = record.approveRecord != null &&
        (record.approveRecord as Map).length > 0;
    String reason = record.approveRecord != null
        ? record.approveRecord['rejectReason']
        : '';
    if (isEmpty(reason)) {
      reason = '无';
    }
    return Container(
      width: kScreenWidth,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Material(
        borderRadius: BorderRadius.circular(5),
        elevation: 1,
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              buildContentItem('审核状态', stateTitles[record.approvalState],
                  contentColor: stateColors[record.approvalState]),
              buildContentItem('新车牌', record.carCode),
              buildContentItem(
                  '旧车牌', isEmpty(record.oldCarCode) ? '无' : record.oldCarCode),
              buildContentItem('提交时间', record.createTime),
              showApproval
                  ? buildContentItem(
                      '审核时间', record.approveRecord['approveTime'])
                  : Container(),
              showApproval && record.approvalState == 2
                  ? buildContentItem('拒绝理由', reason)
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildContentItem(String title, String content,
      {double width = 70, Color contentColor}) {
    return Container(
      height: 34,
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: <Widget>[
          Container(
            width: width,
            child: Text(
              '$title',
              style: TextStyle(fontSize: 15, color: Color(0xff999999)),
            ),
          ),
          Text(
            '$content',
            style: TextStyle(
                fontSize: 15,
                color: contentColor != null ? contentColor : Color(0xff454545)),
          )
        ],
      ),
    );
  }

  Widget buildFaceRecord(Records record) {
    List<String> stateTitles = ['待审批', '已同意', '已拒绝'];
    List<Color> stateColors = [
      Colors.blue[400],
      Colors.green[400],
      Colors.red[400]
    ];
    bool showApproval = record.approveRecord != null &&
        (record.approveRecord as Map).length > 0;
    String reason = record.approveRecord != null
        ? record.approveRecord['rejectReason']
        : '';
    if (isEmpty(reason)) {
      reason = '无';
    }
    return Container(
      width: kScreenWidth,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Material(
        borderRadius: BorderRadius.circular(5),
        elevation: 1,
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '审核状态：',
                          style:
                              TextStyle(fontSize: 15, color: Color(0xff999999)),
                        ),
                        Text(
                          stateTitles[record.approvalState],
                          style: TextStyle(
                              fontSize: 15,
                              color: stateColors[record.approvalState]),
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          '提交时间：',
                          style:
                              TextStyle(fontSize: 15, color: Color(0xff999999)),
                        ),
                        Expanded(
                          child: Text(
                            record.createTime,
                            style: TextStyle(
                                fontSize: 15, color: Color(0xff454545)),
                          ),
                        )
                      ],
                    ),
                    Offstage(
                      offstage: !showApproval,
                      child: Row(
                        children: <Widget>[
                          Text(
                            '审核时间：',
                            style: TextStyle(
                                fontSize: 15, color: Color(0xff999999)),
                          ),
                          Expanded(
                            child: Text(
                              showApproval
                                  ? record.approveRecord['approveTime']
                                  : '',
                              style: TextStyle(
                                  fontSize: 15, color: Color(0xff454545)),
                            ),
                          )
                        ],
                      ),
                    ),
                    Offstage(
                      offstage: !showApproval || record.approvalState != 2,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '拒绝理由：',
                            style: TextStyle(
                                fontSize: 15, color: Color(0xff999999)),
                          ),
                          Expanded(
                            child: Text(
                              '$reason',
                              style: TextStyle(
                                  fontSize: 15, color: Color(0xff454545)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 10),
                width: 80,
                height: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ImageUtil.imageFromUrl(
                        Global.appDomain + record.identifyImage),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
