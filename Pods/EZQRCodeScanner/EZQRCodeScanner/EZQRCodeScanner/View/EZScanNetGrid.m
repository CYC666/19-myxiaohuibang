//
//  EZScanNetGrid.m
//  EZQRCodeScanner
//
//  Created by ezfen on 16/5/20.
//  Copyright © 2016年 Ezfen Cheung. All rights reserved.
//

#import "EZScanNetGrid.h"

@interface EZScanNetGrid()
@property (nonatomic) CGRect initFrame;
@end

@implementation EZScanNetGrid

- (void)setShowView:(UIView *)showView {
    CGRect frame = showView.frame;
    frame.origin.x = 0;
    frame.origin.y = -frame.size.height;
    self.initFrame = frame;
    self.frame = frame;
    self.animationBegin = NO;
}

- (void)startAnimation {
    [UIView animateWithDuration:3.5 animations:^{
        CGRect frame = self.initFrame;
        frame.origin.y += 2 * self.initFrame.size.height;
        self.frame = frame;
    } completion:^(BOOL finished) {
        self.frame = self.initFrame;
        [self startAnimation];
    }];
    self.animationBegin = YES;
}

@end
