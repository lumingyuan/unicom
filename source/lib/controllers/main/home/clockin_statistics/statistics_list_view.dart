import 'package:unicom_attendance/global.dart';
import 'package:flutter_picker/flutter_picker.dart';
import './statistics_list_cell.dart';

class StatisticsListView extends StatefulWidget {
  StatisticsListView({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _StatisticsListViewState();
  }
}

class _StatisticsListViewState extends State<StatisticsListView>
    with AutomaticKeepAliveClientMixin {
  DateTime _selectedDate;
  ClockinStatisticsModel _model;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectedDate = ClockManager.instance.now;
    requestData();
  }

  Future<void> requestData() async {
    ResponseModel ret = await HttpManager.instance
        .post('loadAttendanceRecordSummaryOfMonth', params: {
      'jobId': UserManager.instance.currentJobId,
      'month': DateFormat('yyyy-MM').format(_selectedDate)
    });
    if (ret.isSuccess) {
      _model = ClockinStatisticsModel.fromJson(ret.data);
      if (mounted) {
        setState(() {});
      }
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
          setState(() {
            _selectedDate = DateTime.tryParse(picker.adapter.toString());
            lLog('confirm:$_selectedDate');
            requestData();
          });
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: Colors.white,
      child: RefreshIndicator(
        onRefresh: requestData,
        child: ListView(
          children: <Widget>[
            buildDatePopupMenu(),
            StatisticsListCell('出勤天数', '${_model?.attendanceDay?.count ?? 0}天',
                _model?.attendanceDay?.data,
                isFirstCell: true),
            StatisticsListCell(
                '出勤班次',
                '共${isNotEmpty(_model?.attendanceSchedule?.attendanceGroupName) ? 1 : 0}次',
                [_model?.attendanceSchedule?.attendanceGroupName ?? '']),
            StatisticsListCell('休息天数', '${_model?.restDay?.count ?? 0}天',
                _model?.restDay?.data),
            StatisticsListCell(
                '迟到', '${_model?.late1?.count ?? 0}次', _model?.late1?.data),
            StatisticsListCell(
                '早退', '${_model?.early?.count ?? 0}次', _model?.early?.data),
            StatisticsListCell(
                '缺卡', '${_model?.lack?.count ?? 0}次', _model?.lack?.data),
            StatisticsListCell('旷工', '${_model?.absenteeism?.count ?? 0}天',
                _model?.absenteeism?.data),
            StatisticsListCell(
                '外勤',
                '${_model?.travelApprovalRecord?.count ?? 0}次',
                _model?.travelApprovalRecord?.data),
            StatisticsListCell(
                '请假',
                '${_model?.leaveApprovalRecord?.count ?? 0}次',
                _model?.leaveApprovalRecord?.data),
            StatisticsListCell(
                '补卡',
                '${_model?.clockApprovalRecord?.count ?? 0}次',
                _model?.clockApprovalRecord?.data),
            StatisticsListCell(
                '外出',
                '${_model?.outApprovalRecord?.count ?? 0}次',
                _model?.outApprovalRecord?.data),
          ],
        ),
      ),
    );
  }
}
