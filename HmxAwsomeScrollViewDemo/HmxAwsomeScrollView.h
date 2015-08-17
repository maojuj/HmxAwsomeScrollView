//
//  HmxAwsomeScrollView.h
//  HmxScrollView
//
//  Created by 黄明星 on 14-8-21.
//  Copyright (c) 2014年 DongPi. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kScreenWidth  ([[UIScreen mainScreen] bounds].size.width)
#define kScreenHeight ([[UIScreen mainScreen] bounds].size.height)

@protocol HmxAwsomeScrollViewDelegate <NSObject>

- (void)clickSomething:(NSInteger)index;

@end

@interface HmxAwsomeScrollView : UIScrollView

@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) UIView *customPageView;
@property (strong, nonatomic) UIColor *customPageViewBackgroundColor;
@property (strong, nonatomic) UIColor *currentPageViewBackgroundColor;
@property (strong, nonatomic) NSArray *contents;
@property (assign, nonatomic) float delay;
@property (assign, nonatomic) id <HmxAwsomeScrollViewDelegate> clickDelegate;

- (id)initWithFrame:(CGRect)frame withScrollDelay:(float)delay;
- (id)initWithFrame:(CGRect)frame withContents:(NSArray*)contents andScrollDelay:(float)delay;
- (void)setCurrentPageViewBackgroundColor:(UIColor *)currentPageViewBackgroundColor;
- (void)setCustomPageViewBackgroundColor:(UIColor *)customPageViewBackgroundColor;
@end
