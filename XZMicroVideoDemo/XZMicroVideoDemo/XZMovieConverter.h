//
//  XZMovieConverter.h
//  XZMicroVideoDemo
//
//  Created by 徐章 on 16/9/3.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface XZMovieConverter : NSObject

+ (UIImage *)convertSampleBufferRefToUIImage:(CMSampleBufferRef)sampleBufferRef;

+ (void)converMovie:(NSURL *)moviePath toGIF:(NSURL *)gifPath;

@end
