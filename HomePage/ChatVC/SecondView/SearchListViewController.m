//
//  SearchListViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/12.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "SearchListViewController.h"

#import "AddFridensDataViewController.h"

#import <AFNetworking.h>
#import <SVProgressHUD.h>

@interface SearchListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property(strong, nonatomic) NSMutableArray *searchDataSource;

@end

@implementation SearchListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor clearColor];
    
//    _lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, My_Screen_Width, 50)];
//    [self.view addSubview:_lab];
        
    [self.view addSubview:self.tableView];
    
}

- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _tableView;
}

- (NSMutableArray *)searchDataSource {
    if (_searchDataSource == nil) {
        _searchDataSource = [NSMutableArray array];
    }
    return _searchDataSource;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [[self.searchDataSource objectAtIndex:indexPath.row] objectForKey:@"search"];
    
    return cell;
}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
//    NSLog(@"%@", searchController.searchBar.text);
    
    
    [self.searchDataSource removeAllObjects];
    
//    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", searchController.searchBar.text];
//   
//    NSLog(@"%@",searchPredicate);
    
    self.searchDataSource = [NSMutableArray arrayWithObjects:@{@"search":searchController.searchBar.text}, nil];
    
//    self.searchDataSource = [[self.dataSource filteredArrayUsingPredicate:searchPredicate] mutableCopy];
    
//    NSLog(@"%@",self.searchDataSource);
    
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@", self.searchDataSource[indexPath.row]);
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    [SVProgressHUD showWithStatus:@"正在加载"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",XBaseURL,XUserQueryFriendsURL];
    
    NSDictionary *dic = @{
                          @"mobile":[[self.searchDataSource objectAtIndex:indexPath.row] objectForKey:@"search"],
                          };
    //        NSLog(@"dic:%@",dic);
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
        session.requestSerializer.timeoutInterval = 5.0;
    [session POST:urlStr parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success:%@",responseObject);
        
        KMLog(@"%@",[MyTool dictionaryToJson:responseObject]);
        
        NSString *msgStr = [responseObject objectForKey:@"msg"];
        NSNumber *msg = (NSNumber *)msgStr;
        if ([msg isEqualToNumber:@1]) {
            
            AddFridensDataViewController *addFriendsDataVC = [[AddFridensDataViewController alloc] initWithUserData:[responseObject objectForKey:@"data"]];
            [self.delegate AddFriendPushViewColltroller:addFriendsDataVC];
            [SVProgressHUD dismiss];
        } else {
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
            [SVProgressHUD showErrorWithStatus:@"该用户不存在"];
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
