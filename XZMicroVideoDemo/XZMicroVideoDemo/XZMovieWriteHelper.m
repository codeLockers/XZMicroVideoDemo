//
//  XZMovieWriteHelper.m
//  XZMicroVideoDemo
//
//  Created by 徐章 on 16/9/2.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import "XZMovieWriteHelper.h"

@interface XZMovieWriteHelper ()

@property (nonatomic, strong) NSURL *recordURL;
@property (nonatomic, assign) CGSize cropSize;
@property (nonatomic, strong) AVAssetWriterInput *movieInput;
@property (nonatomic, strong) AVAssetWriterInput *audioInput;
@property (nonatomic, strong) AVAssetWriter *movieWriter;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *adaptor;

@end

@implementation XZMovieWriteHelper

- (id)initWithURL:(NSURL *)recordURL cropSize:(CGSize)cropSize{

    self = [super init];
    if (self) {
        
        self.recordURL = recordURL;
        self.cropSize = cropSize;
        [self prepareRecord];
    }
    
    return self;
}

- (void)prepareRecord{
    
    if (self.cropSize.height == 0 || self.cropSize.width == 0) {
        NSLog(@"请设置视屏尺寸");
        return;
    }
    
    //需要删除原来路径上的文件才能写入数据
    NSString *betaCompressionDirectory = [[self.recordURL absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    unlink([betaCompressionDirectory UTF8String]);
    
    NSError *error;
    self.movieWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:self.recordURL.absoluteString] fileType:AVFileTypeMPEG4 error:&error];
    if (error){
        NSLog(@"%@",error.description);
        return;
    }
    //视屏输入设置
    NSDictionary *movieSetting = @{
                                   AVVideoCodecKey:AVVideoCodecH264,
                                   AVVideoWidthKey:[NSNumber numberWithFloat:self.cropSize.width],
                                   AVVideoHeightKey:[NSNumber numberWithFloat:self.cropSize.height],
                                   AVVideoScalingModeKey:AVVideoScalingModeResizeAspectFill
                                   };
    
    self.movieInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:movieSetting];
    if (!self.movieInput) {
        NSLog(@"movieInput创建失败");
        return;
    }
    self.movieInput.expectsMediaDataInRealTime = YES;
    
    //缓冲区设置
    NSDictionary *sourcePixelBufferAttributesDic = @{
                                                     (id)kCVPixelBufferPixelFormatTypeKey:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB]
                                                     };
    self.adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.movieInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDic];
    
    [self.movieWriter addInput:self.movieInput];
    
    //音频输入设置
    AudioChannelLayout acl;
    bzero(&acl, sizeof(acl));
    acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
    
    NSDictionary *audioSetting = @{
                                   AVFormatIDKey:[NSNumber numberWithInt:kAudioFormatMPEG4AAC],
                                   AVEncoderBitRateKey:[NSNumber numberWithInt:64000],
                                   AVSampleRateKey:[NSNumber numberWithFloat: 44100.0],
                                   AVNumberOfChannelsKey:[NSNumber numberWithInt:1],
                                   AVChannelLayoutKey:[NSData dataWithBytes: &acl length: sizeof(acl)]
                                   };
    
    self.audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioSetting];
    self.audioInput.expectsMediaDataInRealTime = YES;
    
    [self.movieWriter addInput:self.audioInput];
    
    [self.movieWriter startWriting];
}

- (void)finishWrite:(void (^)(void))complete{

    if (self.movieWriter.status != AVAssetWriterStatusWriting)
        return;
    
    [self.movieInput markAsFinished];
    [self.movieWriter finishWritingWithCompletionHandler:^{
       
        NSLog(@"Record Finsh");
        if (complete)
            complete();
    }];
}


- (void)appendMovieBuffer:(CMSampleBufferRef)sampleBuffer{

    if (self.movieWriter.status != AVAssetWriterStatusWriting)
        return;
    
    [self.movieWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
    [self.movieInput appendSampleBuffer:sampleBuffer];
}

- (void)appendAudioBuffer:(CMSampleBufferRef)sampleBuffer{

    if (self.movieWriter.status != AVAssetWriterStatusWriting)
        return;
    
    [self.movieWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
    [self.audioInput appendSampleBuffer:sampleBuffer];
}
@end
