
### 0、前言	
好像最近都没怎么写UI,最近公司有一个新的模块需要一个多级的列表联动,主要涉及到多个列表滚动时滚动对象的控制以及多个可滚动列表滑动手势处理。

废话不多说 先看下UI要求的效果
    
![效果图](https://ws2.sinaimg.cn/large/006tKfTcly1g0hwl9gmv1g305k09vnpd.gif)


### 1、层次拆分

通过下面的图 我们将这个效果整体的UI实现大概画一下(按照比较通用的方式 有些地方可以优化)

![](https://ws3.sinaimg.cn/large/006tKfTcly1g0hsmuviv7j30vf0jy3zd.jpg)

大概的结构就是:

![](https://ws2.sinaimg.cn/large/006tKfTcly1g0hsxic9t1j31nk0n0n0n.jpg)


### 2、需求分析

#### 1 如何让多个可滚动视图手势可以同时相应

在我们搭建好基本框架 去直接滚动视图的时候 我们发现 我们在滚动最内层tableview时 外面是不动的。也就是说 滚动的手势同时只可以有一个响应者。而最顶部的视图肯定是最优先的响应者。

那么如何让多个滚动视图同时相应一个手势呢？

来看下面的方法

```objc

// note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;

```

简单的翻译一下:是否允许多个手势识别器共同识别，一个控件的手势识别后是否阻断手势识别继续向下传播，默认返回NO；如果为YES，响应者链上层对象触发手势识别后，如果下层对象也添加了手势并成功识别也会继续执行，否则上层对象识别后则不再继续传播。

所以我们要做的第一步需要重写这个方法然后返回 YES

#### 2、多滚动视图协同

我们可以先分析一下这种场景下滚动的顺序：

首先,假设我们三层的滚动视图 分别为 A B C 

向上滚动:


| 状态 | A | B | C | 状态结束 |
| --- | --- | --- | --- | --- |
| 状态0 | 开始滚动 | 不可滚动 | 不可滚动 | A 滚动到需要停止的区域(offset = contentsize.h-a.left) |
| 状态1 | 停止滚动 | 开始滚动 | 不可滚动 | B 滚动到需要停止的区域 (offset = contentsize.h-b.left) |
| 状态2 | 不可滚动 | 停止滚动 | 开始滚动 | 滚动到页面底部 |
| 状态3 | 不可滚动 | 不可滚动 | 不可滚动 | C 滚动到顶部(offset == 0) |
| 状态4 | 不可滚动 | 开始滚动 | 停止滚动 | B 滚动到顶部(offset == 0) |
| 状态5 | 开始滚动 | 停止滚动 | 不可滚动 | A 滚动到顶部(offset == 0) 页面整体回到顶部|

那么我们如何控制一个滚动视图是否滚动呢？

这里我们选择的是 设置滚动视图的contentOffset,即在不让某个视图滚动的时候 通过设置其contentOffset.y为某个固定值的方式 不让其滚动。

当然 应该是还有其他的方式,大家可以尝试其他的方式,以及其他的方式可能存在的问题。

#### 多视图之间消息传递

由最开始的部分我们可以看到,整个页面的视图结构层次非常深,这就给我们带来了一个问题: 如何通知各个视图？

这里我们采用的是: 通知 原因也很简单 耦合性最低。


### 具体实现

首先 页面的滚动 我们基本上是通过下面两个属性来控制


| 属性 | 功能 |
| --- | --- |
| canScroll | scrollViewDidScroll方法中判断当前控制器是否可以滚动 默认A为YES B/C 为NO |
| fixOffset | 当scrollView不可以滚动时 将其offset设置为该值 默认为0


#### 首先对于最底层：

默认 canScroll = YES fixOffset = 0


```objc
- (void)ul_scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.canScroll) { // 默认可以滚动
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, kULGroupHomeViewControllerMargin)];
        return;
    }
    if (scrollView.contentOffset.y >= kULGroupHomeViewControllerMargin) { // 当滚动到临界值时
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, kULGroupHomeViewControllerMargin)];
        // 发送 顶部视图到达顶部通知 让第中间的scrollView 滚动
        [[NSNotificationCenter defaultCenter] postNotificationName:kULGroupTopViewGotoTopNotificationName object:nil userInfo:@{kULGroupScrollViewCanScroll:@"1"}];
        _canScroll = NO; // 当自身是否可以滚动设置为NO
    }
}
```

#### 对于中间的那层:

```objc
- (void)ul_scrollViewDidScroll:(UIScrollView *)scrollView {
    // 默认不可以滚动
    if (!self.canScroll) {
        [scrollView setContentOffset:self.fixOffset];
        return;
    }
    
    // 先确认 要停止滚动的位置 
    CGFloat tabOffsetY = [self.tableView rectForSection:1].origin.y;
    
    CGFloat offsetY = scrollView.contentOffset.y;
    // 因为这里调用的比较频繁 这里记录一下之前的状态 
    _preCanMoveTableView = _canMoveTableView;
    // 判断 当前是否到达了临界值(不可滚动 到 可以滚动 )
    if (offsetY>=tabOffsetY) {
        scrollView.contentOffset = CGPointMake(0, tabOffsetY);
        _canMoveTableView = YES;
    }else{
        _canMoveTableView = NO;
    }
    // 如果状态没有变化 那么不用改变
    if (_canMoveTableView != _preCanMoveTableView) {
        if (!_preCanMoveTableView && _canMoveTableView) {
            // 由不可以滚动变为可以滚动
            [[NSNotificationCenter defaultCenter] postNotificationName:kULGroupMiddleViewGotoTopNotificationName object:nil userInfo:@{kULGroupScrollViewCanScroll:@"1"}];
            _canScroll = NO;
            self.fixOffset = scrollView.contentOffset;
        }
        if(_preCanMoveTableView && !_canMoveTableView){
            // 由可以滚动变为不可以滚动
            if (!_canScroll) {
                scrollView.contentOffset = CGPointMake(0, tabOffsetY);
            }
        }
    }

    // 这里为了 大幅度滚动顺畅 当offset < 3 默认就认为已经到达了顶部
    if (self.canScroll && offsetY < 3) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kULGroupMiddleViewLeaveTopNotificationName object:nil userInfo:@{kULGroupScrollViewCanScroll:@"1"}];
    }
}
```

#### 对于 最顶层

```objc
- (void)ul_scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.canScroll) {
        [scrollView setContentOffset:CGPointZero];
    }
    CGFloat offsetY = scrollView.contentOffset.y;
    // 是否到达了顶部 如果到达通知第二层去滚动
    if (offsetY<0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kULGroupBottomViewLeaveTopNotificationName object:nil userInfo:@{kULGroupScrollViewCanScroll:@"1"}];
    }
}
```

上面就是我们按照前面分析的规则 在视图滚动的时候 所要做的操作！ 

#### 通知及处理

还有最后一步:通知的处理 

我们先看一下代码里涉及到的几个通知

```objc
// 顶部进入置顶通知
static NSString *const kULGroupTopViewGotoTopNotificationName = @"kULGroupTopViewGotoTopNotificationName";
// 中间view到达顶部通知
static NSString *const kULGroupMiddleViewGotoTopNotificationName = @"kULGroupMiddleViewGotoTopNotificationName";
// 中间view离开顶部通知
static NSString *const kULGroupMiddleViewLeaveTopNotificationName = @"kULGroupMiddleViewLeaveTopNotificationName";
// 底部view离开顶部通知
static NSString *const kULGroupBottomViewLeaveTopNotificationName = @"kULGroupBottomViewLeaveTopNotificationName";

```

其实根据通知的名字 我们就基本可以了解到 收到这些通知的时候我们需要做什么


| 通知名 | 何时发送 | 监听者需要做的事 |
| --- | --- | --- |
| kULGroupTopViewGotoTopNotificationName | 最底层滚动到指定位置 | 中间层监听 监听到时需要使自己可以滚动  |
| kULGroupMiddleViewGotoTopNotificationName | 中间层滚动到指定位置 | 最顶部滚动视图 监听 监听到时 让自己可以滚动 |
| kULGroupMiddleViewLeaveTopNotificationName | 中间层从滚动到固定位置的地方离开 |中间层监听 监听到时 中间层不可以滚动; 最底层监听 监听到时 最底层可以滚动|
| kULGroupBottomViewLeaveTopNotificationName| 最顶层滚动到顶部时| 最底层监听监听到后 让自己不可以滚动; 中间层监听 监听到后让自己可以滚动 |

代码我就不具体的贴出来了,可以到项目里更详细的看一下。

### 结果

![](https://ws2.sinaimg.cn/large/006tKfTcly1g0huj318olg30ai0h6tkg.gif)

### 总结

其实这个结构还是挺复杂的不过在仔细分析实现后,我们发现这个效果其实并没有很难实现。只是在实现之前我们需要把 东西缕清楚。这样我们在去动手写代码的时候才可以有的放矢。

希望本文能够帮到你！！！








