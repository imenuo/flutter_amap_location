#import "FlutterAMapLocationPlugin.h"
#import <flutter_amap_location/flutter_amap_location-Swift.h>

@implementation FlutterAMapLocationPlugin
+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    [SwiftFlutterAMapLocationPlugin registerWithRegistrar:registrar];
}
@end
