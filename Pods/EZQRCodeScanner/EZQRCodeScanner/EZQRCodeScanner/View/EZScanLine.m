//
//  EZScanLine.m
//  EZQRCodeScanner
//
//  Created by ezfen on 16/5/20.
//  Copyright © 2016年 Ezfen Cheung. All rights reserved.
//

#import "EZScanLine.h"

@interface EZScanLine()
@property (nonatomic) CGFloat minBorder;
@property (nonatomic) CGFloat maxBorder;
@property (nonatomic) BOOL direction;
@end

@implementation EZScanLine

- (instancetype)init{
    return [self initWithFrame:[UIScreen mainScreen].bounds];
}
- (instancetype)initWithFrame:(CGRect)frame displayInView:(UIView *)showView{
    self = [super initWithFrame:frame];
    if (self) {
        self.showView = showView;
    }
    return self;
}

- (void)setShowView:(UIView *)showView {
    _showView = showView;
    self.minBorder = CGRectGetMinY(showView.bounds);
    self.maxBorder = CGRectGetMaxY(showView.bounds);
    self.direction = YES;
}

- (void)startAnimation {
    CGRect rect = self.frame;
    UIView *shadowLine = [[UIView alloc] initWithFrame:rect];
    shadowLine.backgroundColor = self.backgroundColor;
    [self.superview addSubview:shadowLine];
    [UIView animateWithDuration:.5 animations:^{
        shadowLine.alpha = 0;
    } completion:^(BOOL finished) {
        [shadowLine removeFromSuperview];
    }];
    if (self.direction) {
        rect.origin.y += 1;
        self.frame = rect;
        if (self.frame.origin.y >= self.maxBorder) {
            self.direction = NO;
        }
    } else {
        rect.origin.y -= 1;
        self.frame = rect;
        if (self.frame.origin.y <= self.minBorder) {
            self.direction = YES;
        }
    }
}

@end
