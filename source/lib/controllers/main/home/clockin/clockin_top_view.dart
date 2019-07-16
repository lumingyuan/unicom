import 'package:unicom_attendance/global.dart';

class ClockinTopView extends StatelessWidget {
  final String date;
  final String username;
  final String groupname;
  final VoidCallback onDatePress;
  ClockinTopView(this.date, this.username, this.groupname, this.onDatePress);

  @override
  Widget build(BuildContext context) {
    return new Material(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Text(
                        '$username',
                        style: TextStyle(fontSize: 18, color: Colors.black87),
                      ),
                    ),
                    Container(height: 5),
                    Container(
                      child: Text(
                        '考勤组：$groupname',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    )
                  ],
                ),
                Spacer(),
                FlatButton(
                  onPressed: this.onDatePress,
                  child: Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('$date',
                            style: TextStyle(
                                fontSize: 14, color: Global.kTintColor)),
                        Container(width: 8),
                        ImageUtil.image('expand_more.png')
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Divider(height: 1),
        ],
      ),
    );
  }
}
