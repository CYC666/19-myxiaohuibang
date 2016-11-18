//
//  UserInformationViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 16/9/30.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "UserInformationViewController.h"

#import "UserInfomationTableViewCell.h"

#import "UserNameViewController.h"
#import "UserSexViewController.h"
#import "MyQRCodeViewController.h"

#import "RCDataBaseManager.h"

#import <AFNetworking.h>
#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>

@interface UserInformationViewController ()
{
    NSData *_photoData;
    
    UITableView *_userInfomationTableView;
    
    NSString *_userHeadImg;
    NSString *_userNameStr;
    NSString *_userSexStr;
    NSString *_userModeilStr;
}
@end

@implementation UserInformationViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self requestUserIndormation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"个人信息";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _userInfomationTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, My_Screen_Width, My_Screen_Height) style:UITableViewStyleGrouped];
    _userInfomationTableView.delegate = self;
    _userInfomationTableView.dataSource = self;
    _userInfomationTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_userInfomationTableView];
    
    [self requestUserIndormation];
}

- (void)requestUserIndormation {
    [AFHttpTool getUserInfo:[USER_D objectForKey:@"user_id"] success:^(id response) {
        KMLog(@"success:%@",response);
        
        KMLog(@"%@",[MyTool dictionaryToJson:response]);
        
        NSString *msgStr = [response objectForKey:@"msg"];
        NSNumber *msg = (NSNumber *)msgStr;
        if ([msg isEqualToNumber:@1]) {
            _userHeadImg = [[response objectForKey:@"data"] objectForKey:@"head_img"];
            _userNameStr = [[response objectForKey:@"data"] objectForKey:@"nickname"];
            _userSexStr = [[response objectForKey:@"data"] objectForKey:@"sex"];
            _userModeilStr = [[response objectForKey:@"data"] objectForKey:@"mobile"];
            
            RCUserInfo *userInfo = [RCIMClient sharedRCIMClient].currentUserInfo;
            userInfo.name = _userNameStr;
            [[RCDataBaseManager shareInstance] insertUserToDB:userInfo];
            [[RCIM sharedRCIM] refreshUserInfoCache:userInfo
                                         withUserId:userInfo.userId];
            [USER_D setObject:_userNameStr forKey:@"userNickName"];
            [USER_D synchronize];
            
            [_userInfomationTableView reloadData];
            
            [SVProgressHUD dismiss];
        } else {
            
        }
    } failure:^(NSError *err) {
        KMLog(@"Error:%@",err);
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 80.0;
    }
    return 50.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserInfomationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserInfomationCell"];
    
    if (!cell) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"UserInfomationTableViewCell" owner:nil options:nil];
        //        判断类型
        if ([array[0] isKindOfClass:[UserInfomationTableViewCell class]]) {
            cell = (UserInfomationTableViewCell *)array[0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.row == 0) {
        cell.userHeadImage.layer.cornerRadius = 5;
        cell.userHeadImage.layer.masksToBounds = YES;
        
        [cell.userHeadImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",_userHeadImg]]];
        cell.userTextLab.text = @"头像";
    } else if (indexPath.row == 1) {
        cell.userTextLab.text = @"昵称";
        cell.userMassageLab.text = [NSString jsonUtils:_userNameStr];;
    } else if (indexPath.row == 2){
        cell.userTextLab.text = @"性别";
        
        if ([_userSexStr isEqualToString:@"0"]) {
            cell.userMassageLab.text = @"请设置性别";
        } else if ([_userSexStr isEqualToString:@"1"]) {
            cell.userMassageLab.text = @"男";
        } else {
            cell.userMassageLab.text = @"女";
        }
    } else {
        cell.userTextLab.text = @"我的二维码";
        
        UIButton *codeBtn = [UIButton new];
        codeBtn.frame = CGRectMake(My_Screen_Width-56, 12, 22, 22);
        [codeBtn setBackgroundImage:[UIImage imageNamed:@"图层-2"] forState:UIControlStateNormal];
        [cell addSubview:codeBtn];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
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
    } else if (indexPath.row == 1) {
        UserNameViewController *userNameVC = [[UserNameViewController alloc] initWithUserName:_userNameStr];
        [self.navigationController pushViewController:userNameVC animated:YES];
    } else if (indexPath.row == 2) {
        UserSexViewController *userSexVC = [[UserSexViewController alloc] initWithUserSex:_userSexStr];
        [self.navigationController pushViewController:userSexVC animated:YES];
    } else {
        MyQRCodeViewController *myCodeVC = [[MyQRCodeViewController alloc] initWithUserOrGroupStatus:@"1"];
        [self.navigationController pushViewController:myCodeVC animated:YES];
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
                
                [_userInfomationTableView reloadData];
                
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
