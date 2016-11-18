//
//  PersonageTableViewCell.h
//  XiaoHuiBang
//
//  Created by 消汇邦 on 16/9/30.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userHeadImg;
@property (weak, nonatomic) IBOutlet UILabel *userNameLab;
@property (weak, nonatomic) IBOutlet UIImageView *userSexImg;
@property (weak, nonatomic) IBOutlet UILabel *userIDLab;

@end
