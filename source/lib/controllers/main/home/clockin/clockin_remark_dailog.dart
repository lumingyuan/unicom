import 'package:unicom_attendance/global.dart';
import 'package:intl/intl.dart';

class ClockinRemarkDialog extends StatefulWidget {
  final TextEditingController editCtrl;
  final String placeholder;
  final String address;
  final DateTime time;

  ClockinRemarkDialog(this.editCtrl, this.address, this.time, this.placeholder);

  @override
  State<StatefulWidget> createState() => new _ClockinRemarkDialogState();

  static Future<String> show(BuildContext context, String title,
      String placeholder, DateTime time, String address) async {
    TextEditingController ctrl = new TextEditingController();
    return showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('$title'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              contentPadding:
                  EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 0),
              content:
                  new ClockinRemarkDialog(ctrl, address, time, placeholder),
              actions: <Widget>[
                FlatButton(
                  child: Text('取消'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text('确定'),
                  onPressed: () {
                    Navigator.of(context).pop(ctrl.text);
                  },
                )
              ],
            ));
  }
}

class _ClockinRemarkDialogState extends State<ClockinRemarkDialog> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: kScreenWidth - 50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('打卡时间：${DateFormat('HH:mm').format(widget.time)}'),
          Container(height: 4),
          Text('打卡地点：${widget.placeholder}'),
          Container(height: 10),
          Container(
            padding: EdgeInsets.all(5),
            decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
              side: BorderSide(color: Color(0xfff0f0f0), width: 1),
              borderRadius: BorderRadius.circular(3),
            )),
            child: TextField(
              maxLines: 4,
              maxLength: 200,
              controller: widget.editCtrl,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(0),
                hintText: '${widget.placeholder}',
                hintStyle: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
