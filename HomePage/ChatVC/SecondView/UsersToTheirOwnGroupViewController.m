//
//  UsersToTheirOwnGroupViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/11/7.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "UsersToTheirOwnGroupViewController.h"

#import "RCDHttpTool.h"
#import "RCDataBaseManager.h"

#import <UIImageView+WebCache.h>

@interface UsersToTheirOwnGroupViewController ()

@end

@implementation UsersToTheirOwnGroupViewController

- (id)initWithGroupId:(NSString *)groupId {
    self = [super init];
    
    if (self) {
        self.groupId = groupId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.addGroupBtn.backgroundColor = [UIColor colorWithRed:29.0/255.0 green:141.0/255.0 blue:239.0/255.0 alpha:1.0];
    self.addGroupBtn.layer.cornerRadius = 5.0;
    self.addGroupBtn.layer.masksToBounds = YES;
    
    self.groupHeadImg.layer.cornerRadius = 5.0;
    self.groupHeadImg.layer.masksToBounds = YES;
    
    [RCDHTTPTOOL getGroupByID:self.groupId
            successCompletion:^(RCDGroupInfo *group) {
                
                [self.groupHeadImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",group.portraitUri]]];
                
                self.groupNameLab.text = group.groupName;
                
                self.groupNumberLab.text = [NSString stringWithFormat:@"（共%@人）",group.number];
                
                [[RCDataBaseManager shareInstance] insertGroupToDB:group];
                [[RCIM sharedRCIM] refreshGroupInfoCache:group
                                             withGroupId:group.groupId];
            }];
}

- (IBAction)addUserToGroupClick:(UIButton *)sender {
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",XBaseURL,@"group/group_add"];
    
    NSDictionary *dic = @{
                          @"id":self.groupId,
                          @"user_id":[USER_D objectForKey:@"user_id"]
                          };
    NSLog(@"%@",dic);
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    session.requestSerializer.timeoutInterval = 5.0;
    [session POST:urlStr parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success:%@",responseObject);
        
        NSLog(@"%@",[MyTool dictionaryToJson:responseObject]);
        
        NSString *msgStr = [responseObject objectForKey:@"msg"];
        NSNumber *msg = (NSNumber *)msgStr;
        if ([msg isEqualToNumber:@1]) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            [SVProgressHUD dismiss];
        } else {
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
            [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"data"]];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        KMLog(@"Error:%@",error);
    }];
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
