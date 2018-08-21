#import "FlutterAmapLocationPlugin.h"
#import <flutter_amap_location/flutter_amap_location-Swift.h>

@implementation FlutterAmapLocationPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterAmapLocationPlugin registerWithRegistrar:registrar];
}
@end
