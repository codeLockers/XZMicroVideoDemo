//
//  XZPreViewViewController.m
//  XZMicroVideoDemo
//
//  Created by 徐章 on 16/9/3.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import "XZPreViewViewController.h"
#import "UIImageView+PlayGIF.h"

@interface XZPreViewViewController ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation XZPreViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@",self.gifPath);
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 150)];
    self.imageView.center = self.view.center;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.gifPath = self.gifPath;
    [self.imageView startGIF];
    
    self.imageView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.imageView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
