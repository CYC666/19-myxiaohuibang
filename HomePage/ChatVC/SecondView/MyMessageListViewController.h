//
//  MyMessageListViewController.h
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/10.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

#import "MyContactViewController.h"

#import <EZQRCodeScanner.h>

@interface MyMessageListViewController : RCConversationListViewController <UISearchBarDelegate,UIScrollViewDelegate,MyMessageNavDelegate,EZQRCodeScannerDelegate>

- (void)updateBadgeValueForTabBarItem;

@end
