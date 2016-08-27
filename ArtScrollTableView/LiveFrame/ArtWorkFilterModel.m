//
//  ArtWorkType.m
//  DesignBox
//
//  Created by LeeWong on 15/9/1.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "ArtWorkFilterModel.h"


static NSString* const kFilterTypeCategory = @"分类";
static NSString* const kFilterTypeSource = @"来源";
static NSString* const kFilterTypeSort = @"排序";
static NSString* const kFilterTypeProvince = @"省份";

@implementation ArtWorkFilterOption

@end

@interface ArtWorkFilterModel ()

@property (nonatomic, strong) NSArray* provinceList; // 省份
@property (nonatomic, strong) NSArray* sourceList; // 来源
@property (nonatomic, strong) NSArray* sortList; // 排序

@property (nonatomic, strong) NSArray* provinceNameList; // 省份
@property (nonatomic, strong) NSArray* sourceNameList; // 来源
@property (nonatomic, strong) NSArray* sortNameList; // 排序

@property (nonatomic, strong) NSMutableDictionary* filterOptionCache;

@end

@implementation ArtWorkFilterModel

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static id shared;
    dispatch_once(&onceToken, ^{
        shared = [[[self class] alloc] init];
    });
    
    return shared;
}

- (id)init
{
    self = [super initWithType:@"1"];
    if (self) {
        self.categoryList = @[@{@"name":@"关注",@"_id":@"1"}, @{@"name":@"热门",@"_id":@"2"}, @{@"name":@"最新",@"_id":@"3"}];
        self.sortNameList = [self getNamesFromContents:self.sortList];
        self.filterOptionCache = [NSMutableDictionary dictionary];
    }
    return self;
}



#pragma mark - Fetch 


- (NSDictionary *)categoryForID:(NSString *)aID
{
    __block NSDictionary* rt = nil;
    [self.categoryList enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
        if ([[obj objectForKey:@"_id"] isEqualToString:aID]) {
            rt = obj;
            *stop = YES;
        }
    }];
    
    return rt;
}


- (ArtWorkFilterOption *)currentFilterOption
{
    NSDictionary* category = self.categoryList[self.categoryListIndex];
    return [self filterOptionForCategoryID:category[@"_id"]];
}

- (ArtWorkFilterOption *)filterOptionForCategoryID:(NSString *)aID
{
    ArtWorkFilterOption* option = [self.filterOptionCache objectForKey:aID];
    if (option == nil) {
        option = [[ArtWorkFilterOption alloc] init];
        option.categoryID = aID;
        option.sortID =  [(NSDictionary *)self.sortList.firstObject objectForKey:@"_id"];
        [self.filterOptionCache setObject:option forKey:aID];
    }
    
    return option;
}

@end
