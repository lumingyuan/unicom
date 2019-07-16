#import "JaemobirdPermissionsPlugin.h"
#import <AVKit/AVKit.h>
#import <Contacts/Contacts.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import <Photos/Photos.h>

@interface JaemobirdPermissionsPlugin() <CLLocationManagerDelegate>
@property(nonatomic, strong) CLLocationManager* locationManager;
@property(nonatomic, assign) BOOL whenInUse;
@property(nonatomic, strong) FlutterResult result;

@end

@implementation JaemobirdPermissionsPlugin
- (CLLocationManager*)locationManager {
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"jaemobird_permissions"
                                     binaryMessenger:[registrar messenger]];
    JaemobirdPermissionsPlugin* instance = [[JaemobirdPermissionsPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else if ([@"checkPermission" isEqualToString:call.method]) {
        if (call.arguments != nil && [call.arguments objectForKey:@"permission"] != nil) {
            NSString* permission = [call.arguments objectForKey:@"permission"];
            [self checkPermission:permission Result:result];
        } else {
            result([FlutterError errorWithCode:@"permission missing" message:nil details:nil]);
        }
    } else if ([@"getPermissionStatus" isEqualToString:call.method]) {
        if (call.arguments != nil && [call.arguments objectForKey:@"permission"] != nil) {
            NSString* permission = [call.arguments objectForKey:@"permission"];
            [self getPermissionStatus:permission Result:result];
        } else {
            result([FlutterError errorWithCode:@"permission missing" message:nil details:nil]);
        }
    } else if ([@"requestPermission" isEqualToString:call.method]) {
        if (call.arguments != nil &&  [call.arguments objectForKey:@"permission"] != nil) {
            NSString* permission = [call.arguments objectForKey:@"permission"];
            [self requestPermission:permission Result:result];
        } else {
            result([FlutterError errorWithCode:@"permission missing" message:nil details:nil]);
        }
    } else if ([@"openSettings" isEqualToString:call.method]) {
        NSURL* url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:url];
            }
            result(@(YES));
        } else {
            result(FlutterMethodNotImplemented);
        }
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)checkPermission:(NSString*)permission Result:(FlutterResult)result {
    BOOL authorized = NO;
    if ([@"RECORD_AUDIO" isEqualToString:permission]) {
        authorized = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio] == AVAuthorizationStatusAuthorized;
    } else if ([@"READ_CONTACTS" isEqualToString:permission] || [@"WRITE_CONTACTS" isEqualToString:permission]) {
        if (@available(iOS 9.0, *)) {
            authorized = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized;
        } else {
            // Fallback on earlier versions
            authorized = YES;
        }
    } else if ([@"CAMERA" isEqualToString:permission]) {
        authorized = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusAuthorized;
    } else if ([@"PHOTO_LIBRARY" isEqualToString:permission]) {
        authorized = [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized;
    } else if ([@"ACCESS_COARSE_LOCATION" isEqualToString:permission] ||
               [@"ACCESS_FINE_LOCATION" isEqualToString:permission] ||
               [@"WHEN_IN_USE_LOCATION" isEqualToString:permission]) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
            authorized = YES;
        }
    } else if ([@"ALWAYS_LOCATION" isEqualToString:permission]) {
        authorized = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways;
    } else if ([@"READ_SMS" isEqualToString:permission] ||
               [@"SEND_SMS" isEqualToString:permission]) {
        authorized = YES;
    } else if ([@"MOTION_SENSOR" isEqualToString:permission]) {
        authorized = [self checkMotionSensorPermission];
    } else {
        result(FlutterMethodNotImplemented);
        return;
    }
    result(@(authorized));
}

- (void)getPermissionStatus:(NSString*)permission Result:(FlutterResult)result {
    int status = 1;
    if ([@"RECORD_AUDIO" isEqualToString:permission]) {
        status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    } else if ([@"READ_CONTACTS" isEqualToString:permission] || [@"WRITE_CONTACTS" isEqualToString:permission]) {
        if (@available(iOS 9.0, *)) {
            status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        } else {
            // Fallback on earlier versions
        }
    } else if ([@"CAMERA" isEqualToString:permission]) {
        status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    } else if ([@"PHOTO_LIBRARY" isEqualToString:permission]) {
        status = [PHPhotoLibrary authorizationStatus];
    } else if ([@"ACCESS_COARSE_LOCATION" isEqualToString:permission] ||
               [@"ACCESS_FINE_LOCATION" isEqualToString:permission] ||
               [@"WHEN_IN_USE_LOCATION" isEqualToString:permission]) {
        status = [CLLocationManager authorizationStatus];
        if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
            status = 3;
        }
    } else if ([@"ALWAYS_LOCATION" isEqualToString:permission]) {
        status = [CLLocationManager authorizationStatus];
        if (status == kCLAuthorizationStatusAuthorizedAlways) {
            status = 3;
        } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
            status = 1;
        }
    } else if ([@"READ_SMS" isEqualToString:permission] ||
               [@"SEND_SMS" isEqualToString:permission]) {
        status = 1;
    } else if ([@"MOTION_SENSOR" isEqualToString:permission]) {
        status = [self getMotionSensorPermissionStatus];
    } else {
        result(FlutterMethodNotImplemented);
        return;
    }
    result(@(status));
}

- (void)requestPermission:(NSString*)permission Result:(FlutterResult)result {
    if ([@"RECORD_AUDIO" isEqualToString:permission]) {
        if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                result(@(granted));
            }];
        } else {
            result(@(NO));
        }
    } else if ([@"READ_CONTACTS" isEqualToString:permission] || [@"WRITE_CONTACTS" isEqualToString:permission]) {
        if (@available(iOS 9.0, *)) {
            CNContactStore* store = [[CNContactStore alloc] init];
            [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                result(@(granted));
            }];
        } else {
            result(@(NO));
        }
    } else if ([@"CAMERA" isEqualToString:permission]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            result(@(granted));
        }];
    }  else if ([@"PHOTO_LIBRARY" isEqualToString:permission]) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            result(@(status == PHAuthorizationStatusAuthorized));
        }];
    } else if ([@"ACCESS_COARSE_LOCATION" isEqualToString:permission] ||
               [@"ACCESS_FINE_LOCATION" isEqualToString:permission] ||
               [@"WHEN_IN_USE_LOCATION" isEqualToString:permission]) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            self.result = result;
            self.whenInUse = YES;
            [self.locationManager requestWhenInUseAuthorization];
        } else {
            bool granted = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse;
            result(@(granted));
        }
    } else if ([@"ALWAYS_LOCATION" isEqualToString:permission]) {
        self.result = result;
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            self.whenInUse = NO;
            [self.locationManager requestAlwaysAuthorization];
        } else {
            bool granted = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways;
            result(@(granted));
        }
    } else if ([@"READ_SMS" isEqualToString:permission] ||
               [@"SEND_SMS" isEqualToString:permission]) {
        result(@(YES));
    } else if ([@"MOTION_SENSOR" isEqualToString:permission]) {
        if ([self getMotionSensorPermissionStatus] == 0) {
            CMPedometer* pedometer = [[CMPedometer alloc] init];
            NSDate* now = [[NSDate alloc] init];
            [pedometer queryPedometerDataFromDate:now toDate:[now dateByAddingTimeInterval:-1.0] withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
                if (error != nil) {
                    if (error.code == CMErrorMotionActivityNotAuthorized) {
                        result(@(NO));
                    } else {
                        result(@(NO));
                    }
                } else {
                    result(@(YES));
                }
            }];
        } else {
            result(@([self checkMotionSensorPermission]));
        }
    } else {
        result(FlutterMethodNotImplemented);
        return;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status != kCLAuthorizationStatusNotDetermined) {
        if (self.whenInUse) {
            if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
                self.result(@(YES));
            } else {
                self.result(@(NO));
            }
        } else {
            self.result(@(status == kCLAuthorizationStatusAuthorizedAlways));
        }
    }
}

- (int) getMotionSensorPermissionStatus {
    int status = 0;
    if (@available(iOS 11.0, *)) {
        status = [CMPedometer authorizationStatus];
    } else {
        if (@available(iOS 9.0, *)) {
            status = [CMSensorRecorder isAuthorizedForRecording] ? 3 : 2;
        } else {
            // Fallback on earlier versions
            status = 1;
        }
    }
    return status;
}

- (BOOL) checkMotionSensorPermission {
    BOOL authorized;
    if (@available(iOS 11.0, *)) {
        authorized = [CMPedometer authorizationStatus] == CMAuthorizationStatusAuthorized;
    } else {
        if (@available(iOS 9.0, *)) {
            authorized = [CMSensorRecorder isAuthorizedForRecording];
        } else {
            // Fallback on earlier versions
            authorized = YES;
        }
    }
    return authorized;
}

@end
