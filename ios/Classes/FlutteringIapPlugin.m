#import "FlutteringIapPlugin.h"
#if __has_include(<fluttering_iap/fluttering_iap-Swift.h>)
#import <fluttering_iap/fluttering_iap-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "fluttering_iap-Swift.h"
#endif

@implementation FlutteringIapPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutteringIapPlugin registerWithRegistrar:registrar];
}
@end
