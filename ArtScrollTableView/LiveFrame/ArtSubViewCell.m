//
//  ArtSubViewCell.m
//  ArtScrollTableView
//
//  Created by LeeWong on 16/8/27.
//  Copyright © 2016年 LeeWong. All rights reserved.
//

#import "ArtSubViewCell.h"
#import "ArtSubTableViewController.h"
#import "ArtThirdViewController.h"
#import "ArtWorkFilterModel.h"
#import "ArtScrollTab.h"

@interface ArtSubViewCell () <UIPageViewControllerDelegate,UIPageViewControllerDataSource>

@property (nonatomic, strong) UIPageViewController* pageViewController;
@property (nonatomic, strong) ArtScrollTab* scrollTab;
@property (nonatomic, strong) ArtWorkFilterModel *workFilterModel;
@property (nonatomic, assign) BOOL pageDoingScroll;
@property (nonatomic, assign) BOOL isCurrentPage;

@end

@implementation ArtSubViewCell

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.workFilterModel = [ArtWorkFilterModel shared];
    [self.workFilterModel setCategoryList:@[@{@"name":@"关注",@"_id":@"1"}, @{@"name":@"热门",@"_id":@"2"}, @{@"name":@"最新",@"_id":@"3"}]];
    [self buildMainView];
}


- (void)buildMainView
{
    
    ArtScrollTab* scrollTab = [[ArtScrollTab alloc] initWithFrame:CGRectZero];
    scrollTab.backgroundColor = [UIColor greenColor];
    self.scrollTab = scrollTab;
    
    NSMutableArray* items = [NSMutableArray array];
    [self.workFilterModel.categoryList enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
        [items addObject:[[UITabBarItem alloc] initWithTitle:obj[@"name"] image:nil tag:0]];
    }];
    
    [scrollTab setTabItems:items];
    
    [self.view addSubview:scrollTab];
    [scrollTab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.height.equalTo(@([ArtScrollTab height]));
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
    }];
    
    //    WEAKSELF(weakSelf);
    //这里的info对应的为上面设置的workFilterModel中的categorylist
    [self.workFilterModel setContentViewController:^UIViewController *(NSDictionary *info) {
        if ([info[@"_id"] isEqualToString:@"2"]) {
            ArtThirdViewController *third = [[ArtThirdViewController alloc] init];
            return third;
        } else {
            ArtSubTableViewController *controller = [[ArtSubTableViewController alloc] init];
            controller.view.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255. green:arc4random_uniform(255)/255. blue:arc4random_uniform(255)/255. alpha:1.];
            return controller;
        }
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
    
    UIView* view = [self.pageViewController view];
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker* make) {
        make.top.equalTo(self.scrollTab.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    self.pageViewController.delegate = self;
    
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

@end
