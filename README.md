

---
title: UITableView的嵌套
date: 2016-08-27 19:27:52
tags: [iOS,Demo,UITableView]
toc: true
categories: UI
photos: 

---

	前端时间公司的某一个模块中，需要用到这么一个效果，一个看似很简单的东西，当时直接用的第三方，现在把简单的东西抽出来，供大家参考。这不是一个第三方的，可以直接使用的库，我只是简单的讲述了我的思想，所以其中有一些东西的依赖比较重。大家只是参考一下就可以了

<!--more-->

#### 0、前言

	


#### 1、效果图
![2016082778727scrollTable.gif](http://7xqmjb.com1.z0.glb.clouddn.com/2016082778727scrollTable.gif)


#### 2、主要思路

1、这个功能的实现主要是多控制器的管理，tableview的cell中嵌套了一个控制器，这个控制器也管理者多个控制器

`这里的多控制器也可以改为多个view，大家可尝试做一些优化`

2、这里为了解耦主要采用的是通知，通知的使用有利有弊，具体使用的时候一定要记得移除监听

具体思路：

 - 1 、外部控制器可滑动，当监听到第三个section的位置的关系判断
     CGFloat tabOffsetY = [_tableView rectForSection:
     						2].origin.y-64;
    CGFloat offsetY = scrollView.contentOffset.y;
    通过判断这两者的关系，判断应该是哪一个tableview可以被拖动
 
   
待续
    