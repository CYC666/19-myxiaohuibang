//
//  MessageListTableViewCell.h
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/7.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLab;
@property (weak, nonatomic) IBOutlet UILabel *userContentLab;
@property (weak, nonatomic) IBOutlet UILabel *messagetimeLab;
@property (weak, nonatomic) IBOutlet UIImageView *messageDisturbImage;

@end
