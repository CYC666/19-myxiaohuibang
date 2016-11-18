//
//  LoginViewController.h
//  XiaoHuiBang
//
//  Created by 消汇邦 on 16/9/26.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <RongIMKit/RongIMKit.h>

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *accountNumTF;
@property (weak, nonatomic) IBOutlet UITextField *pswTF;
@property (weak, nonatomic) IBOutlet UIButton *cancelNumBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelPswBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *forgetBtn;

@end
