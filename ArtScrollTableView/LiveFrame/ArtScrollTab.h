//
//  ArtScrollTab.h
//  DesignBox
//
//  Created by zhaoguogang on 8/25/15.
//  Copyright (c) 2015 GK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArtScrollTab : UIView

@property (nonatomic, strong) NSArray* tabItems; // UITabBarItem
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) NSInteger currentTag;
@property (nonatomic, strong, readonly) UIButton* moreBtn;

+ (CGFloat)height;

@end
