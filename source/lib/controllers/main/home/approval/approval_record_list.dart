import 'package:unicom_attendance/global.dart';
import './approval_record_cell.dart';
import '../approval/approval_detail_vc.dart';

class ApprovalRecordList extends StatefulWidget {
  final int type;
  final OnApprovalTap onApprovalTap;
  ApprovalRecordList(this.type, this.onApprovalTap, {Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _ApprovalRecordListState();
  }
}

class _ApprovalRecordListState extends State<ApprovalRecordList> {
  GlobalKey<EasyRefreshState> _refreshKey = new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey = new GlobalKey();
  GlobalKey<RefreshFooterState> _footerKey = new GlobalKey();

  int _currentPage = 0;

  List<DayOfApplyRecordModel> _records = new List();
  @override
  void initState() {
    super.initState();

    Global.eventBus
        .on<EventApprovalChanged>()
        .listen((EventApprovalChanged event) {
      _currentPage = 0;
      _records.clear();
      requestRecords(showLoading: false);
    });
  }

  Future<Null> requestRecords({bool showLoading = false}) async {
    if (showLoading) {
      ToastUtil.showLoading('加载中...');
    }
    ResponseModel ret =
        await HttpManager.instance.post('loadApprovalRecords', params: {
      'jobId': UserManager.instance.currentJobId,
      'pageIndex': _currentPage,
      'type': widget.type
    });
    await Future.delayed(Duration(seconds: 1));
    if (showLoading) {
      ToastUtil.hideLoading();
    }
    if (ret.isSuccess) {
      String updateTime = ret.data['updateTime'];
      if (isNotEmpty(updateTime)) {
        Setting.saveString(Setting.kNumUpdateTime, updateTime);
        Setting.numUpdateTime = updateTime;
        Global.eventBus.fire(new EventUpdateBaseData());
      }

      List<DayOfApplyRecordModel> models =
          getDayOfApplyRecordModelList(ret.data['records']);
      if (models != null && models.length > 0) {
        if (mounted) {
          setState(() {
            _records.addAll(models);
          });
        }
      } else {
        if (_currentPage != 0) {
          ToastUtil.shortToast(context, '没有更多记录了~');
        }
      }
    } else {
      ToastUtil.shortToast(context, ret.message);
    }
  }

  ///一天内的所有申请记录
  Widget buildDayOfRecords(BuildContext context, int index) {
    DayOfApplyRecordModel model = _records.elementAt(index);
    List<Widget> widgets = new List();
    if (model.records == null) {
      return Container();
    }
    widgets.add(new Container(
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
            '${model.date}',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    ));

    widgets.addAll(model.records.map((Records record) {
      return ApprovalRecordCell(record, widget.onApprovalTap);
    }).toList());
    return Container(
      child: Column(
        children: widgets,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: newRefresh(
        context,
        refreshKey: _refreshKey,
        headerKey: _headerKey,
        footerKey: _footerKey,
        onLoadMore: () {
          _currentPage++;
          return requestRecords();
        },
        onRefresh: () {
          _currentPage = 0;
          _records.clear();
          return requestRecords();
        },
        child: ListView.builder(
          itemBuilder: buildDayOfRecords,
          itemCount: _records.length,
        ),
      ),
    );
  }
}
