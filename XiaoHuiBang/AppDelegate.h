//
//  AppDelegate.h
//  XiaoHuiBang
//
//  Created by 消汇邦 on 16/9/26.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <RongIMKit/RongIMKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,RCIMConnectionStatusDelegate, RCIMReceiveMessageDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

