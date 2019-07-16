//
//  IOSDeviceConfig.h
//  Runner
//
//  Created by 米来 on 2019/1/7.
//  Copyright © 2019年 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IOSDeviceConfig : NSObject

/**
 本方法是得到 UUID 后存入系统中的 keychain 的方法
 不用添加 plist 文件
 程序删除后重装,仍可以得到相同的唯一标示
 但是当系统升级或者刷机后,系统中的钥匙串会被清空,此时本方法失效
 */
+(NSString *) getDeviceIDInKeychain;

// 获取版本号
+ (int) versionCode;
+ (NSString*) versionString;
@end

NS_ASSUME_NONNULL_END
