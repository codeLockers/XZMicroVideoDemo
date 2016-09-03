//
//  XZMovieWriteHelper.h
//  XZMicroVideoDemo
//
//  Created by 徐章 on 16/9/2.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface XZMovieWriteHelper : NSObject

- (id)initWithURL:(NSURL *)url cropSize:(CGSize)cropSize;

- (void)finishWrite:(void(^)(void))complete;

- (void)appendMovieBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)appendAudioBuffer:(CMSampleBufferRef)sampleBuffer;
@end
