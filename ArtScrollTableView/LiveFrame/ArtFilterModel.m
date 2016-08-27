//
//  ArtFilterModel.m
//  DesignBox
//
//  Created by zhaoguogang on 15/9/7.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "ArtFilterModel.h"
#import <objc/message.h>
#import <objc/runtime.h>

#define kScrollCategoryID @"kScrollCategoryID"
NSString* kArtFilterAllFilterIDKey = @"com.lll.art.all.filter";

@interface ArtFilterModel ()

@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSString* storeKey;

@property (nonatomic, strong) NSMutableDictionary* pageControllers;

@property (nonatomic, strong) UIViewController *(^contentVCBlock)(NSDictionary* info);

@end

@implementation ArtFilterModel

- (id)initWithType:(NSString *)aType
{
    self = [super init];
    
    self.type = aType;
    self.storeKey = [[NSString alloc] initWithFormat:@"category.type.%@", self.type];
    
    self.pageControllers = [NSMutableDictionary dictionary];
        
    return self;
}

#pragma mark - Do Request


#pragma mark - Data
- (NSDictionary *)removeInfoForID:(NSString *)aID list:(NSMutableArray *)aList
{
    __block NSDictionary* rt = nil;
    [aList enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
        if ([obj[@"_id"] isEqualToString:aID]) {
            rt = obj;
            [aList removeObject:obj];
            *stop = YES;
        }
    }];
    
    return rt;
}

- (void)mergeCategoryList:(NSArray *)aCategoryList
{
    if (self.categoryList.count == 0) {
        self.categoryList = [NSArray arrayWithArray:aCategoryList];
        self.categoryNameList = [self getNamesFromContents:self.categoryList];
    } else {
        NSArray* list1 = [NSArray arrayWithArray:self.categoryList];
        NSMutableArray* list2 = [NSMutableArray arrayWithArray:aCategoryList];
        
        NSMutableArray* rt = [NSMutableArray array];
        [list1 enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
            NSDictionary* info = [self removeInfoForID:obj[@"_id"] list:list2];
            if (info) {
                if ([info[@"name"] isEqualToString:obj[@"name"]]) {
                    [rt addObject:obj];
                } else {
                    [rt addObject:info];
                }
            }
        }];
        
        [list2 enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [rt addObject:obj];
        }];
        
        self.categoryList = [NSArray arrayWithArray:rt];
        self.categoryNameList = [self getNamesFromContents:self.categoryList];
    }
}

- (void)setCategorySort:(NSArray *)aCategoryList
{
    self.categoryList = [NSArray arrayWithArray:aCategoryList];
    self.categoryNameList = [self getNamesFromContents:self.categoryList];
    
}


- (NSArray *)getNamesFromContents:(NSArray *)aContents
{
    NSMutableArray* names = [NSMutableArray array];
    [aContents enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
        NSString* name = [obj objectForKey:@"name"];
        if (name) {
            [names addObject:name];
        }
    }];
    return [NSArray arrayWithArray:names];
}

- (NSString *)getIDFromContents:(NSArray *)aContents forName:(NSString *)aName
{
    __block NSString* rt = nil;
    [aContents enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
        NSString* name = [obj objectForKey:@"name"];
        if (name && [aName isEqualToString:name]) {
            rt = [obj objectForKey:@"_id"];
            *stop = YES;
        }
    }];
    
    return rt;
}

- (NSString *)getNameFromContents:(NSArray *)aContents forID:(NSString *)aID
{
    if (aID == nil)
        return [aContents[0] objectForKey:@"name"];
    
    __block NSString* name = 0;
    [aContents enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
        NSString* ID = [obj objectForKey:@"_id"];
        if (ID && [aID isEqualToString:ID]) {
            name = [obj objectForKey:@"name"];
            *stop = YES;
        }
    }];
    
    return name;
}

#pragma mark - Page Controller

- (void)removeAndReleaseContentVCFromPagerViewController:(NSString *)aInfoID
{
    UIViewController *contentVC = [self.pageControllers valueForKey:aInfoID];
    if (contentVC) {
        [self.pageControllers removeObjectForKey:aInfoID];
    }
}

- (void)removeMoreCachedViewController:(NSInteger)aIndex
{
    NSInteger totalCount = [self.categoryList count];
    NSInteger maxCachedCount = 3;
    [self.categoryList enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (aIndex-maxCachedCount > 0 && idx < aIndex-maxCachedCount) {
            //向前超出maxCachedCount 需移除掉
            [self removeAndReleaseContentVCFromPagerViewController:obj[@"_id"]];
        }
        if (aIndex+maxCachedCount < totalCount   && idx > aIndex+maxCachedCount) {
            //向后超出maxCachedCount 需移除掉
            [self removeAndReleaseContentVCFromPagerViewController:obj[@"_id"]];
        }
    }];
}

- (void)onlyCachedCurrentContentViewController:(NSInteger)aIndex
{
    if (aIndex == -1 || aIndex >= [self.categoryList count]) {
        return;
    }
    
    NSDictionary* info = [self.categoryList objectAtIndex:aIndex];
    
    [self.pageControllers enumerateKeysAndObjectsUsingBlock:^(NSString *key, UIViewController *obj, BOOL *stop) {
        if (![key isEqualToString:info[@"_id"]]) {
            [self removeAndReleaseContentVCFromPagerViewController:key];
        }
    }];
}

- (void)setContentViewController:(UIViewController *(^)(NSDictionary* info))aContentVCBlock
{
    self.contentVCBlock = aContentVCBlock;
}

- (UIViewController *)pageControllerAtIndex:(NSInteger)aIndex
{
    if (aIndex == -1 || aIndex >= [self.categoryList count]) {
        return nil;
    }
    
    NSDictionary* info = [self.categoryList objectAtIndex:aIndex];
    
    UIViewController* vc = [self.pageControllers valueForKey:info[@"_id"]];
    if (vc == nil) {
        if (self.contentVCBlock) {
            vc = self.contentVCBlock(info);
        } else {
            vc = [[UIViewController alloc] init];
        }
        objc_setAssociatedObject(vc, kScrollCategoryID, info[@"_id"], OBJC_ASSOCIATION_COPY_NONATOMIC);
        [self.pageControllers setValue:vc forKey:info[@"_id"]];
    }
    return vc;
}

- (NSInteger)indexOfPageController:(UIViewController *)aViewController
{
    NSString* categoryID = objc_getAssociatedObject(aViewController, kScrollCategoryID);
    __block NSInteger index = 0;
    if (categoryID) {
        [self.categoryList enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
            if ([obj[@"_id"] isEqualToString:categoryID]) {
                index = idx;
                *stop = YES;
            }
        }];
    }
    
    return index;
}

@end
