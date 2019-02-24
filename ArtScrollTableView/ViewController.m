//
//  ViewController.m
//  ArtScrollTableView
//
//  Created by LeeWong on 2019/2/18.
//  Copyright © 2019年 LeeWong. All rights reserved.
//

#import "ViewController.h"
#import "ArtMainTableViewController.h"
#import "ArtScrollView.h"
@interface ViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) ArtScrollView *scrollView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) ArtMainTableViewController *tableVc;
@property (nonatomic, assign) BOOL canScroll;
@end

@implementation ViewController

- (void)buildUI {

    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height + 120);
    self.topView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 150);
    self.tableVc.view.frame = CGRectMake(0, 150, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.canScroll = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;

//    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.top.equalTo(self.scrollView);
//        make.height.equalTo(@150);
//    }];

//    [self.tableVc.view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.topView.mas_bottom);
//        make.bottom.left.right.equalTo(self.scrollView);
//    }];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotify:) name:kTopLeaveTopNotificationName object:nil];
}

- (void)receiveNotify:(NSNotification *)noti {
    if ([noti.name isEqualToString:kTopLeaveTopNotificationName]) {
        self.canScroll = [noti.userInfo[@"canScroll"] boolValue];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.canScroll) {
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 120)];
        return;
    }
    if (scrollView.contentOffset.y >= 120) {
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 120)];
        // 通知其他页面滚动
        [[NSNotificationCenter defaultCenter] postNotificationName:kTopGotoTopNotificationName object:nil userInfo:@{@"canScroll":@"1"}];
        _canScroll = NO;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self buildUI];
}


- (ArtScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[ArtScrollView alloc] initWithFrame:self.view.bounds];
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor blueColor];
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (UIView *)topView {
    if (_topView == nil) {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = [UIColor redColor];
        [self.scrollView addSubview:_topView];
    }
    return _topView;
}

- (ArtMainTableViewController *)tableVc {
    if (_tableVc == nil) {
        _tableVc = [[ArtMainTableViewController alloc] init];
        [self addChildViewController:_tableVc];
        [self.scrollView addSubview:_tableVc.view];
    }
    return _tableVc;
}

@end
