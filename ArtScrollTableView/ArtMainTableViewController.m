//
//  ArtMainTableViewController.m
//  ArtScrollTableView
//
//  Created by LeeWong on 16/8/27.
//  Copyright © 2016年 LeeWong. All rights reserved.
//

#import "ArtMainTableViewController.h"
#import "ArtSubTableViewController.h"
#import "ArtWorkFilterModel.h"
#import "ArtScrollTab.h"

@interface ArtMainTableViewController () <UIPageViewControllerDelegate,UIPageViewControllerDataSource,UIScrollViewDelegate>

@property (nonatomic, strong) UIPageViewController* pageViewController;
@property (nonatomic, strong) ArtScrollTab* scrollTab;
@property (nonatomic, strong) ArtWorkFilterModel *workFilterModel;
@property (nonatomic, assign) BOOL pageDoingScroll;
@property (nonatomic, assign) BOOL isCurrentPage;

@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabView;

@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabViewPre;

@property (nonatomic, assign) BOOL canScroll;

@end

@implementation ArtMainTableViewController

-(void)acceptMsg : (NSNotification *)notification{
    //NSLog(@"%@",notification);
    NSDictionary *userInfo = notification.userInfo;
    NSString *canScroll = userInfo[@"canScroll"];
    if ([canScroll isEqualToString:@"1"]) {
        _canScroll = YES;
        self.tableView.scrollEnabled = YES;
    }
}


- (void)buildMainView
{

    
    //    WEAKSELF(weakSelf);
    [self.workFilterModel setContentViewController:^UIViewController *(NSDictionary *info) {
        ArtSubTableViewController *controller = [[ArtSubTableViewController alloc] init];
        controller.view.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255. green:arc4random_uniform(255)/255. blue:arc4random_uniform(255)/255. alpha:1.];
        return controller;
    }];
    
    @weakify(self)
    [RACObserve(self.scrollTab, currentIndex) subscribeNext:^(NSNumber* aIndex) {
        //1.点击切换分类 idx得到的是切换之前的分类的index aIndex是当前点击的分类的index
        //2.滑动切换分类 idx得到的是切换之后的分类的index aIndex是切换之后的分类的index
        //用isCurrentPage 来标记是通过哪种方式来切换分类的
        @strongify(self)
        NSInteger idx = [self.workFilterModel indexOfPageController:self.pageViewController.viewControllers.firstObject];
        if (idx != [aIndex integerValue]) {
            _pageDoingScroll = YES;
            UIViewController* vc = [self.workFilterModel pageControllerAtIndex:[aIndex integerValue]];
            [self.pageViewController setViewControllers:@[vc]
                                              direction:UIPageViewControllerNavigationDirectionForward
                                               animated:NO
                                             completion:^(BOOL finished) {
                                                 _pageDoingScroll = NO;
                                             }];
            
        } else {
            if (!self.isCurrentPage) {
                ArtSubTableViewController* vc = (ArtSubTableViewController *)[self.workFilterModel pageControllerAtIndex:[aIndex integerValue]];
                if ([vc isKindOfClass:[ArtSubTableViewController class]]) {
                    //可以实现返回到顶部
                }
            }else
            {
                self.isCurrentPage = NO;
            }
        }
    }];
    
    RAC(self.workFilterModel, categoryListIndex) = RACObserve(self.scrollTab, currentIndex);
    
    
    
    [self createPageViewPageIndex:0];
}

- (void)createPageViewPageIndex:(NSInteger)aIndex
{
    NSDictionary* options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin] forKey:UIPageViewControllerOptionSpineLocationKey];
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
    
    self.pageViewController.dataSource = self;
    
    [self addChildViewController:self.pageViewController];
    
    [self.pageViewController setViewControllers:@[[self.workFilterModel pageControllerAtIndex:aIndex]]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
    
    [self.pageViewController didMoveToParentViewController:self];
    self.pageViewController.delegate = self;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
        self.workFilterModel = [ArtWorkFilterModel shared];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"TableViewCell"];
    
    self.workFilterModel = [ArtWorkFilterModel shared];
    [self buildMainView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:kLeaveTopNotificationName object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 2;
        case 2:
            return 1;
        default:
            break;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    

    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 2) {
        [cell.contentView addSubview:self.pageViewController.view];
        [self.pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell.contentView);
        }];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"第%tu行",indexPath.row];
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        return CGRectGetHeight(self.view.frame)-64-49;;
    }
    return 44;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 2) {
        ArtScrollTab* scrollTab = [[ArtScrollTab alloc] initWithFrame:CGRectZero];
        scrollTab.backgroundColor = [UIColor greenColor];
        self.scrollTab = scrollTab;
        
        NSMutableArray* items = [NSMutableArray array];
        [self.workFilterModel.categoryList enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
            [items addObject:[[UITabBarItem alloc] initWithTitle:obj[@"name"] image:nil tag:0]];
        }];
        
        [scrollTab setTabItems:items];
        
        return scrollTab;
    }
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0000001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 2) {
       return [ArtScrollTab height];
    }
    return 0;
}


#pragma mark - UIPageViewControllerDelegate UIPageViewControllerDataSource

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController viewControllerBeforeViewController:(UIViewController*)viewController
{
    NSInteger idx = [self.workFilterModel indexOfPageController:viewController];
    return [self.workFilterModel pageControllerAtIndex:idx - 1];
}

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController viewControllerAfterViewController:(UIViewController*)viewController
{
    NSInteger idx = [self.workFilterModel indexOfPageController:viewController];
    return [self.workFilterModel pageControllerAtIndex:idx + 1];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (finished) {
        NSInteger idx = [self.workFilterModel indexOfPageController:pageViewController.viewControllers.firstObject];
        self.scrollTab.currentIndex = idx;
        
        [self.workFilterModel removeMoreCachedViewController:idx];
    }
}

#pragma mark - UISCrollviewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat tabOffsetY = [self.tableView rectForSection:2].origin.y;
    CGFloat offsetY = scrollView.contentOffset.y + 64;
    NSLog(@"offsetY ----- %f",offsetY);
    NSLog(@"tabOffsetY ----- %f",tabOffsetY);
    _isTopIsCanNotMoveTabViewPre = _isTopIsCanNotMoveTabView;
    
    if (offsetY>=tabOffsetY) {
        scrollView.contentOffset = CGPointMake(0, tabOffsetY);
        _isTopIsCanNotMoveTabView = YES;
    }else{
        _isTopIsCanNotMoveTabView = NO;
    }
    
    if (_isTopIsCanNotMoveTabView != _isTopIsCanNotMoveTabViewPre) {
        if (!_isTopIsCanNotMoveTabViewPre && _isTopIsCanNotMoveTabView) {
            //NSLog(@"滑动到顶端");
            [[NSNotificationCenter defaultCenter] postNotificationName:kGoTopNotificationName object:nil userInfo:@{@"canScroll":@"1"}];
            _canScroll = NO;
            self.tableView.scrollEnabled = NO;
        }
        if(_isTopIsCanNotMoveTabViewPre && !_isTopIsCanNotMoveTabView){
            //NSLog(@"离开顶端");
            if (!_canScroll) {
                scrollView.contentOffset = CGPointMake(0, tabOffsetY);
            }
            self.tableView.scrollEnabled = YES;
        }
    }
}
@end
