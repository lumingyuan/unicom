//
//  UtilsManager.h
//  Runner
//
//  Created by 米来 on 2019/1/7.
//  Copyright © 2019年 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface UtilsManager : NSObject

+ (UtilsManager *) shareInstance;

//注册通道
- (void)registerMethodChannel:(FlutterViewController*)flutter;

@end

NS_ASSUME_NONNULL_END
