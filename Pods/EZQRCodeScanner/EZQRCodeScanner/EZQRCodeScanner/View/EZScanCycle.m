//
//  EZScanCycle.m
//  EZQRCodeScanner
//
//  Created by ezfen on 16/5/20.
//  Copyright © 2016年 Ezfen Cheung. All rights reserved.
//

#import "EZScanCycle.h"

@interface EZScanCycle()

@end

@implementation EZScanCycle

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, rect);
    self.center = CGPointMake(CGRectGetMinX(rect) + CGRectGetWidth(rect) / 2, CGRectGetMinY(rect) + CGRectGetHeight(rect) / 2);
    CGContextAddArc(ctx, self.center.x, self.center.y, CGRectGetWidth(rect) * .35, 0, M_PI_4 / 4, 0);
    [[UIColor colorWithRed:0.400 green:1.000 blue:0.800 alpha:0.500] setStroke];
    CGContextSetLineWidth(ctx, 20);
    CGContextStrokePath(ctx);
}

- (void)startAnimation {
    // 未完成
}

@end
