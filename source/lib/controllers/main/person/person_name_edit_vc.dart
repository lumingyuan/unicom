import 'package:unicom_attendance/global.dart';

class PersonNameEditVC extends StatelessWidget {
  final TextEditingController _controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: newAppBar(
          context,
          '姓名',
          actions: <Widget>[
            FlatButton(
              padding: EdgeInsets.all(0),
              child: Text('确定',
                  style: TextStyle(color: Theme.of(context).accentColor)),
              onPressed: () {
                Navigator.pop(context, _controller.text);
              },
            )
          ],
        ),
        body: Container(
          color: Global.kBackgroundColor,
          padding: EdgeInsets.only(top: 10),
          child: Container(
            height: 50,
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: CupertinoTextField(
              maxLines: 1,
              maxLength: 20,
              clearButtonMode: OverlayVisibilityMode.editing,
              controller: _controller,
              placeholder: '填写姓名',
              decoration: BoxDecoration(),
            ),
          ),
        ));
  }
}
