//
//  SetHeadNameViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 16/9/27.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "SetHeadNameViewController.h"

#import <AFNetworking.h>
#import <SVProgressHUD.h>
#import <UIButton+WebCache.h>

@interface SetHeadNameViewController ()
{
    NSData *_photoData;
    
    NSString *_userHeadImg;
    NSString *_userNameStr;
    NSString *_userSexStr;
    NSString *_userModeilStr;
}
@end

@implementation SetHeadNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelBtn.frame = CGRectMake(10, 25, 40, 40);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    //    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(goBackToRegistViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    
    self.completeBtn.backgroundColor = [UIColor colorWithRed:29.0/255.0 green:141.0/255.0 blue:239.0/255.0 alpha:1.0];
    self.completeBtn.layer.cornerRadius = 5;
    self.completeBtn.layer.masksToBounds = YES;
}

- (IBAction)uploadThePictureButtonClick:(UIButton *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"请选择文件来源" preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"照相机" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //			[self presentModalViewController:imagePicker animated:YES];
        [self presentViewController:imagePicker animated:YES completion:nil];
    }];
    UIAlertAction *ookAction = [UIAlertAction actionWithTitle:@"从手机相册选择" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //			[self presentModalViewController:imagePicker animated:YES];
        [self presentViewController:imagePicker animated:YES completion:nil];
    }];
    // 注意取消按钮只能添加一个
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction *action) {
        
    }];
    // 添加按钮 将按钮添加到UIAlertController对象上
    [alertController addAction:okAction];
    [alertController addAction:ookAction];
    [alertController addAction:cancelAction];
    
    // 将UIAlertController模态出来 相当于UIAlertView show 的方法
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)clearUserNameClick:(UIButton *)sender {
    self.nameTF.text = @"";
}

- (IBAction)finishedUploadingButtonClick:(UIButton *)sender {
    if (self.nameTF.text.length <= 0) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
        [SVProgressHUD showErrorWithStatus:@"密码不能为空"];
        return;
    } else {
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",XBaseURL,XUserInformationModifyURL];
        
        NSDictionary *dic = @{
                              @"id":[USER_D objectForKey:@"user_id"],
                              @"nickname":self.nameTF.text,
                              };
        KMLog(@"dic:%@",dic);
        
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", nil];
        //    session.requestSerializer.timeoutInterval = 5.0;
        [session POST:urlStr parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            KMLog(@"success:%@",responseObject);
            
            KMLog(@"%@",[MyTool dictionaryToJson:responseObject]);
            
            NSString *msgStr = [responseObject objectForKey:@"msg"];
            NSNumber *msg = (NSNumber *)msgStr;
            if ([msg isEqualToNumber:@1]) {
                //登录融云服务器
                [[RCIM sharedRCIM] connectWithToken:[USER_D objectForKey:@"key_token"]
                                            success:^(NSString *userId) {
                                                NSLog(@"%@",userId);
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    
                                                    [MyTool toMainVCRequest];
                                                });
                                            }
                                              error:^(RCConnectErrorCode status) {
                                                  NSLog(@"RCConnectErrorCode is %ld", (long)status);
                                              }
                                     tokenIncorrect:^{
                                         NSLog(@"IncorrectToken");
                                     }];
            } else {
                [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"data"]];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            KMLog(@"Error:%@",error);
        }];
    }
}

#pragma mark -

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    //    NSLog(@"%@",[info objectForKey:@"UIImagePickerControllerMediaType"]);
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    [SVProgressHUD showWithStatus:@"正在加载"];
    
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    KMLog(@"%@",type);
    if ([type isEqualToString:@"public.image"]) {
        //先把图片转成NSData
        //UIImagePickerControllerEditedImage 获取截取的照片
        //UIImagePickerControllerOriginalImage 获取整张图片
        UIImage *image = [self scaleImage:[info objectForKey:@"UIImagePickerControllerEditedImage"] toScale:0.75];
        _photoData = UIImageJPEGRepresentation(image, 0.75);
        
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",XBaseURL,XUploadPictureURL];
        
        NSDictionary *dic = @{
                              @"id":[USER_D objectForKey:@"user_id"],
                              @"file":[info objectForKey:@"UIImagePickerControllerEditedImage"],
                              };
        NSLog(@"dic:%@",dic);
        AFHTTPSessionManager  *session = [AFHTTPSessionManager manager];
        session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
        [session POST:urlStr parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            if (image!=nil) {   // 图片数据不为空才传递
                //                NSData *fileData = UIImageJPEGRepresentation(image, 1.0);
                
                [formData appendPartWithFileData:_photoData name:@"file" fileName:@"user.jpg" mimeType:@"image/jpg"];
            }
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            KMLog(@"success:%@",responseObject);
            
            NSString *codeStr = [responseObject objectForKey:@"msg"];
            NSNumber *code = (NSNumber *)codeStr;
            
            if ([code isEqualToNumber:@1]){
                _userHeadImg = [[responseObject objectForKey:@"data"] objectForKey:@"head_img"];
                
                [USER_D setObject:_userHeadImg forKey:@"userPortraitUri"];
                [USER_D synchronize];
                RCUserInfo *user = [RCUserInfo new];
                user.userId = [RCIM sharedRCIM].currentUserInfo.userId;
                user.portraitUri = _userHeadImg;
                user.name = [USER_D stringForKey:@"userNickName"];
                
                [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:user.userId];
                
                [self.headImgBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",_userHeadImg]] forState:UIControlStateNormal];
                
                [SVProgressHUD dismiss];
                [SVProgressHUD showSuccessWithStatus:@"上传成功"];
            } else {
                [SVProgressHUD dismiss];
                [SVProgressHUD showSuccessWithStatus:@"上传失败"];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"Error:%@",error);
            [SVProgressHUD showErrorWithStatus:@"服务器连接超时,请检查网络"];
        }];
    }
}

- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize {
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

//点击return 按钮 去掉
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
//点击屏幕空白处去掉键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.nameTF resignFirstResponder];
}

- (void)goBackToRegistViewController:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
