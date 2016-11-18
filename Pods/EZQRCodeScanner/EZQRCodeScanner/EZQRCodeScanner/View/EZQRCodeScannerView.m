//
//  EZQRCodeScannerView.m
//  EZQRCodeScanner
//
//  Created by ezfen on 16/5/16.
//  Copyright © 2016年 Ezfen Cheung. All rights reserved.
//

#import "EZQRCodeScannerView.h"
#import "EZScanLine.h"
#import "EZScanNetGrid.h"
#import "EZScanCycle.h"

#define CornerLineWidth 4

@interface EZQRCodeScannerView()
// Animation Show View
@property (strong, nonatomic) UIView *showView;
@property (nonatomic) CGRect scanRegionFrame;

@property (strong, nonatomic) NSTimer *timer;
// ScanLine
@property (strong, nonatomic) EZScanLine *scanLine;
// ScanNetGrid
@property (strong, nonatomic) EZScanNetGrid *netGrid;
// ScanCycle
@property (strong, nonatomic) EZScanCycle *cycle;

@end

@implementation EZQRCodeScannerView

# pragma mark - Initial
- (instancetype)init {
    return [self initWithFrame:[UIScreen mainScreen].bounds];
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.scanRegionFrame = CGRectMake(self.frame.size.width * kWidthPaddingAspect,
                                    self.frame.size.height * kHeightPaddingAspect,
                                    self.frame.size.width * kClearRectAspect,
                                    self.frame.size.width * kClearRectAspect);
    }
    return self;
}

- (CGFloat)minYUnderScannerRegion {
    // 获取扫描区域下方最小的Y值
    return CGRectGetMaxY(self.scanRegionFrame);
}

- (CGFloat)minXNearScannerRegion {
    return CGRectGetMaxX(self.scanRegionFrame);
}

# pragma mark - Getter and Setter
- (UIView *)showView {
    if (!_showView) {
        _showView = [[UIView alloc] initWithFrame:self.scanRegionFrame];
        _showView.clipsToBounds = YES;
        [self addSubview:_showView];
    }
    return _showView;
}

- (void)setScanStyle:(EZScanStyle)scanStyle {
    _scanStyle = scanStyle;
    switch (scanStyle) {
        case EZScanStyleNetGrid:
        {
            self.netGrid = [[EZScanNetGrid alloc] initWithImage:[UIImage imageNamed:@"scan_net"]];
            self.netGrid.showView = self.showView;
            self.netGrid.contentMode = UIViewContentModeScaleAspectFill;
            [self.showView addSubview:self.netGrid];
        }
            break;
        case EZScanStyleLine:
        {
            self.scanLine = [[EZScanLine alloc] initWithFrame:CGRectMake(0, 0, self.showView.frame.size.width, 1) displayInView:self.showView];
            self.scanLine.backgroundColor = [UIColor colorWithRed:0.400 green:1.000 blue:1.000 alpha:0.600];
            [self.showView addSubview:self.scanLine];
        }
            break;
        case EZScanStyleCycle:
        {
            self.cycle = [[EZScanCycle alloc] initWithFrame:self.showView.bounds];
            [self.showView addSubview:self.cycle];
        }
            break;
        default:
            break;
    }
}

# pragma mark - Running Control
- (void)startAnimation {
    switch (self.scanStyle) {
        case EZScanStyleLine:
        {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self.scanLine selector:@selector(startAnimation) userInfo:nil repeats:YES];
        }
            break;
        case EZScanStyleCycle:
        {
            
        }
            break;
        case EZScanStyleNetGrid:
        {
            if (!self.netGrid.animationBegin) {
                [self.netGrid startAnimation];
            }
        }
            break;
        default:
        break;
    }
}
- (void)stopAnimation {
    [self.timer invalidate];
    self.timer = nil;
}

# pragma mark - 描绘中间透明四周半透明的View
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGSize viewSize = rect.size;
    CGRect screenDrawRect = CGRectMake(0, 0, viewSize.width, viewSize.height);
    CGRect clearDrawRect = self.scanRegionFrame;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [self drawFullScreen:ctx rect:screenDrawRect];
    [self addCenterClearRect:ctx rect:clearDrawRect];
    [self addWhiteRect:ctx rect:clearDrawRect];
    [self addCorner:ctx rect:clearDrawRect];
}
- (void)drawFullScreen:(CGContextRef)ctx rect:(CGRect)rect {
    CGContextSetRGBFillColor(ctx, 0, 0, 0, .5);
    CGContextFillRect(ctx, rect);
}
- (void)addCenterClearRect:(CGContextRef)ctx rect:(CGRect)rect {
    CGContextClearRect(ctx, rect);
}
- (void)addWhiteRect:(CGContextRef)ctx rect:(CGRect)rect {
    CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1);
    CGContextSetLineWidth(ctx, 0.7);
    CGContextAddRect(ctx, rect);
    CGContextStrokeRect(ctx, rect);
}
- (void)addCorner:(CGContextRef)ctx rect:(CGRect)rect {
    CGFloat cornerOffset = CornerLineWidth / 2;     // 考虑到线条的粗细，设置边角位置偏移量
    // 左上角
    CGPoint pointsTopLeftA[] = {
        CGPointMake(rect.origin.x, rect.origin.y - cornerOffset),
        CGPointMake(rect.origin.x, rect.origin.y + rect.size.height * .15 - cornerOffset)
    };
    CGContextAddLines(ctx, pointsTopLeftA, 2);
    CGPoint pointsTopLeftB[] = {
        CGPointMake(rect.origin.x - cornerOffset, rect.origin.y),
        CGPointMake(rect.origin.x + rect.size.width * .15 - cornerOffset, rect.origin.y)
    };
    CGContextAddLines(ctx, pointsTopLeftB, 2);
    
    // 左下角
    CGPoint pointsBottomLeftA[] = {
        CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect) + cornerOffset),
        CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect) - rect.size.height * .15 + cornerOffset)
    };
    CGContextAddLines(ctx, pointsBottomLeftA, 2);
    CGPoint pointsBottomLeftB[] = {
        CGPointMake(CGRectGetMinX(rect) - cornerOffset , CGRectGetMaxY(rect)),
        CGPointMake(CGRectGetMinX(rect) + rect.size.width * .15 - cornerOffset, CGRectGetMaxY(rect))
    };
    CGContextAddLines(ctx, pointsBottomLeftB, 2);
    
    // 右上角
    CGPoint pointsTopRightA[] = {
        CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect) - cornerOffset),
        CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect) + rect.size.height * .15 - cornerOffset)
    };
    CGContextAddLines(ctx, pointsTopRightA, 2);
    CGPoint pointsTopRightB[] = {
        CGPointMake(CGRectGetMaxX(rect) + cornerOffset , CGRectGetMinY(rect)),
        CGPointMake(CGRectGetMaxX(rect) - rect.size.width * .15 + cornerOffset, CGRectGetMinY(rect))
    };
    CGContextAddLines(ctx, pointsTopRightB, 2);
    
    // 右下角
    CGPoint pointsBottomRightA[] = {
        CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect) + cornerOffset),
        CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect) - rect.size.height * .15 + cornerOffset)
    };
    CGContextAddLines(ctx, pointsBottomRightA, 2);
    CGPoint pointsBottomRightB[] = {
        CGPointMake(CGRectGetMaxX(rect) + cornerOffset, CGRectGetMaxY(rect)),
        CGPointMake(CGRectGetMaxX(rect) - rect.size.width * .15 + cornerOffset, CGRectGetMaxY(rect))
    };
    CGContextAddLines(ctx, pointsBottomRightB, 2);
    
    CGContextSetLineWidth(ctx, CornerLineWidth);
    [[UIColor colorWithRed:0.400 green:0.800 blue:1.000 alpha:1.000] setStroke];
    CGContextStrokePath(ctx);
}


@end
