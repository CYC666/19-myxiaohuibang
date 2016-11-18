//
//  UsersToTheirOwnGroupViewController.h
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/11/7.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UsersToTheirOwnGroupViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *groupHeadImg;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLab;
@property (weak, nonatomic) IBOutlet UILabel *groupNumberLab;
@property (weak, nonatomic) IBOutlet UIButton *addGroupBtn;

@property (nonatomic, retain) NSString *groupId;

- (id)initWithGroupId:(NSString *)groupId;

@end
