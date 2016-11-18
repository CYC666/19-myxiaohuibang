//
//  SearchListViewController.h
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/12.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddFriendNavDelegate <NSObject>

- (void)AddFriendPushViewColltroller:(UIViewController *)AddFriendViewColltroller;

@end

@interface SearchListViewController : UIViewController <UISearchResultsUpdating>

@property (nonatomic,weak)id <AddFriendNavDelegate>delegate;

@property (nonatomic, strong) NSArray *dataSource;

@end
