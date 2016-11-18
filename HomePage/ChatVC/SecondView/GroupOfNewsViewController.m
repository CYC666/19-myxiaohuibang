//
//  GroupOfNewsViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/19.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "GroupOfNewsViewController.h"

#import "MyChatConversationViewController.h"

#import "MultiSelectItem.h"

#import <AFNetworking.h>
#import <SVProgressHUD.h>
#import <RongIMKit/RongIMKit.h>

@interface GroupOfNewsViewController ()
{
    UITextField *_groupNameTF;
}
@end

@implementation GroupOfNewsViewController

- (id)initWithFriendsArr:(NSMutableArray *)FriendsArr {
    self = [super init];
    
    if (self) {
        self.FriendsArr = FriendsArr;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"群消息设置";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;
    
    UIButton *releaseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [releaseButton setTitle:@"确定" forState:UIControlStateNormal];
    releaseButton.frame = CGRectMake(0, 0, 60, 30);
    [releaseButton addTarget:self action:@selector(releaseInfo:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *releaseButtonItem = [[UIBarButtonItem alloc] initWithCustomView:releaseButton];
    self.navigationItem.rightBarButtonItem = releaseButtonItem;
    
    UIButton *imageBtn = [UIButton new];
    imageBtn.frame = CGRectMake(My_Screen_Width/2-48, 45+64, 95, 95);
    [imageBtn setBackgroundImage:[UIImage imageNamed:@"头像"] forState:UIControlStateNormal];
    [imageBtn addTarget:self action:@selector(imageHeadChangeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:imageBtn];
    
    UILabel *contentLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 160+64, 80, 40)];
    contentLab.text = @"群聊名称";
    [self.view addSubview:contentLab];
    
    _groupNameTF = [[UITextField alloc] initWithFrame:CGRectMake(110, 160+64, My_Screen_Width-130, 40)];
    _groupNameTF.placeholder = @"请填写群聊名称";
    _groupNameTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:_groupNameTF];
    
    UILabel *lineLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 200+64, My_Screen_Width-40, 1)];
    lineLab.backgroundColor = [UIColor grayColor];
    [self.view addSubview:lineLab];
}

- (void)imageHeadChangeButtonClick:(UIButton *)button {
    
}

- (void)releaseInfo:(UIButton *)button {
    NSLog(@"123");
    
    //    NSLog(@"%@",items);
    
    if (_groupNameTF.text.length <= 0) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
        [SVProgressHUD showErrorWithStatus:@"群名称不能为空"];
        
        return;
    } else {
        NSMutableArray *items = [NSMutableArray array];
        
        for (MultiSelectItem *item in self.FriendsArr) {
            NSString *idStr = item.friendId;
            [items addObject:idStr];
        }
        
        NSString *itemsStr=[items componentsJoinedByString:@","];
        //    NSLog(@"~~~~%@",itemsStr);
        
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",XBaseURL,XCreateAGroupChatURL];
        
        NSDictionary *dic = @{
                              @"user_id":[USER_D objectForKey:@"user_id"],
                              @"name":_groupNameTF.text,
                              @"check":itemsStr
                              };
        NSLog(@"dic:%@",dic);
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
        //    session.requestSerializer.timeoutInterval = 5.0;
        [session POST:urlStr parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"success:%@",responseObject);
            
            KMLog(@"%@",[MyTool dictionaryToJson:responseObject]);
            
            NSString *msgStr = [responseObject objectForKey:@"msg"];
            NSNumber *msg = (NSNumber *)msgStr;
            if ([msg isEqualToNumber:@1]) {
                //新建一个聊天会话View Controller对象
                MyChatConversationViewController *chat = [[MyChatConversationViewController alloc]init];
                //设置会话的类型，如单聊、讨论组、群聊、聊天室、客服、公众服务会话等
                chat.conversationType = ConversationType_GROUP;
                //设置会话的目标会话ID。（单聊、客服、公众服务会话为对方的ID，讨论组、群聊、聊天室为会话的ID）
                chat.targetId = [[responseObject objectForKey:@"data"] objectForKey:@"id"];
                //设置聊天会话界面要显示的标题
                
                //            KMLog(@"~!~!~!~%@",model.conversationTitle);
                
                UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
                title.text = [[responseObject objectForKey:@"data"] objectForKey:@"name"];
                title.textAlignment = NSTextAlignmentCenter;
                title.textColor = [UIColor whiteColor];
                chat.navigationItem.titleView = title;
                //    chat.title = model.conversationTitle;
                chat.hidesBottomBarWhenPushed = YES;
                //    chat.userName = model.conversationTitle;
                //显示聊天会话界面
                [self.navigationController pushViewController:chat animated:YES];
                
            } else {
                KMLog(@"123");
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            KMLog(@"Error:%@",error);
        }];
    }
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
