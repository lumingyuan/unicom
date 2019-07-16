import 'package:unicom_attendance/global.dart';
import './approval_record_list.dart';
import '../approval/approval_detail_vc.dart';

class ApprovalVC extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ApprovalVCState();
}

class _ApprovalVCState extends State<ApprovalVC>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  int _currentIndex = 0;
  UniqueKey _unapprovalKey = new UniqueKey();
  UniqueKey _approvaledKey = new UniqueKey();

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        setState(() {
          _currentIndex = _tabController.index;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: newAppBar(context, '审批',
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(46),
              child: TabBar(
                indicatorWeight: 1,
                controller: _tabController,
                tabs: <Widget>[
                  Tab(
                    text: '待审批',
                  ),
                  Tab(
                    text: '已完成',
                  ),
                ],
              ),
            )),
        body: Container(
          child: IndexedStack(
            children: <Widget>[
              ApprovalRecordList(1, (Records record) {
                NavigatorUtil.pushVC(
                  context,
                  new ApprovalDetailVC(
                    record.approvalRecordId
                  ),
                );
              }, key: _unapprovalKey),
              ApprovalRecordList(2, (Records record) {
                NavigatorUtil.pushVC(
                  context,
                  new ApprovalDetailVC(
                    record.approvalRecordId
                  ),
                );
              }, key: _approvaledKey)
            ],
            index: _currentIndex,
          ),
        ));
  }
}
