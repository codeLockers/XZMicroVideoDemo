//
//  XZRecordViewController.m
//  XZMicroVideoDemo
//
//  Created by 徐章 on 16/9/2.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import "XZRecordViewController.h"
#import "XZRecordButton.h"
#import "XZMovieRecordHelper.h"
#import "XZPreViewViewController.h"

#define UIScreen_Height [UIScreen mainScreen].bounds.size.height
#define UIScreen_Width [UIScreen mainScreen].bounds.size.width

@interface XZRecordViewController ()<XZRecordButtonDelegate>

@property (nonatomic, strong) XZRecordButton *recordBtn;
@property (nonatomic, strong) UIView *preView;
@property (nonatomic, strong) CALayer *progressLayer;
@property (nonatomic, strong) XZMovieRecordHelper *movieRecordeHelper;

@end

@implementation XZRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadUI];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Load_UI
- (void)loadUI{

    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"拍摄";
    [self loadRecordBtn];
    [self loadPreView];
    [self loadProgressView];
}

- (void)loadRecordBtn{

    self.recordBtn = [[XZRecordButton alloc] initWithFrame:CGRectMake((UIScreen_Width - 100)/2.0f, UIScreen_Height - 200, 100, 100)];
    self.recordBtn.delegate = self;
    [self.view addSubview:self.recordBtn];
}

- (void)loadPreView{

    self.preView = [[UIView alloc] initWithFrame:CGRectMake(0, 64.0f, UIScreen_Width, UIScreen_Width/4.0f*3.0f)];
    self.preView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.preView];
    
    self.movieRecordeHelper = [XZMovieRecordHelper helper];
    [self.movieRecordeHelper authorizationStatus:^(BOOL status) {
       
        if (status)
            [self.movieRecordeHelper showOnPreView:self.preView];
        
    }];
    
    
}

- (void)loadProgressView{

    self.progressLayer = [[CALayer alloc] init];
    self.progressLayer.bounds = CGRectMake(0, 0, UIScreen_Width, 5.0f);
    self.progressLayer.position = CGPointMake(UIScreen_Width/2.0f, CGRectGetHeight(self.preView.frame)-5.0/2.0f);
    self.progressLayer.backgroundColor = [UIColor blueColor].CGColor;
    [self.preView.layer addSublayer:self.progressLayer];
}

#pragma mark - Private_Methods
- (void)progressViewStartAnimation{

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    animation.duration          = 10.0f;
    animation.fromValue         = @1;
    animation.toValue           = @0;
    animation.delegate          = self;
    animation.removedOnCompletion = NO;
    [self.progressLayer addAnimation:animation forKey:@"progressLayerAniamtion"];
}

#pragma mark - CAAnimation_Delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{

    if (!flag)
        return;
    if (anim == [self.progressLayer animationForKey:@"progressLayerAniamtion"]) {
//        [self.movieRecordeHelper finishRecord];
//        [self.progressLayer removeAllAnimations];
    }
}


#pragma mark - XZRecordButton_Delegate
- (void)recordButtonPressedBegin:(XZRecordButton *)recordBtn{

    recordBtn.backgroundColor = [UIColor redColor];
    [self.movieRecordeHelper startRecord];
    [self progressViewStartAnimation];
}

- (void)recordButtonPressedEnd:(XZRecordButton *)recordBtn{

    recordBtn.backgroundColor = [UIColor redColor];
    [self.progressLayer removeAllAnimations];
    [self.movieRecordeHelper finishRecord:^(NSString *gifPath) {
        
        XZPreViewViewController *preViewVc = [[XZPreViewViewController alloc] init];
        preViewVc.gifPath = gifPath;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:preViewVc animated:YES];
        });
    }];
}
@end
