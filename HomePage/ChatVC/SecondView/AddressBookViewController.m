//
//  AddressBookViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/14.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "AddressBookViewController.h"

#import "SDContactModel.h"
#import "SDContactsTableViewCell.h"

#import "MyChatConversationViewController.h"

#import "RCDataBaseManager.h"

#import <AFNetworking.h>
#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>
#import <RongIMKit/RongIMKit.h>

#define HEXCOLOR(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface AddressBookViewController ()
{
    NSArray                 *_adddataArray;
}
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray *sectionArray;

@property (nonatomic, strong) NSMutableArray *sectionTitlesArray;

@property(nonatomic, assign) BOOL hasSyncFriendList;

@end

@implementation AddressBookViewController
{
    NSInteger tag;
    BOOL isSyncFriends;
}
+ (instancetype)addressBookViewController {
    return [[self alloc]init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, My_Screen_Width, My_Screen_Height-114) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = HEXCOLOR(0xf0f0f6);
    //    self.friendsTabelView.separatorColor = HEXCOLOR(0xdfdfdf);
    self.tableView.rowHeight = [SDContactsTableViewCell fixedHeight];
    self.tableView.tableHeaderView = [self searchHeadTableView];
    self.tableView.tableFooterView = [UIView new];
    
    //设置右侧索引
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = HEXCOLOR(0x555555);
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 14, 0, 0)];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0, 14, 0, 0)];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",XBaseURL,XUserFriendURL];
    
    NSDictionary *dic = @{
                          @"id":[USER_D objectForKey:@"user_id"],
                          };
    //        NSLog(@"dic:%@",dic);
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    //    session.requestSerializer.timeoutInterval = 5.0;
    [session POST:urlStr parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success:%@",responseObject);
        
        NSLog(@"%@",[MyTool dictionaryToJson:responseObject]);
        
        NSString *msgStr = [responseObject objectForKey:@"msg"];
        NSNumber *msg = (NSNumber *)msgStr;
        if ([msg isEqualToNumber:@1]) {
            if (_adddataArray == nil) {
                _adddataArray = [NSMutableArray array];
            }
            _adddataArray = [responseObject objectForKey:@"data"];
            
            for (int i = 0; i < _adddataArray.count; i ++) {
//                NSLog(@"~~~%@", [[_adddataArray objectAtIndex:_adddataArray.count-1] objectForKey:@"name"]);
                
                SDContactModel *model = [SDContactModel new];
                
                model.name = [[[_adddataArray objectAtIndex:i] objectForKey:@"user"] objectForKey:@"name"];
                model.imageName = [[[_adddataArray objectAtIndex:i] objectForKey:@"user"] objectForKey:@"head_img"];
                model.wxId = [[[_adddataArray objectAtIndex:i] objectForKey:@"user"] objectForKey:@"id"];
                [self.dataArray addObject:model];
            }
            [self setUpTableSection];
            
            [self.tableView reloadData];
        } else {
            self.dataArray = [NSMutableArray array];
            
            [self setUpTableSection];
            
            [self.tableView reloadData];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        KMLog(@"Error:%@",error);
    }];
}

- (void)setUpTableSection {
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    //create a temp sectionArray
    NSUInteger numberOfSections = [[collation sectionTitles] count];
    NSMutableArray *newSectionArray =  [[NSMutableArray alloc]init];
    for (NSUInteger index = 0; index<numberOfSections; index++) {
        [newSectionArray addObject:[[NSMutableArray alloc]init]];
    }
    
    // insert Persons info into newSectionArray
    for (SDContactModel *model in self.dataArray) {
        NSUInteger sectionIndex = [collation sectionForObject:model collationStringSelector:@selector(name)];
        [newSectionArray[sectionIndex] addObject:model];
    }
    
    //sort the person of each section
    for (NSUInteger index=0; index<numberOfSections; index++) {
        NSMutableArray *personsForSection = newSectionArray[index];
        NSArray *sortedPersonsForSection = [collation sortedArrayFromArray:personsForSection collationStringSelector:@selector(name)];
        newSectionArray[index] = sortedPersonsForSection;
    }
    NSMutableArray *temp = [NSMutableArray new];
    self.sectionTitlesArray = [NSMutableArray new];
    
    [newSectionArray enumerateObjectsUsingBlock:^(NSArray *arr, NSUInteger idx, BOOL *stop) {
        if (arr.count == 0) {
            [temp addObject:arr];
        } else {
            [self.sectionTitlesArray addObject:[collation sectionTitles][idx]];
        }
    }];
    [newSectionArray removeObjectsInArray:temp];
    
    NSMutableArray *operrationModels = [NSMutableArray new];
    NSArray *dicts = @[@{@"name" : @"群聊", @"imageName" : @"icon_group-chat-qun"}, ];
    for (NSDictionary *dict in dicts) {
        SDContactModel *model = [SDContactModel new];
        model.name = dict[@"name"];
        model.imageName = dict[@"imageName"];
        [operrationModels addObject:model];
    }
    [newSectionArray insertObject:operrationModels atIndex:0];
    [self.sectionTitlesArray insertObject:@"" atIndex:0];
    
    self.sectionArray = newSectionArray;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}

- (UIView *)searchHeadTableView {
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, My_Screen_Width, 50)];
    _searchBar.delegate = self;
    
    //    //改变searchBar的默认颜色
    //    UIView *segment = [searchBar.subviews objectAtIndex:0];
    //    [segment removeFromSuperview];
    //    searchBar.backgroundColor = [UIColor colorWithRed:238/255.f green:238/255.f blue:238/255.f alpha:.5f];
    //
    //    //改变searchBar的键盘划出类型
    //    UITextField *searchTF = [[searchBar subviews] lastObject];
    //    [searchTF setReturnKeyType:UIReturnKeyDone];
    //
    //    searchBar.barStyle = UIBarStyleBlackTranslucent;
    //    searchBar.keyboardType = UIKeyboardTypeDefault;
    _searchBar.placeholder = @"搜索";
    return _searchBar;
}

#pragma mark - tableView Delegate && DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.01;
    } else {
        return 20.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {    
    return self.sectionTitlesArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sectionArray[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sectionTitlesArray objectAtIndex:section];
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.sectionTitlesArray;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"SDContacts";
    SDContactsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[SDContactsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    SDContactModel *model = self.sectionArray[section][row];
    cell.model = model;
    
    NSLog(@"%@",model.imageName);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.selected = NO;  //（这种是点击的时候有效果，返回后效果消失）
    
    if (indexPath.section == 0) {
        
    } else {
        SDContactModel *model = self.sectionArray[indexPath.section][indexPath.row];
        
        //新建一个聊天会话View Controller对象
        MyChatConversationViewController *chat = [[MyChatConversationViewController alloc]init];
        //设置会话的类型，如单聊、讨论组、群聊、聊天室、客服、公众服务会话等
        chat.conversationType = ConversationType_PRIVATE;
        //设置会话的目标会话ID。（单聊、客服、公众服务会话为对方的ID，讨论组、群聊、聊天室为会话的ID）
        chat.targetId = model.wxId;
        //设置聊天会话界面要显示的标题
        
//        KMLog(@"~!~!~!~%@",model.conversationTitle);
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        title.text = model.name;
        title.textAlignment = NSTextAlignmentCenter;
        title.textColor = [UIColor whiteColor];
        chat.navigationItem.titleView = title;
//        chat.title = title.text;
//        chat.navigationItem.title
        chat.hidesBottomBarWhenPushed = YES;
        //    chat.userName = model.conversationTitle;
        //显示聊天会话界面
//        [self.delegate MyMessagePushViewColltroller:chat];
//        [self.navigationController pushViewController:chat animated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_searchBar resignFirstResponder];
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
