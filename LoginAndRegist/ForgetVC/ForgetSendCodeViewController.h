//
//  ForgetSendCodeViewController.h
//  XiaoHuiBang
//
//  Created by 消汇邦 on 16/9/28.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgetSendCodeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *phoneNumTF;
@property (weak, nonatomic) IBOutlet UITextField *codeTF;
@property (weak, nonatomic) IBOutlet UIButton *clearBtn;
@property (weak, nonatomic) IBOutlet UIButton *verifyBtn;
@property (weak, nonatomic) IBOutlet UIButton *toObtainBtn;

@end
