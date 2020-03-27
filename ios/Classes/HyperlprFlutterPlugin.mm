
#import "ScanImageInfo.h"

#import "HyperlprFlutterPlugin.h"
#define FlutterPluginName "com.shenjk/hyperlpr_flutter"



@implementation HyperlprFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@FlutterPluginName
            binaryMessenger:[registrar messenger]];
  HyperlprFlutterPlugin* instance = [[HyperlprFlutterPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if([@"scanImage" isEqualToString:call.method]){
    [ScanImageInfo Scan:call.arguments result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
