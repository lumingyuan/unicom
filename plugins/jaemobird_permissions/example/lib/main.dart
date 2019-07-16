import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:jaemobird_permissions/jaemobird_permissions.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await JaemobirdPermissions.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Running on: $_platformVersion\n'),
              FlatButton(
                onPressed: () {
                  JaemobirdPermissions.checkPermission(Permission.WhenInUseLocation).then((ret){
                    print('checkPermission $ret');
                  });
                },
                child: Text('checkPermission'),
              ),
              FlatButton(
                onPressed: () {
                  JaemobirdPermissions.getPermissionStatus(Permission.WhenInUseLocation).then((ret){
                    print('getPermissionStatus $ret');
                  });
                },
                child: Text('getPermissionStatus'),
              ),
              FlatButton(
                onPressed: () {
                  JaemobirdPermissions.requestPermission(Permission.WhenInUseLocation).then((ret){
                    print('requestPermission $ret');
                  });
                },
                child: Text('requestPermission'),
              ),
              FlatButton(
                onPressed: () {
                  JaemobirdPermissions.openSettings().then((ret) {
                    print('openSettings $ret');
                  });
                },
                child: Text('openSettings'),
              ),
            ],
          ) 
        ),
      ),
    );
  }
}
