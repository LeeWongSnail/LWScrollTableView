//
//  ArtWorkType.h
//  DesignBox
//
//  Created by LeeWong on 15/9/1.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "ArtFilterModel.h"

@interface ArtWorkFilterOption : NSObject

@property (nonatomic, strong) NSString* categoryID; // 分类
@property (nonatomic, strong) NSString* provinceID; // 省份
@property (nonatomic, strong) NSString* sourceID; // 来源
@property (nonatomic, strong) NSString* sortID; // 排序

@end

@interface ArtWorkFilterModel : ArtFilterModel

@property (nonatomic, strong, readonly) NSArray* provinceList; // 省份
@property (nonatomic, strong, readonly) NSArray* sourceList; // 来源
@property (nonatomic, strong, readonly) NSArray* sortList; // 排序

@property (nonatomic, strong, readonly) NSArray* filterTitles; // 筛选标题列表
@property (nonatomic, strong, readonly) NSArray* filterDetails; // 筛选全部内容
@property (nonatomic, strong, readonly) NSDictionary* filterSelected; // 筛选已选项

@property (nonatomic, assign, readonly) BOOL hasFilter; //是否筛选过

+ (instancetype)shared;


// 数据
- (NSDictionary *)categoryForID:(NSString *)aID;


@end
