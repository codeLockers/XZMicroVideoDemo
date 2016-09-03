//
//  XZMovieRecordHelper.m
//  XZMicroVideoDemo
//
//  Created by 徐章 on 16/9/2.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import "XZMovieRecordHelper.h"
#import "AssetsLibrary/ALAssetsLibrary.h"
#import <AVFoundation/AVFoundation.h>
#import "XZMovieWriteHelper.h"
#import "XZMovieConverter.h"


@interface XZMovieRecordHelper()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>{

    BOOL _isRecording;
}

@property (nonatomic, strong) AVCaptureSession *session;

@property (nonatomic, strong) AVCaptureConnection *cameraConnection;
@property (nonatomic, strong) AVCaptureConnection *audioConnection;

@property (nonatomic, strong) XZMovieWriteHelper *movieWriter;
@property (nonatomic, strong) NSURL *movieWriterPath;

@end


@implementation XZMovieRecordHelper

+ (XZMovieRecordHelper *)helper{

    static XZMovieRecordHelper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        helper = [[XZMovieRecordHelper alloc] init];
    });
    return helper;
}

#pragma mark - Public_Methods
- (void)authorizationStatus:(void(^)(BOOL status))result{

    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                result(granted);
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized:
            result(YES);
            break;
            
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            result(NO);
            break;
            
        default:
            break;
    }
}

- (void)showOnPreView:(UIView *)view{

    _isRecording = NO;
    
    //会话
    self.session = [[AVCaptureSession alloc] init];
    
    //配置会话
    [self.session beginConfiguration];
    
    //设置分辨率
    if ([self.session canSetSessionPreset:AVCaptureSessionPresetHigh])
        [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    //摄像头设备
    AVCaptureDevice *cameraDevice = [self cameraDeviceWithPosition:AVCaptureDevicePositionBack];
    
    //设置输入源
    NSError *error;
    AVCaptureDeviceInput *cameraDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:cameraDevice error:&error];
    if (!cameraDeviceInput || error){
        NSLog(@"创建摄像头输入失败");
        return;
    }
    if ([self.session canAddInput:cameraDeviceInput])
        [self.session addInput:cameraDeviceInput];
    
    //设置输出源
    AVCaptureVideoDataOutput *cameraDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    cameraDataOutput.videoSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };
    [cameraDataOutput setSampleBufferDelegate:self queue:dispatch_queue_create("videoDataOutput", DISPATCH_QUEUE_SERIAL)];
    cameraDataOutput.alwaysDiscardsLateVideoFrames = NO;
    if ([self.session canAddOutput:cameraDataOutput])
        [self.session addOutput:cameraDataOutput];
    self.cameraConnection = [cameraDataOutput connectionWithMediaType:AVMediaTypeVideo];
    //发抖模式
    if (self.cameraConnection.isVideoStabilizationSupported)
        self.cameraConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
    
    //方向修复
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    self.cameraConnection.videoOrientation = (AVCaptureVideoOrientation)orientation;
    
    //麦克风设备
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    //输入源
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    if (error || !audioInput)
        NSLog(@"创建摄像头输入失败");
    if ([self.session canAddInput:audioInput])
        [self.session addInput:audioInput];
    //输出源
    AVCaptureAudioDataOutput *audioOuput = [[AVCaptureAudioDataOutput alloc] init];
    [audioOuput setSampleBufferDelegate:self queue:dispatch_queue_create("audioDataOutput", DISPATCH_QUEUE_SERIAL)];
    if ([self.session canAddOutput:audioOuput])
        [self.session addOutput:audioOuput];
    self.audioConnection = [audioOuput connectionWithMediaType:AVMediaTypeAudio];
    
    //完成配置
    [self.session commitConfiguration];
    
    //创建预览视图
    AVCaptureVideoPreviewLayer *preLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    preLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preLayer.frame = view.bounds;
    [view.layer addSublayer:preLayer];
    [self.session startRunning];
    
}

- (void)finishRecord:(void(^)(NSString *gifPath))complete{
    
    if (!_isRecording)
        return;
    
    _isRecording = NO;
    [self.movieWriter finishWrite:^{
        
        //把视屏转成GIF
        NSString *fileName = @"movie.gif";
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        [XZMovieConverter converMovie:self.movieWriterPath toGIF:[NSURL fileURLWithPath:path]];
        
        NSLog(@"GIF Complete");
        
        if (complete)
            complete(path);
    }];
    

}

- (void)startRecord{

    _isRecording = YES;
}

#pragma mark - Private_Methods
/**
 *  获取摄像头设备
 *
 *  @param position 前置／后置
 *
 *  @return 摄像头设备
 */
- (AVCaptureDevice *)cameraDeviceWithPosition:(AVCaptureDevicePosition)position{

    NSArray *array = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *cameraDevice = array.firstObject;
    for (AVCaptureDevice *device in array) {
        if (device.position == position)
            cameraDevice = device;
    }
    return cameraDevice;
}

#pragma mark - AVCaptureVideoDataOutputSampleBuffer_Delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{

    if (!_isRecording)
        return;
    
    if (!self.movieWriter) {
        
        NSString *fileName = @"movie.mp4";
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        self.movieWriterPath = [NSURL URLWithString:path];
        self.movieWriter = [[XZMovieWriteHelper alloc] initWithURL:self.movieWriterPath cropSize:CGSizeMake(320.f, 320/4.0f*3.0f)];
//        self.imageArray = [NSMutableArray array];
    }
    if (connection == self.cameraConnection){
        
//        @autoreleasepool {
//            
//            UIImage *image = [XZMovieConverter convertSampleBufferRefToUIImage:sampleBuffer];
//            [self.imageArray addObject:image];
            [self.movieWriter appendMovieBuffer:sampleBuffer];
//        }
    }
    else if (connection == self.audioConnection)
        [self.movieWriter appendAudioBuffer:sampleBuffer];
}
@end
