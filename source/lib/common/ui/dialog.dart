import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter/material.dart';

Future<bool> showAlertDialog(BuildContext context, String title, String content,
    {bool cancel = true,
    bool confirm = true,
    String confirmText = '确定'}) async {
  List<Widget> actions = new List();
  if (cancel) {
    actions.add(CupertinoButton(
      child: new Text("取消"),
      onPressed: () {
        Navigator.of(context).pop(false);
      },
    ));
  }
  if (confirm) {
    actions.add(CupertinoButton(
      child: new Text("$confirmText"),
      onPressed: () {
        Navigator.of(context).pop(true);
      },
    ));
  }

  return showCupertinoDialog(
      context: context,
      builder: (_) {
        return new CupertinoApp(
            home: new CupertinoAlertDialog(
                title: new Text("$title"),
                content: Container(
                  margin: EdgeInsets.only(top: 20),
                  child: new Text("$content"),
                ),
                actions: actions));
      });
}

///actions 格式为
/// [{"title":"", "value":..} ...]
///
Future<dynamic> showActionSheetDialog(
    BuildContext context, String title, List<Map> actions) async {
  List<Widget> actionWidgets = new List();
  for (Map action in actions) {
    actionWidgets.add(CupertinoActionSheetAction(
      onPressed: () {
        Navigator.of(context).pop(action['value']);
      },
      isDestructiveAction: false,
      child: Text('${action['title']}'),
    ));
  }

  return await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          actions: actionWidgets,
          message: title == null ? null : Text('$title'),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('取消'),
            isDestructiveAction: true,
          ),
        );
      });
}

Future<String> showInputDialog(
    BuildContext context, String title, String placeholder,
    {bool cancel = true, bool confirm = true, int maxLength}) async {
  List<Widget> actions = new List();
  TextEditingController controller = new TextEditingController();
  if (cancel) {
    actions.add(CupertinoButton(
      child: new Text("取消"),
      onPressed: () {
        Navigator.of(context).pop(null);
      },
    ));
  }
  if (confirm) {
    actions.add(CupertinoButton(
      child: new Text("确定"),
      onPressed: () {
        Navigator.of(context).pop(controller.text);
      },
    ));
  }

  return showDialog(
      context: context,
      builder: (_) => AlertDialog(
            title: Text('$title'),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 0),
            content: Container(
              width: MediaQuery.of(context).size.width - 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                      side: BorderSide(color: Color(0xfff0f0f0), width: 1),
                      borderRadius: BorderRadius.circular(3),
                    )),
                    child: TextField(
                      maxLines: 4,
                      maxLength: maxLength,
                      controller: controller,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(0),
                        hintText: '$placeholder',
                        hintStyle: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                  Navigator.of(context).pop(controller.text);
                },
              )
            ],
          ));
}
