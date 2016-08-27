//
//  ArtScrollTab.m
//  DesignBox
//
//  Created by zhaoguogang on 8/25/15.
//  Copyright (c) 2015 GK. All rights reserved.
//

#import "ArtScrollTab.h"

static CGFloat const kItemCtrlLeftRightMargin = 13.; // 按钮左右空白
static CGFloat const kIndicatorHeight = 2;
static CGFloat const kIndicatorLeftRightMargin = -4;
static CGFloat const kIndicatorBottomMargin = 0.;

@interface ArtScrollTab ()
{
    NSArray* _tabItems;
    NSInteger _currentIndex;
    NSMutableArray* _itemControls;
    UIScrollView* _scrollView;
    UIView* _indicatorView;
}

@property (nonatomic, strong) UIButton* moreBtn;
@property (nonatomic, assign) BOOL isMoreBtnRotation;

@property (nonatomic, strong) UIColor* normalColor;
@property (nonatomic, strong) UIColor* selectedColor;


@property (nonatomic, strong) UIView* moreCustomeView;

@property (nonatomic, assign) BOOL isShowMoreView;

@end

@implementation ArtScrollTab

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.backgroundColor = [UIColor whiteColor];
    
    _itemControls = [NSMutableArray array];
    
    self.moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.moreBtn setImage:[UIImage imageNamed:@"scrolltab_arrow_down"] forState:UIControlStateNormal];
    [self addSubview:self.moreBtn];
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@([self moreControlWidth]));
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
        make.right.equalTo(self.mas_right);
    }];
    
    @weakify(self);
    [[self.moreBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        
        if (self.moreCustomeView) {
            [self bringSubviewToFront:self.moreCustomeView];
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            
            self.userInteractionEnabled = NO;
            
            if (self.isMoreBtnRotation) {
                self.isShowMoreView = NO;
                
                self.moreBtn.imageView.transform = CGAffineTransformIdentity;
                self.isMoreBtnRotation = NO;
                
                // Hide More View
                if (self.moreCustomeView) {
                    self.moreCustomeView.alpha = 0.;
                }
            } else {
                self.isShowMoreView = YES;
                
                self.moreBtn.imageView.transform = CGAffineTransformRotate(self.moreBtn.imageView.transform, -M_PI/2.);
                self.moreBtn.imageView.transform = CGAffineTransformRotate(self.moreBtn.imageView.transform, -M_PI/2.);
                
                self.isMoreBtnRotation = YES;
                // Show More View
                if (self.moreCustomeView) {
                    self.moreCustomeView.hidden = NO;
                    self.moreCustomeView.alpha = 1.;
                }
            }
        } completion:^(BOOL finished) {
            
            if (self.moreCustomeView && !self.isMoreBtnRotation) {
                self.moreCustomeView.hidden = YES;
            }
            
            self.userInteractionEnabled = YES;
        }];
    }];
    
    self.normalColor = [UIColor grayColor];
    self.selectedColor = [UIColor redColor];
    
    return self;
}

+ (CGFloat)height
{
    return 39.;
}

- (void)setTabItems:(NSArray *)tabItems
{
    _tabItems = tabItems;
    
    [self constructItemControls];
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex = currentIndex;
    
    UIButton* btn = [_itemControls objectAtIndex:currentIndex];
    [UIView animateWithDuration:0.2 animations:^{
        _indicatorView.center = CGPointMake(btn.center.x, _indicatorView.center.y);
        _indicatorView.transform = CGAffineTransformMakeScale((btn.frame.size.width - kItemCtrlLeftRightMargin * 2 - kIndicatorLeftRightMargin*2)/_indicatorView.frame.size.width, 1.);
    } completion:^(BOOL finished) {
        _indicatorView.transform = CGAffineTransformIdentity;
        
        [_indicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(btn.mas_left).offset(kItemCtrlLeftRightMargin + kIndicatorLeftRightMargin);
            make.right.equalTo(btn.mas_right).offset(-kItemCtrlLeftRightMargin - kIndicatorLeftRightMargin);
            make.height.equalTo(@(kIndicatorHeight));
            make.bottom.equalTo(self.mas_bottom).offset(-kIndicatorBottomMargin);
        }];
        
        if (_scrollView) {
            [_scrollView scrollRectToVisible:CGRectInset(btn.frame, -(self.itemControlLimitWidth - btn.frame.size.width)/2., 0.) animated:YES];
        }
    }];
}

- (void)setMoreCustomeView:(UIView *)moreCustomeView
{
    if (_moreCustomeView) {
        [_moreCustomeView removeFromSuperview];
    }
    _moreCustomeView = moreCustomeView;
    
    if (_moreCustomeView) {
        _moreCustomeView.alpha = 0.;
        _moreCustomeView.hidden = YES;
        [self addSubview:_moreCustomeView];
        [_moreCustomeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom);
            make.right.equalTo(@(-[self moreControlWidth]));
        }];
        
        [self bringSubviewToFront:_moreCustomeView];
    }
}

- (void)rotateMoreBtn
{
    [UIView animateWithDuration:0.2 animations:^{
        if (self.isMoreBtnRotation) {
            self.moreBtn.imageView.transform = CGAffineTransformIdentity;
            self.isMoreBtnRotation = NO;
        } else {
            self.moreBtn.imageView.transform = CGAffineTransformRotate(self.moreBtn.imageView.transform, -M_PI/2.);
            self.moreBtn.imageView.transform = CGAffineTransformRotate(self.moreBtn.imageView.transform, -M_PI/2.);
            
            self.isMoreBtnRotation = YES;
        }
    }];
}

#pragma mark - Construct
- (CGFloat)itemControlLimitWidth
{
    return SCREEN_W - self.moreControlWidth;
}

- (CGFloat)moreControlWidth
{
    return 44.;
}

- (CGFloat)caculateTotalWidth
{
    UIFont* itemFont = [UIFont systemFontOfSize:14];
    
    __block CGFloat totalWidth = 0.;
    [_tabItems enumerateObjectsUsingBlock:^(UITabBarItem* obj, NSUInteger idx, BOOL *stop) {
        NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:itemFont, NSFontAttributeName, nil];
        CGSize size = [obj.title sizeWithAttributes:attributes];
        
        totalWidth += (size.width + kItemCtrlLeftRightMargin * 2.);
    }];
    
    return totalWidth;
}

- (void)constructItemControls
{
    _currentIndex = 0;
    
    [_scrollView removeFromSuperview];
    _scrollView = nil;
    
    [_itemControls enumerateObjectsUsingBlock:^(UIView* obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    [_itemControls removeAllObjects];
    
    [_indicatorView removeFromSuperview];
    _indicatorView = nil;
    _indicatorView = [[UIView alloc] initWithFrame:CGRectZero];
    _indicatorView.backgroundColor = self.selectedColor;

    if (_tabItems.count > 0) {
        CGFloat totalWidth = [self caculateTotalWidth];
        if (totalWidth >= [self itemControlLimitWidth]) {
            [self constructScrollControls:totalWidth];
        } else {
            [self constructFixControls];
        }
    }
}

- (UIButton *)createBtnWithItem:(UITabBarItem *)aItem index:(NSInteger)aIndex
{
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:aItem.title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    @weakify(self);
    btn.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(UIButton* btn) {
        @strongify(self);
        self.currentIndex = aIndex;
        self.currentTag = aItem.tag;
        return [RACSignal empty];
    }];

    return btn;
}

- (void)constructScrollControls:(CGFloat)aTotalWidth
{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.scrollEnabled = YES;
    _scrollView.scrollsToTop = NO;
    [self addSubview:_scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right).offset(-[self moreControlWidth]);
    }];
    _scrollView.contentSize = CGSizeMake(aTotalWidth, [[self class] height]);
    
    __block CGFloat centerX = 0.;
    UIFont* itemFont = [UIFont systemFontOfSize:14];
    [_tabItems enumerateObjectsUsingBlock:^(UITabBarItem* obj, NSUInteger idx, BOOL *stop) {
        UIButton* btn = [self createBtnWithItem:obj index:idx];
        btn.titleLabel.font = itemFont;
        
        NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:itemFont, NSFontAttributeName, nil];
        CGSize size = [obj.title sizeWithAttributes:attributes];
        
        CGFloat width = size.width + kItemCtrlLeftRightMargin * 2.;
        
        btn.frame = CGRectMake(0., 0., width, [[self class] height]);
        
        centerX += width / 2.;
        btn.center = CGPointMake(centerX, [[self class] height]/2.);
        centerX += width / 2.;
        
        [_scrollView addSubview:btn];
        
        [_itemControls addObject:btn];
        
        if (idx == 0) {
            [_scrollView addSubview:_indicatorView];
            
            [_indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(btn.mas_left).offset(kItemCtrlLeftRightMargin+kIndicatorLeftRightMargin);
                make.right.equalTo(btn.mas_right).offset(-kItemCtrlLeftRightMargin-kIndicatorLeftRightMargin);
                make.height.equalTo(@(kIndicatorHeight));
                make.bottom.equalTo(self.mas_bottom).offset(-kIndicatorBottomMargin);
            }];
        }
    }];
}

- (void)constructFixControls
{
    __block CGFloat centerX = 0.;
    CGFloat width = self.itemControlLimitWidth / _tabItems.count;
//    UIFont* itemFont = [[[ArtUIStyle styleForKey:@"App"] styleForKey:@"ScrollTab"] font];
    UIFont *itemFont = [UIFont systemFontOfSize:14];
    [_tabItems enumerateObjectsUsingBlock:^(UITabBarItem* obj, NSUInteger idx, BOOL *stop) {
        UIButton* btn = [self createBtnWithItem:obj index:idx];
        btn.titleLabel.font = itemFont;
        
        btn.frame = CGRectMake(0., 0., width, [[self class] height]);
        
        centerX += width / 2.;
        btn.center = CGPointMake(centerX, [[self class] height]/2.);
        centerX += width / 2.;
        
        [self addSubview:btn];
        
        [_itemControls addObject:btn];
        
        if (idx == 0) {
            [self addSubview:_indicatorView];
            
            [_indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(btn.mas_left).offset(kItemCtrlLeftRightMargin+kIndicatorLeftRightMargin);
                make.right.equalTo(btn.mas_right).offset(-kItemCtrlLeftRightMargin-kIndicatorLeftRightMargin);
                make.height.equalTo(@(kIndicatorHeight));
                make.bottom.equalTo(self.mas_bottom).offset(-kIndicatorBottomMargin);
            }];
        }
    }];
}

@end
