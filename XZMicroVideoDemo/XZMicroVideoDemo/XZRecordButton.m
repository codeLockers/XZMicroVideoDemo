//
//  XZRecordButton.m
//  XZMicroVideoDemo
//
//  Created by 徐章 on 16/9/2.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import "XZRecordButton.h"

@implementation XZRecordButton

- (id)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor greenColor];
        
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesture_Method:)];
        [self addGestureRecognizer:longGesture];
        
    }
    return self;
}

#pragma mark - UIGesture_Methods
- (void)longGesture_Method:(UILongPressGestureRecognizer *)longGesture{

    switch (longGesture.state) {

        case UIGestureRecognizerStateBegan: {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(recordButtonPressedBegin:)]) {
                [self.delegate recordButtonPressedBegin:self];
            }
            
            break;
        }
        case UIGestureRecognizerStateChanged: {
            //NSLog(@"change");
            break;
        }
        case UIGestureRecognizerStateEnded: {
            if (self.delegate && [self.delegate respondsToSelector:@selector(recordButtonPressedEnd:)]) {
                [self.delegate recordButtonPressedEnd:self];
            }
            break;
        }
        case UIGestureRecognizerStateCancelled: {
           // NSLog(@"cancel");
            self.backgroundColor = [UIColor greenColor];
            break;
        }
        case UIGestureRecognizerStateFailed: {
            //NSLog(@"fail");
            self.backgroundColor = [UIColor greenColor];
            break;
        }
        default:
            break;

    }
    
}



@end
