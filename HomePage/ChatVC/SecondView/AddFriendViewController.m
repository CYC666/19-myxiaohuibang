//
//  AddFriendViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/7.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "AddFriendViewController.h"

@interface AddFriendViewController ()

@end

@implementation AddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"添加朋友";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;
    
    SearchListViewController *resultsController = [[SearchListViewController alloc] init];
//    resultsController.dataSource = self.dataArray;
    resultsController.delegate = self;
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:resultsController];
    
    self.searchController.searchResultsUpdater = resultsController;
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.placeholder = @"请输入手机号查找";
    
    [self.view addSubview: self.tableView];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
}

- (void)AddFriendPushViewColltroller:(UIViewController *)AddFriendViewColltroller {
    [self.navigationController pushViewController:AddFriendViewColltroller animated:YES];
}

//- (NSArray *)dataArray {
//    if (_dataArray == nil) {
//        NSMutableArray *tempArray = [NSMutableArray array];
//        for (int i = 0 ; i< 100; i ++) {
//            NSString *number = [NSString stringWithFormat:@"%d",i];
//            [tempArray addObject:number];
//        }
//        _dataArray = tempArray.copy;
//    }
//    return _dataArray;
//}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, My_Screen_Width, My_Screen_Height) style:UITableViewStylePlain];
//        _tableView.dataSource = self;                                                                                                                                                                                                                                                                                                       
//        _tableView.delegate = self;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _tableView;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    // Configure the cell...
    cell.textLabel.text = self.dataArray[indexPath.row];
    
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
