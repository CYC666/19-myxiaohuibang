//
//  EZScanLine.h
//  EZQRCodeScanner
//
//  Created by ezfen on 16/5/20.
//  Copyright © 2016年 Ezfen Cheung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EZScanLine : UIView

@property (weak, nonatomic) UIView *showView;

- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame displayInView:(UIView *)showView;
- (void)startAnimation;     // 需要设置定时器定时调用此函数

@end
