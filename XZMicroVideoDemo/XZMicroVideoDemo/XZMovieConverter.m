//
//  XZMovieConverter.m
//  XZMicroVideoDemo
//
//  Created by 徐章 on 16/9/3.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import "XZMovieConverter.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation XZMovieConverter

+ (CGImageRef)convertSamepleBufferRefToCGImage:(CMSampleBufferRef)sampleBufferRef
{
    @autoreleasepool {
        
        // Get a CMSampleBuffer's Core Video image buffer for the media data
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBufferRef);
        // Lock the base address of the pixel buffer
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        
        // Get the number of bytes per row for the pixel buffer
        void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
        
        // Get the number of bytes per row for the pixel buffer
        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        // Get the pixel buffer width and height
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        
        // Create a device-dependent RGB color space
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        // Create a bitmap graphics context with the sample buffer data
        CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                     bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        // Create a Quartz image from the pixel data in the bitmap graphics context
        CGImageRef quartzImage = CGBitmapContextCreateImage(context);
        // Unlock the pixel buffer
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
        
        // Free up the context and color space
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        
        return quartzImage;
    }
    
}


+ (UIImage *)convertSampleBufferRefToUIImage:(CMSampleBufferRef)sampleBufferRef{

    @autoreleasepool {
        
        CGImageRef cgImage = [self convertSamepleBufferRefToCGImage:sampleBufferRef];
        UIImage *image;

        CGFloat height = CGImageGetHeight(cgImage);
        CGFloat width = CGImageGetWidth(cgImage);
        
        height = height / 5;
        width = width / 5;

        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, [UIScreen mainScreen].scale);
        
#define UseUIImage 0
#if UseUIImage
        
        [image drawInRect:CGRectMake(0, 0, width, height)];
#else
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);
        
#endif
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGImageRelease(cgImage);
        UIGraphicsEndImageContext();
        return image;
    }
}

+ (void)converMovie:(NSURL *)moviePath toGIF:(NSURL *)gifPath{

    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:moviePath.absoluteString]];
    NSError *error;
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    if (error)
        return;
    
    NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *videoTrack = videoTracks.firstObject;
    if (!videoTrack)
        return;
    
    int m_pixelFormatType;
    //视频播放时，
    m_pixelFormatType = kCVPixelFormatType_32BGRA;
    
    AVAssetReaderTrackOutput *videoReaderOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:@{(id)kCVPixelBufferPixelFormatTypeKey:@(m_pixelFormatType)}];
    
    if ([reader canAddOutput:videoReaderOutput])
        [reader addOutput:videoReaderOutput];
    [reader startReading];
    
    NSMutableArray *images = [NSMutableArray array];
    // 要确保nominalFrameRate>0，之前出现过android拍的0帧视频
    while ([reader status] == AVAssetReaderStatusReading && videoTrack.nominalFrameRate > 0) {
        @autoreleasepool {
            // 读取 video sample
            CMSampleBufferRef videoBuffer = [videoReaderOutput copyNextSampleBuffer];
            
            if (!videoBuffer)
                break;
            
            [images addObject:[self convertSampleBufferRefToUIImage:videoBuffer]];
            CFRelease(videoBuffer);
        }
    }
    
    //时长
    NSTimeInterval duration = CMTimeGetSeconds(asset.duration);
    
    [self generateGIFFileWithImages:images duration:duration gifPath:gifPath];
}

+ (void)generateGIFFileWithImages:(NSArray *)imageArray duration:(NSTimeInterval)duration gifPath:(NSURL *)gifPath{
    
//        NSString *betaCompressionDirectory = [[gifPath absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
//    
//    if ([[NSFileManager defaultManager] fileExistsAtPath:betaCompressionDirectory]) {
//        NSLog(@"存在");
//        NSError *error;
//        [[NSFileManager defaultManager] removeItemAtPath:betaCompressionDirectory error:&error];
//        if (!error) {
//            
//            NSLog(@"delete success");
//        }
//    }
    
    
    NSTimeInterval perSecond = duration /imageArray.count;
    
    NSDictionary *fileProperties = @{
                                     (__bridge id)kCGImagePropertyGIFDictionary: @{
                                            (__bridge id)kCGImagePropertyGIFLoopCount: @0, // 0 means loop forever
                                             }
                                     };
    
    NSDictionary *frameProperties = @{
                                      (__bridge id)kCGImagePropertyGIFDictionary: @{
                                              (__bridge id)kCGImagePropertyGIFDelayTime: @(perSecond), // a float (not double!) in seconds, rounded to centiseconds in the GIF data
                                              }
                                      };
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)gifPath, kUTTypeGIF, imageArray.count, NULL);
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)fileProperties);
    
    for (UIImage *image in imageArray) {
        @autoreleasepool {
            CGImageDestinationAddImage(destination, image.CGImage, (__bridge CFDictionaryRef)frameProperties);
        }
    }
    
    if (!CGImageDestinationFinalize(destination)) {
        NSLog(@"failed to finalize image destination");
    }else{
        
        
    }
    CFRelease(destination);
}


@end
