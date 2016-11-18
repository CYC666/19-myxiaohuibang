//
//  SendMomentsController.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/8.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

// 发表动态编辑界面



#import "SendMomentsController.h"
#import "NSString+Extension.h"
#import "FromCameraController.h"
#import "CLocationController.h"
#import <SVProgressHUD.h>
#import "NSString+Extension.h"
#import "CNetTool.h"

#define kScreenHeight [UIScreen mainScreen].bounds.size.height  // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width    // 屏宽


@interface SendMomentsController () <UITextViewDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RCEmojiViewDelegate> {

    UITableView *_tableView;
    UITextView *_textView;  // 输入框
    RCEmojiBoardView *_emojiInputView;  // 表情输入框
    NSData *_photoData;     // 等待上传的图片数据
    UIImage *_photo;        // 等待上传的图片
    
    
}

@end

@implementation SendMomentsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建子视图
    [self _createSubView];
    [self _setNavigationBar];
    
    
    
    
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    _scrollView.delegate = self;

}

#pragma mark - 设置导航栏
- (void)_setNavigationBar {
    
    self.navigationController.navigationBar.translucent = NO;

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"记录生活";
    title.font = [UIFont boldSystemFontOfSize:19];
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;
    
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(cancelAction:)];
    cancelButton.tintColor = [UIColor whiteColor];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"发布"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(sendAction:)];
    sendButton.tintColor = [UIColor colorWithRed:29/255.0 green:161/255.0 blue:243/255.0 alpha:1];
    sendButton.enabled = NO;
    [self.navigationItem setRightBarButtonItem:sendButton];

}

#pragma mark - 创建子视图
- (void)_createSubView {

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight*.48)
                                              style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = NO;
    [_backgroundView addSubview:_tableView];

}

#pragma mark - 导航栏按钮响应
// 取消按钮
- (void)cancelAction:(UIBarButtonItem *)button {
    
    // 先隐藏键盘，再dismiss
    [_textView endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        // 缓存动态编辑的状态
    }];
    
}
// 发布按钮
- (void)sendAction:(UIBarButtonItem *)button {
    if (button.enabled == NO) {
        return;
    }
    
    if (_textView.text.length > 255) {
        // 弹窗提示字数过多
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"请少于255字"];
        return;
    }
    
    // 判断是否含有表情
    if ([NSString stringContainsEmoji:_textView.text]) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"暂不支持表情"];
        return;
    }

    // 发表动态
    NSDictionary *params = @{@"user_id" : [USER_D objectForKey:@"user_id"],
                             @"content" : _textView.text,
                             @"file" : _photo == nil ? @"" : _photo};
    
    
    if (_photo != nil) {
        [CNetTool postAboutWithParameters:params
                                     data:_photoData
                                  success:^(id response) {
                                      [SVProgressHUD dismiss];
                                      [SVProgressHUD showSuccessWithStatus:@"发送成功"];
                                  } failure:^(NSError *err) {
                                      [SVProgressHUD dismiss];
                                      [SVProgressHUD showSuccessWithStatus:@"发送失败"];
                                  }];
    } else {
    
        [CNetTool postAboutWithParameters:params
                                  success:^(id response) {
                                      [SVProgressHUD dismiss];
                                      [SVProgressHUD showSuccessWithStatus:@"发送成功"];
                                  } failure:^(NSError *err) {
                                      [SVProgressHUD dismiss];
                                      [SVProgressHUD showSuccessWithStatus:@"发送失败"];
                                  }];
    
    }
    
    
    
    // 先隐藏键盘，再dismiss
    [_textView endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

#pragma mark - textView代理方法
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {

    // 先判断本地是否存有已经编辑过的状态
    if ([textView.text isEqualToString:@"记录我的生活"]) {
        textView.text = @"";
    }
    
    // 开始编辑文字输入框的时候就把表情面板隐藏掉
    if (_emojiInputView != nil) {
        [UIView animateWithDuration:.35
                         animations:^{
                             _emojiInputView.alpha = 0;
                         } completion:^(BOOL finished) {
                             [_emojiInputView removeFromSuperview];
                         }];
        _emojiInputView = nil;
    }
    return YES;

}

- (void)textViewDidChange:(UITextView *)textView {
    if ([textView.text isEmpty]) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    if (textView.textColor != [UIColor blackColor]) {
        textView.textColor = [UIColor blackColor];
    }
}

#pragma mark - scrollView代理方法
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [_textView endEditing:YES];

}

#pragma mark - 表视图代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 4;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                   reuseIdentifier:@"cellID"];
    if (indexPath.row == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight*.3)];
        _textView.text = @"记录我的生活";
        _textView.font = [UIFont systemFontOfSize:17];
        _textView.textColor = [UIColor lightGrayColor];
        _textView.delegate = self;
        [cell.contentView addSubview:_textView];
    } else if (indexPath.row == 1) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 0)];
        cell.imageView.image = [UIImage imageNamed:@"icon_open"];
        cell.textLabel.text = @"谁可以看";
        cell.detailTextLabel.text = @"公开";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.row == 2) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        cell.imageView.image = [UIImage imageNamed:@"icon_@"];
        cell.textLabel.text = @"提醒谁看";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.row == 3) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
        NSArray *array = @[@"icon_emoj", @"icon_album", @"icon_camera_b", @"icon_position"];
        float buttonWidth = kScreenWidth/4;
        for (int i = 0; i < 4; i++) {
            UIImage *image = [UIImage imageNamed:array[i]];
            float imageHeight = image.size.height;
            float imageWidth = image.size.width;
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth*i + (buttonWidth - imageWidth)/2.0, (kScreenHeight*.06 - imageHeight)/2.0, imageWidth, imageHeight)];
            button.tag = 989 + i;
            [button addTarget:self action:@selector(moreOptionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [button setImage:image forState:UIControlStateNormal];
            [cell.contentView addSubview:button];
            [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0) {
        return kScreenHeight*.3;
    } else {
        return kScreenHeight*.06;
    }

}

#pragma mark - 输入框下面按钮的点击响应
- (void)moreOptionButtonAction:(UIButton *)button {

    NSInteger num = button.tag - 989;
    if (num == 0) {
        // 打开表情输入
        [self openEmojiInput];
    } else if (num == 1) {
        // 打开系统相册
        [self openSystemPicture];
    } else if (num == 2) {
        [self presentViewController:[[FromCameraController alloc] init]
                           animated:YES
                         completion:nil];
    } else if (num == 3) {
        [self openLocation];
    }

}

#pragma mark - 打开表情输入
- (void)openEmojiInput {

    if (_emojiInputView == nil) {
        [_textView endEditing:YES];
        _emojiInputView = [[RCEmojiBoardView alloc] initWithFrame:CGRectMake(0,
                                                                             kScreenHeight*.48,
                                                                             kScreenWidth,
                                                                             223)];
        // 设置表情的协议代理方法
        _emojiInputView.delegate = self;
        _emojiInputView.alpha = 0;
        [_emojiInputView enableSendButton:YES];
        [_backgroundView addSubview:_emojiInputView];
        [UIView animateWithDuration:.35
                         animations:^{
                             _emojiInputView.alpha = 1;
                         }];
        NSLog(@"%@", _emojiInputView);
        
    } else {
#warning 如果不从父视图移除的话，会内存泄露，不断创建_emojiInputView
        [UIView animateWithDuration:.35
                         animations:^{
                             _emojiInputView.alpha = 0;
                         } completion:^(BOOL finished) {
                             [_emojiInputView removeFromSuperview];
                         }];
        _emojiInputView = nil;
    }

}

#pragma mark - 打开系统相册选区照片
- (void)openSystemPicture {
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
    
}

#pragma mark - imagePicker代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {

    // 判断资源的来源 相册||摄像头
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary || picker.sourceType == UIImagePickerControllerSourceTypeSavedPhotosAlbum) {
        // 取出照片
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        // 返回照片
        _photoData = UIImageJPEGRepresentation(image, 0.75);
        
        _photo = image;
        
    }
    //关闭,返回
    [picker dismissViewControllerAnimated:YES completion:^{
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"添加图片成功"];
    }];
}

#pragma mark - RCEmojiViewDelegate表情输入框代理方法
/*!
 点击表情的回调
 
 @param emojiView 表情输入的View
 @param string    点击的表情对应的字符串编码
 */
- (void)didTouchEmojiView:(RCEmojiBoardView *)emojiView touchedEmoji:(NSString *)string{

    if ([_textView.text isEqualToString:@"记录我的生活"]) {
        _textView.text = @"";
    }
    
#warning 表情输入板的删除按钮，没有相应的协议方法，智能根据输入的是否未空，来判断当前输入的是否未删除按钮
    // 删除按钮不做任何操作,因为有些表情是2bit，有的是1bit
    if (string != nil) {
        _textView.text = [_textView.text stringByAppendingString:string];
    }
    

}

- (void)didSendButtonEvent:(RCEmojiBoardView *)emojiView sendButton:(UIButton *)sendButton {
    
    NSLog(@"%@", emojiView);
    // 当点击发送按钮时，将表情面板隐藏
    [UIView animateWithDuration:.35
                     animations:^{
                         emojiView.alpha = 0;
                     } completion:^(BOOL finished) {
                         [emojiView removeFromSuperview];
                     }];
    emojiView = nil;
}


#pragma mark - 打开定位界面
- (void)openLocation {

    CLocationController *locationCtrl = [[CLocationController alloc] init];
    [self.navigationController pushViewController:locationCtrl animated:YES];

}















- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*

 被丢弃的代码
 
 
 //    NSString *urlStr = @"http://115.28.6.7/rongyun.php/Home/about/about_publish";
 //    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
 //    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
 //    [session POST:urlStr
 //       parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
 //           if (_photo != nil) {   // 图片数据不为空才传递
 //
 //               [formData appendPartWithFileData:_photoData name:@"file" fileName:@"user.jpg" mimeType:@"image/jpg"];
 //           }
 //       } progress:^(NSProgress * _Nonnull uploadProgress) {
 //
 //       } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
 //           [SVProgressHUD dismiss];
 //           [SVProgressHUD showSuccessWithStatus:@"发送成功"];
 //       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
 //           [SVProgressHUD dismiss];
 //           [SVProgressHUD showSuccessWithStatus:@"发送失败"];
 //       }];

 
 
 */

@end
