//
//  ScanImageInfo.m
//  hyperlpr_flutter
//
//  Created by shenjk on 2020/3/20.
//

#ifdef __cplusplus
#include <opencv2/opencv.hpp>
#include <opencv2/imgcodecs/ios.h>
#include <opencv2/stitching/detail/blenders.hpp>
#include <opencv2/stitching/detail/exposure_compensate.hpp>
#include "Pipeline.h"
#endif

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Flutter/Flutter.h>
#endif




@interface ScanImageInfo : NSObject

+ (void) Scan:(NSDictionary*) args result:(FlutterResult) result;
@end

