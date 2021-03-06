//
//  UIScrollView+PullUpRefresh.h
//  XiaoHuiBang
//
//  Created by mac on 16/11/15.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InfiniteScrollingView;

@interface UIScrollView (PullUpRefresh)

- (void)addInfiniteScrollingWithActionHandler:(void (^)(void))actionHandler;
- (void)triggerInfiniteScrolling;

@property(nonatomic, strong, readonly)
InfiniteScrollingView *infiniteScrollingView;
@property(nonatomic, assign) BOOL showsInfiniteScrolling;

@end

enum {
    InfiniteScrollingStateStopped = 0,
    InfiniteScrollingStateTriggered,
    InfiniteScrollingStateLoading,
    InfiniteScrollingStateAll = 10
};

typedef NSUInteger InfiniteScrollingState;

@interface InfiniteScrollingView : UIView

@property(nonatomic, readwrite)
UIActivityIndicatorViewStyle activityIndicatorViewStyle;
@property(nonatomic, readonly) InfiniteScrollingState state;
@property(nonatomic, readwrite) BOOL enabled;

- (void)setCustomView:(UIView *)view forState:(InfiniteScrollingState)state;

- (void)startAnimating;
- (void)stopAnimating;

@end

