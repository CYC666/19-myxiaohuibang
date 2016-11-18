//
//  SecurityCodeViewController.h
//  XiaoHuiBang
//
//  Created by 消汇邦 on 16/9/27.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecurityCodeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *registPhoneNumLab;
@property (weak, nonatomic) IBOutlet UITextField *codeTF;
@property (weak, nonatomic) IBOutlet UIButton *clearPhoneNumBtn;
@property (weak, nonatomic) IBOutlet UIButton *verifyCodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *toObtainCodeBtn;

@property (nonatomic,retain) NSString *phoneStr;
@property (nonatomic,retain) NSString *codeStr;

- (id)initWithPhoneNumberStr:(NSString *)phoneStr withCodeStr:(NSString *)codeStr;

@end
