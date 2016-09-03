//
//  XZMovieRecordHelper.h
//  XZMicroVideoDemo
//
//  Created by 徐章 on 16/9/2.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XZMovieRecordHelper : NSObject

+ (XZMovieRecordHelper *)helper;

- (void)authorizationStatus:(void(^)(BOOL status))result;
- (void)showOnPreView:(UIView *)view;
- (void)startRecord;
- (void)finishRecord:(void(^)(NSString *gifPath))complete;
@end
