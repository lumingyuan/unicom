import 'package:unicom_attendance/global.dart';

class ChooseUserVC extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ChooseUserVCState();
}

class _ChooseUserVCState extends State<ChooseUserVC> {
  Map<String, List<Map<String, dynamic>>> _groupsModel = new Map();

  List<Map<String, dynamic>> get selectedUser {
    List<Map<String, dynamic>> selectUsers = new List();
    _groupsModel.forEach((String key, List<Map<String, dynamic>> value) {
      value.forEach((Map<String, dynamic> user) {
        if (user['select'] == true) {
          selectUsers.add(user);
        }
      });
    });
    return selectUsers;
  }

  @override
  void initState() {
    super.initState();

    _groupsModel = {
      '人事部': [
        {'name': '张三', 'select': false},
        {'name': '李四', 'select': false},
        {'name': '王五', 'select': false},
        {'name': '甲', 'select': false},
      ],
      '财务部': [
        {'name': '张三', 'select': false},
        {'name': '李四', 'select': false},
        {'name': '王五', 'select': false},
        {'name': '甲', 'select': false},
      ]
    };
  }

  void onConfirmPress() {
    Navigator.of(context).pop(selectedUser);
  }

  Widget buildContent() {
    List<Widget> widgets = new List();
    _groupsModel.forEach((String key, List<Map<String, dynamic>> value) {
      widgets.add(Container(
        color: Colors.white,
        child: new ExpansionTile(
          title: Text('$key(${value.length}人)'),
          backgroundColor: Colors.white,
          children: value.map((Map<String, dynamic> user) {
            return CheckboxListTile(
              value: user['select'],
              title: Row(
                children: <Widget>[Icon(Icons.people), Text('${user['name']}')],
              ),
              onChanged: (bool val) {
                user['select'] = val;
                setState(() {});
              },
            );
          }).toList(),
        ),
      ));
    });

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        children: widgets,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: newAppBar(context, '选择',
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(40),
            child: Container(
              child: Container(
                height: 32,
                margin: EdgeInsets.only(left: 10, right: 10, bottom: 8),
                alignment: Alignment.center,
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey,
                    ),
                    fillColor: Color(0xfff0f0f0),
                    filled: true,
                    hintText: '搜索',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                    enabled: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(style: BorderStyle.none),
                    ),
                    hintStyle:
                        TextStyle(color: Color(0xff999999), fontSize: 16),
                    labelStyle:
                        TextStyle(color: Color(0xff696969), fontSize: 16),
                  ),
                ),
              ),
            ),
          )),
      body: Container(
        color: Global.kBackgroundColor,
        child: Column(
          children: <Widget>[
            Expanded(
              child: buildContent(),
            ),
            Container(
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                  color: Color(0xfff0f0f0),
                  offset: Offset(0, -0.5),
                  blurRadius: 1,
                )
              ]),
              child: Row(
                children: <Widget>[
                  Text('已选择：${selectedUser.length}人'),
                  Spacer(),
                  RaisedButton(
                    disabledColor: Colors.grey,
                    color: Global.kTintColor,
                    child: Text(
                      '确定',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: onConfirmPress,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
