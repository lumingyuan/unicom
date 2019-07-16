import 'package:unicom_attendance/global.dart';

class ClockinApprovalView extends StatelessWidget {
  final ApprovalRecordsData record;

  ClockinApprovalView(this.record);

  String get timeDescription {
    return formateDate(record.unitType, record.beginTime) +
        ' - ' +
        formateDate(record.unitType, record.endTime) +
        ' ' +
        record.duration.toString() +
        (record.unitType == 0 ? '小时' : '天');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 5),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              SizedBox(
                width: 40.0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
                ),
              ),
              Expanded(
                child: Text('${record.approvalType} >'),
              )
            ],
          ),
          Container(height: 5),
          Text(
            timeDescription,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          )
        ],
      ),
    );
  }
}
