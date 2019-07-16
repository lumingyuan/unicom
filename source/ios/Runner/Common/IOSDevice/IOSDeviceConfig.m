//
//  IOSDeviceConfig.m
//  Runner
//
//  Created by 米来 on 2019/1/7.
//  Copyright © 2019年 The Chromium Authors. All rights reserved.
//

#import "IOSDeviceConfig.h"

@implementation IOSDeviceConfig

static IOSDeviceConfig *_sharedConfig = nil;

//@synthesize deviceUUID = _deviceUUID;
+ (IOSDeviceConfig *)sharedConfig
{
    @synchronized(_sharedConfig)
    {
        if (_sharedConfig == nil) {
            _sharedConfig = [[IOSDeviceConfig alloc] init];
        }
        return _sharedConfig;
    }
}

+(NSString *) getDeviceIDInKeychain {
    NSString* key = [NSString stringWithFormat:@"%@.udid.key", [[NSBundle mainBundle] bundleIdentifier]];
    
    NSString *getUDIDInKeychain = (NSString *)[[IOSDeviceConfig sharedConfig] load:key];
    if (!getUDIDInKeychain ||[getUDIDInKeychain isEqualToString:@""]||[getUDIDInKeychain isKindOfClass:[NSNull class]]) {
        CFUUIDRef puuid = CFUUIDCreate( nil );
        CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
        NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
        CFRelease(puuid);
        CFRelease(uuidString);
        [[IOSDeviceConfig sharedConfig] save:key data:result];
        getUDIDInKeychain = (NSString *)[[IOSDeviceConfig sharedConfig] load:key];
    }
    return getUDIDInKeychain;
}

- (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Configure the search setting
    //Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    if (keyData)
        CFRelease(keyData);
    return ret;
}

-(void) save:(NSString *)service data:(id)data {
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Delete old item before add new item
    SecItemDelete((CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    //Add item to keychain with the search dictionary
    SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
}

-(void) delete:(NSString *)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}

-(NSMutableDictionary *) getKeychainQuery:(NSString *)key {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:(__bridge id)kSecClassGenericPassword, (__bridge id)kSecClass,
            key, (__bridge id)kSecAttrService, key, (__bridge id)kSecAttrAccount, (__bridge id)kSecAttrAccessibleAfterFirstUnlock,(__bridge id)kSecAttrAccessible, nil];
    
}


+ (int)versionCode {
    //此获取的版本号对应bundle，打印出来对应为12345这样的数字
    NSNumber *number = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
    return [number intValue];
}

+ (NSString *)versionString {
    //此获取的版本号对应version，打印出来对应为1.2.3.4.5这样的字符串
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

@end
