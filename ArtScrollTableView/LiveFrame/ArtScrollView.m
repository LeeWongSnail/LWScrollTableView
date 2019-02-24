//
//  ArtScrollView.m
//  ArtScrollTableView
//
//  Created by LeeWong on 2019/2/18.
//  Copyright © 2019年 LeeWong. All rights reserved.
//

#import "ArtScrollView.h"

@implementation ArtScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
