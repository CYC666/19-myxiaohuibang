//
//  AddFridensDataViewController.h
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/13.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddFridensDataViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, retain) NSDictionary *userDataDic;

- (id)initWithUserData:(NSDictionary *)userData;

@end
