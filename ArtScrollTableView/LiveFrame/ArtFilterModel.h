//
//  ArtFilterModel.h
//  DesignBox
//
//  Created by zhaoguogang on 15/9/7.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString* kArtFilterAllFilterIDKey;

@interface ArtFilterModel : NSObject

- (id)initWithType:(NSString *)aType;

@property (nonatomic, assign) BOOL hasCheck;

@property (nonatomic, strong) NSArray* categoryList; // 分类
@property (nonatomic, strong) NSArray* categoryNameList; // 分类
@property (nonatomic, assign) NSInteger categoryListIndex; // 分类


// 排序
- (void)mergeCategoryList:(NSArray *)aCategoryList;
- (void)setCategorySort:(NSArray *)aCategoryList;

- (NSArray *)getNamesFromContents:(NSArray *)aContents;
- (NSString *)getIDFromContents:(NSArray *)aContents forName:(NSString *)aName;
- (NSString *)getNameFromContents:(NSArray *)aContents forID:(NSString *)aID;

- (void)removeMoreCachedViewController:(NSInteger)aIndex;
- (void)onlyCachedCurrentContentViewController:(NSInteger)aIndex;
- (void)setContentViewController:(UIViewController *(^)(NSDictionary* info))aContentVCBlock;
- (UIViewController *)pageControllerAtIndex:(NSInteger)aIndex;
- (NSInteger)indexOfPageController:(UIViewController *)aViewController;

@end
