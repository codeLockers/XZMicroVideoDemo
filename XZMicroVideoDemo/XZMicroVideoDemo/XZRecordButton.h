//
//  XZRecordButton.h
//  XZMicroVideoDemo
//
//  Created by 徐章 on 16/9/2.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XZRecordButton;

@protocol XZRecordButtonDelegate <NSObject>

- (void)recordButtonPressedBegin:(XZRecordButton *)recordBtn;
- (void)recordButtonPressedEnd:(XZRecordButton *)recordBtn;

@end


@interface XZRecordButton : UIView

@property (nonatomic, weak) id<XZRecordButtonDelegate> delegate;

@end
