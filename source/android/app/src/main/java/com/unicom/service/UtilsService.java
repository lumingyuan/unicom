package com.unicom.service;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.FlutterView;

public class UtilsService {
    private static final String CHANNEL = "com.unicom.attendance/utils";

    private static UtilsService instance;
    public static UtilsService shareInstance() {
        if (instance == null) {
            instance = new UtilsService();
        }
        return instance;
    }

    private EventChannel.EventSink eventSink = null;
    /**
     * 注册flutter通道
     * @param flutterView
     */
    public void registerMethodChannel(FlutterView flutterView) {
        new MethodChannel(flutterView, CHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
                if ("getDeviceId".equals(methodCall.method)) {
                    result.success("deviceid");
                } else {
                    result.notImplemented();
                }
            }
        });
    }
}
