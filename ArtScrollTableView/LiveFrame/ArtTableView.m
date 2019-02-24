//
//  ArtTableView.m
//  ArtScrollTableView
//
//  Created by LeeWong on 16/8/27.
//  Copyright © 2016年 LeeWong. All rights reserved.
//

#import "ArtTableView.h"

@implementation ArtTableView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.tableHeaderView && CGRectContainsPoint(self.tableHeaderView.frame, point)) {
        return NO;

    }
    return [super pointInside:point withEvent:event];
}




@end
