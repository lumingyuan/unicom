//
//  UtilsManager.m
//  Runner
//
//  Created by 米来 on 2019/1/7.
//  Copyright © 2019年 The Chromium Authors. All rights reserved.
//

#include "UtilsManager.h"
#include "IOSDeviceConfig.h"

#define kUtilsChannelIdentifier @"com.unicom.attendance/utils"

static UtilsManager* g_manager = nil;
@implementation UtilsManager

+(UtilsManager *) shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_manager = [[UtilsManager alloc] init];
    });
    return g_manager;
}

- (void)registerMethodChannel:(FlutterViewController *)flutter {
    if (flutter == nil) {
        return;
    }
    
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:kUtilsChannelIdentifier binaryMessenger:flutter];
    [channel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
        if ([@"getDeviceId" isEqualToString:call.method]) {
            result([IOSDeviceConfig getDeviceIDInKeychain]); //获取设备唯一标识
        } else {
            @throw [FlutterError errorWithCode:@"invaild method" message:[NSString stringWithFormat:@"method:%@", call.method] details:nil];
        }
    }];
}

@end
