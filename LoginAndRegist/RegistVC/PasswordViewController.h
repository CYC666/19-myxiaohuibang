//
//  PasswordViewController.h
//  XiaoHuiBang
//
//  Created by 消汇邦 on 16/9/27.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PasswordViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *pswTF;
@property (weak, nonatomic) IBOutlet UITextField *freshPswTF;
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;

@property (nonatomic,retain) NSString *phoneStr;

- (id)initWithPhoneNumberStr:(NSString *)phoneStr;

@end
