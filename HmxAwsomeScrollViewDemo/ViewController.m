//
//  ViewController.m
//  HmxAwsomeScrollViewDemo
//
//  Created by ruandao on 15/8/17.
//  Copyright (c) 2015年 hmx. All rights reserved.
//

#import "ViewController.h"
#import "HmxAwsomeScrollView.h"

@interface ViewController ()<HmxAwsomeScrollViewDelegate>
{
    HmxAwsomeScrollView *_scrollView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 创建图片数据源
    NSArray *imgUrls = @[@"http://a2.att.hudong.com/73/16/01300000165476121211162421024.jpg", @"http://pic8.nipic.com/20100808/4953913_162517044879_2.jpg",@"http://pic1.nipic.com/2009-01-13/2009113121422584_2.jpg"];
    // 初始化1
    //_scrollView = [[HmxAwsomeScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 250) withScrollDelay:4.0];
    //_scrollView.clickDelegate = self;
    //[_scrollView setContents:imgUrls];
    
    // 初始化2
    _scrollView = [[HmxAwsomeScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 250) withContents:imgUrls andScrollDelay:4.0];
    _scrollView.clickDelegate = self;
    // 设置自定义page视图的背景色，和当前页颜色
    //_scrollView.customPageViewBackgroundColor = [UIColor greenColor];
    //_scrollView.currentPageViewBackgroundColor = [UIColor blueColor];
    [self.view addSubview:_scrollView];
    // 添加系统默认的pageControl
    [self.view addSubview:_scrollView.pageControl];
    // 添加自定义page视图
    //[self.view addSubview:_scrollView.customPageView];
}

#pragma mark ClickDelegateMethod
- (void)clickSomething:(NSInteger)index
{
    NSLog(@"index = %ld",index);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
