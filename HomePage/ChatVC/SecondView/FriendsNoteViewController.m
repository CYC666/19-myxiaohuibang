//
//  FriendsNoteViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/13.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "FriendsNoteViewController.h"

@interface FriendsNoteViewController ()

@end

@implementation FriendsNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"备注信息";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;
    
    UITableView *noteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, My_Screen_Width, My_Screen_Height) style:UITableViewStyleGrouped];
    noteTableView.delegate = self;
    noteTableView.dataSource = self;
    [self.view addSubview:noteTableView];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, My_Screen_Height, 45)];
        view.backgroundColor = [UIColor clearColor];
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, My_Screen_Height-30, 30)];
        lab.text = @"备注名";
        lab.textColor = [UIColor grayColor];
        lab.font = [UIFont systemFontOfSize:14];
        [view addSubview:lab];
        
        return view;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    UITextField *phoneTF = [[UITextField alloc] initWithFrame:CGRectMake(15, 5, 200, 45)];
    phoneTF.placeholder = @"王土豪";
    [cell.contentView addSubview:phoneTF];
    
    return cell;
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
