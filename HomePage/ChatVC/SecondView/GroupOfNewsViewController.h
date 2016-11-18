//
//  GroupOfNewsViewController.h
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/19.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupOfNewsViewController : UIViewController

@property (nonatomic, retain) NSMutableArray *FriendsArr;

- (id)initWithFriendsArr:(NSMutableArray *)FriendsArr;

@end
