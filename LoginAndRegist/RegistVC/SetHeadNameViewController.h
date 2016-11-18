
//
//  SetHeadNameViewController.h
//  XiaoHuiBang
//
//  Created by 消汇邦 on 16/9/27.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetHeadNameViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *headImgBtn;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UIButton *cleanNameBtn;
@property (weak, nonatomic) IBOutlet UIButton *completeBtn;

@end
