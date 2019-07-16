package com.unicom.attendance;

import android.os.Bundle;

import com.unicom.service.UtilsService;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        GeneratedPluginRegistrant.registerWith(this);

        //注册flutter通道
        UtilsService.shareInstance().registerMethodChannel(getFlutterView());
    }

}
