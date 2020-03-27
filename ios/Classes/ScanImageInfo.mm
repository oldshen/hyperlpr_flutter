//
//  ScanImageInfo.m
//  hyperlpr_flutter
//
//  Created by shenjk on 2020/3/16.
//
#include <opencv2/imgproc/imgproc_c.h>
#import "ScanImageInfo.h"

//PipelinePRusing namespace pr;

@implementation ScanImageInfo
+ (void) Scan:(NSDictionary*) args result:(FlutterResult) result
{
    const FlutterStandardTypedData* typedData = args[@"byteList"][0];
    const int height = [args[@"height"] intValue];
    const int width = [args[@"width"] intValue];
    
    uint8_t* bytes = (uint8_t*)[[typedData data] bytes];
//    cv::Mat cvmat;//(height, width, CV_8UC3,bytes);
    cv::Mat cvmat= cvMatFromUint8_t(bytes,width,height);
    simpleRecognition(cvmat, result);
}

static CGImageRef cgImageReffromUint8_t(uint8_t * bytes,size_t w,size_t h){
    const size_t bitPerCompent=8;
    const size_t bitPreRow=((bitPerCompent*w)/8)*4;
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx=CGBitmapContextCreate(bytes, w, h, bitPerCompent, bitPreRow, colorSpace, kCGImageAlphaPremultipliedLast);
    CGImageRef toCGImage=CGBitmapContextCreateImage(ctx);
    return toCGImage;
}
static cv::Mat cvMatFromUint8_t(uint8_t *bytes,size_t width,size_t height)
{
    CGImageRef cgImageRef=cgImageReffromUint8_t(bytes,width,height);
    CGColorSpaceRef colorSpace =CGImageGetColorSpace(cgImageRef);
    CGFloat cols = width;
    CGFloat rows = height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), cgImageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    cv::Mat cvMat3(rows, cols, CV_8UC3); // 8 bits per component, 4 channels
    cv::cvtColor(cvMat, cvMat3,cv::COLOR_RGBA2RGB);
    
    return cvMat3;
}

static pr::PipelinePR getPRWrapper(){
    NSString *path_1 = getPath(@"cascade.xml");
    NSString *path_2 = getPath(@"HorizonalFinemapping.prototxt");
    NSString *path_3 = getPath(@"HorizonalFinemapping.caffemodel");
    NSString *path_4 = getPath(@"Segmentation.prototxt");
    NSString *path_5 = getPath(@"Segmentation.caffemodel");
    NSString *path_6 = getPath(@"CharacterRecognization.prototxt");
    NSString *path_7 = getPath(@"CharacterRecognization.caffemodel");
    NSString *path_8 = getPath(@"SegmenationFree-Inception.prototxt");
    NSString *path_9 = getPath(@"SegmenationFree-Inception.caffemodel");
    
    std::string *cpath_1 = new std::string([path_1 UTF8String]);
    std::string *cpath_2 = new std::string([path_2 UTF8String]);
    std::string *cpath_3 = new std::string([path_3 UTF8String]);
    std::string *cpath_4 = new std::string([path_4 UTF8String]);
    std::string *cpath_5 = new std::string([path_5 UTF8String]);
    std::string *cpath_6 = new std::string([path_6 UTF8String]);
    std::string *cpath_7 = new std::string([path_7 UTF8String]);
    std::string *cpath_8 = new std::string([path_8 UTF8String]);
    std::string *cpath_9 = new std::string([path_9 UTF8String]);
    
    return pr::PipelinePR(*cpath_1, *cpath_2, *cpath_3, *cpath_4, *cpath_5, *cpath_6, *cpath_7, *cpath_8, *cpath_9);
}

static void simpleRecognition(cv::Mat&src ,FlutterResult result)
{

    pr::PipelinePR pr2 = getPRWrapper();
    std::vector<pr::PlateInfo> list_res = pr2.RunPiplineAsImage(src, pr::SEGMENTATION_FREE_METHOD);
    std::string concat_results = "";
    cv::Mat cvMatRes;
    for(auto one:list_res) {
        if(one.confidence>0.7) {
            concat_results += one.getPlateName()+",";
            cvMatRes=one.getPlateImage();
        }
    }
    
    NSString *str = [NSString stringWithCString:concat_results.c_str() encoding:NSUTF8StringEncoding];
    if (str.length > 0) {
        str = [str substringToIndex:str.length-1];
        str = [NSString stringWithFormat:@"%@",str];
        
        NSMutableDictionary* resultDict = [NSMutableDictionary new];
        resultDict[@"number"] = str;
        resultDict[@"bytes"]=cvMat2NSData(cvMatRes);
        result(resultDict);
    } else {
         NSMutableDictionary* empty = [NSMutableDictionary new];
        result(empty);
    }
}

static NSData * cvMat2NSData(cv::Mat cvMat){
//       NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
//    return  data;
    UIImage* image=UIImageFromCVMat(cvMat);
     NSData *imageData = UIImagePNGRepresentation(image);
    return imageData;
}
static UIImage * UIImageFromCVMat (cv::Mat cvMat)
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}
static NSString* getPath(NSString* fileName)
{
    NSString * m_name=[@"assets/model/" stringByAppendingString:fileName];
    NSString * file=[ FlutterDartProject lookupKeyForAsset:m_name  fromPackage:@"hyperlpr_flutter"];
    NSString *bundlePath = [NSBundle mainBundle].bundlePath;
    NSString *path = [bundlePath stringByAppendingPathComponent:file];
    return path;
}

@end
