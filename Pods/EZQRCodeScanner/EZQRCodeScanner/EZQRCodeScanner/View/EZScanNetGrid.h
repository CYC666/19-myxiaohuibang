//
//  EZScanNetGrid.h
//  EZQRCodeScanner
//
//  Created by ezfen on 16/5/20.
//  Copyright © 2016年 Ezfen Cheung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EZScanNetGrid : UIImageView

@property (weak, nonatomic) UIView *showView;

@property (nonatomic) BOOL animationBegin;

- (void)startAnimation;

@end
