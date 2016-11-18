//
//  MyQRCodeViewController.h
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/11/4.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyQRCodeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *headImg;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UIImageView *sexLab;
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImg;

@property (nonatomic, copy) NSString *status;

@property (nonatomic, strong) NSString *GroupId;

- (id)initWithUserOrGroupStatus:(NSString *)status;

@end
