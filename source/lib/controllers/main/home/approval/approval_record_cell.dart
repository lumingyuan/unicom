import 'package:unicom_attendance/global.dart';

typedef void OnApprovalTap(Records record);

class ApprovalRecordCell extends StatelessWidget {
  final Records record;
  final OnApprovalTap onApprovalTap;
  ApprovalRecordCell(this.record, this.onApprovalTap);

  @override
  Widget build(BuildContext context) {
    ///0：请假；1：补卡；2：外出；3：出差）
    List<String> titles = ['请假申请', '补卡申请', '外出申请', '出差申请', '更换照片申请', '更换车牌申请'];
    List<String> stateTitles = ['待审批', '已同意', '已拒绝'];
    List<Color> stateColors = [
      Colors.blue[400],
      Colors.green[400],
      Colors.red[400]
    ];
    List<Widget> widgets = new List();
    widgets.add(new Text(
      '${titles[record.approvalType]}',
      style: TextStyle(color: Global.kTintColor, fontSize: 18),
    ));

    Widget content;
    if (record.approvalType == 0) {
      //请假
      content = new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('请假类型：${record.leaveTypeName}'),
          Container(
            height: 3,
          ),
          Text(
            '请假理由：${record.reason}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Container(
            height: 3,
          ),
          Text(
            '开始时间：${record.beginTime}',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          Container(
            height: 3,
          ),
          Text(
            '结束时间：${record.endTime}',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      );
    } else if (record.approvalType == 1) {
      //补卡
      content = new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '补卡理由：${record.reason}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Container(
            height: 3,
          ),
          Text(
            '补卡班次：${record.scheduleName}',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          Container(
            height: 3,
          ),
          Text(
            '补卡时间：${record.clockTime}',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      );
    } else if (record.approvalType == 2) {
      //外出
      content = new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '外出理由：${record.reason}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Container(
            height: 3,
          ),
          Text(
            '开始时间：${record.beginTime}',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          Container(
            height: 3,
          ),
          Text(
            '结束时间：${record.endTime}',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          Container(
            height: 3,
          ),
          Text(
            '外出时长：${record.duration}${record.unitType == 0 ? '时' : '天'}',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      );
    } else if (record.approvalType == 3) {
      //出差
      content = new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '出差地点：${record.destination}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Container(
            height: 3,
          ),
          Text(
            '出差理由：${record.reason}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Container(
            height: 3,
          ),
          Text(
            '开始时间：${record.beginTime}',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          Container(
            height: 3,
          ),
          Text(
            '结束时间：${record.endTime}',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          Container(
            height: 3,
          ),
          Text(
            '出差时长：${record.duration}${record.unitType == 0 ? '时' : '天'}',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      );
    } else if (record.approvalType == 4) {
      //车牌更换
      content = new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '申请人：${record.userName}',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          Text(
            '申请时间：${record.createTime}',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      );
    } else if (record.approvalType == 5) {
      //车牌更换
      content = new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '申请人：${record.userName}',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          Text(
            '申请时间：${record.createTime}',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      );
    }
    widgets.add(new Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: content,
    ));

    widgets.add(new Text(
      '${stateTitles[record.approvalState]}',
      style: TextStyle(color: stateColors[record.approvalState], fontSize: 16),
    ));
    return Container(
      width: kScreenWidth,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Material(
        borderRadius: BorderRadius.circular(5),
        elevation: 1,
        color: Colors.white,
        child: InkWell(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widgets,
            ),
          ),
          onTap: () {
            if (this.onApprovalTap != null) {
              this.onApprovalTap(record);
            }
          },
        ),
      ),
    );
  }
}
