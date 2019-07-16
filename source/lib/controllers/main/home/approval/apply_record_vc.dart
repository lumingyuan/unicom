import 'package:unicom_attendance/global.dart';
import './approval_record_list.dart';
import '../approval/approval_detail_vc.dart';

class ApplyRecordVC extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ApplyRecordVCState();
}

class _ApplyRecordVCState extends State<ApplyRecordVC> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Global.kBackgroundColor,
      appBar: newAppBar(context, '申请记录'),
      body: ApprovalRecordList(0, (Records record) {
        NavigatorUtil.pushVC(
          context,
          new ApprovalDetailVC(
            record.approvalRecordId
          ),
        );
      }),
    );
  }
}
