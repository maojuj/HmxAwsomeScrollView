//
//  HmxAwsomeScrollView.m
//  HmxScrollView
//
//  Created by 黄明星 on 14-8-21.
//  Copyright (c) 2014年 DongPi. All rights reserved.
//

#import "HmxAwsomeScrollView.h"
#import "UIImageView+WebCache.h"

@interface HmxAwsomeScrollView ()<UIScrollViewDelegate>

@end

@implementation HmxAwsomeScrollView
{
    CGRect _contentRect;
    
    NSUInteger _originalImageCount;
    NSInteger _imageCount;
    NSInteger _currentXoffset;
    //定时器，控制自动滚动广告
    NSTimer *_timer;
    BOOL _manual;
    NSMutableArray *_mImageArray;
    UIView *_currentPageView;
    
    CGFloat _currentPageViewWidth;
}

- (id)initWithFrame:(CGRect)frame withScrollDelay:(float)delay
{
    self = [super initWithFrame:frame];
    if (self) {
        _contentRect = frame;
        _currentXoffset = -1;
        _delay = delay;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.pagingEnabled = YES;
        self.delegate = self;
        _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, _contentRect.origin.y+_contentRect.size.height-30, _contentRect.size.width, 30)];
        _pageControl.hidesForSinglePage = YES;
        
        _customPageViewBackgroundColor = [UIColor yellowColor];
        _currentPageViewBackgroundColor = [UIColor redColor];
        _customPageView = [[UIView alloc]initWithFrame:CGRectMake(0, _contentRect.origin.y+_contentRect.size.height, kScreenWidth, 2)];
        _customPageView.backgroundColor = _customPageViewBackgroundColor;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
       withContents:(NSArray*)contents
     andScrollDelay:(float)delay
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _contentRect = frame;
        _currentXoffset = -1;
        _delay = delay;
        _mImageArray = [[NSMutableArray alloc]initWithArray:contents];
        self.pagingEnabled = YES;
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, _contentRect.origin.y+_contentRect.size.height-30, _contentRect.size.width, 30)];
        _pageControl.numberOfPages = _mImageArray.count;
        _pageControl.hidesForSinglePage = YES;
        
        _customPageViewBackgroundColor = [UIColor yellowColor];
        _currentPageViewBackgroundColor = [UIColor redColor];
        _customPageView = [[UIView alloc]initWithFrame:CGRectMake(0, _contentRect.origin.y+_contentRect.size.height, kScreenWidth, 2)];
        _customPageView.backgroundColor = [UIColor whiteColor];
        _customPageView.backgroundColor = _customPageViewBackgroundColor;
        _currentPageViewWidth = kScreenWidth/(CGFloat)_mImageArray.count;
        
        [self initContents];
    }
    return self;
}

- (void)setCustomPageViewBackgroundColor:(UIColor *)customPageViewBackgroundColor
{
    _customPageViewBackgroundColor = customPageViewBackgroundColor;
    _customPageView.backgroundColor = _customPageViewBackgroundColor;
}

- (void)setCurrentPageViewBackgroundColor:(UIColor *)currentPageViewBackgroundColor
{
    _currentPageViewBackgroundColor = currentPageViewBackgroundColor;
    _currentPageView.backgroundColor = _currentPageViewBackgroundColor;
}

- (void)setContents:(NSArray *)contents
{
    _mImageArray = [[NSMutableArray alloc]initWithArray:contents];
    _currentPageViewWidth = kScreenWidth/(CGFloat)_mImageArray.count;
    [self initContents];
}

- (void)initContents
{
    if (!_currentPageView) {
        _currentPageView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _currentPageViewWidth, 2)];
        _currentPageView.backgroundColor = _currentPageViewBackgroundColor;
        [_customPageView addSubview:_currentPageView];
    }
    
    //[_timer invalidate];
    //_timer = nil;
    
    _pageControl.numberOfPages = _mImageArray.count;
    if (_mImageArray.count > 1)
    {
        _originalImageCount = _mImageArray.count;
        //这里在最开始和最后多加一张图片，做循环滚动
        NSString *firstImageName = [NSString stringWithString:[_mImageArray lastObject]];
        NSString *lastImageName = [NSString stringWithString:[_mImageArray firstObject]];
        [_mImageArray insertObject:firstImageName atIndex:0];
        [_mImageArray insertObject:lastImageName atIndex:_mImageArray.count];
    }
    //NSLog(@"array: %@",_mImageArray);
    
    NSArray *subViews = [self subviews];
    for (int i = 0; i < subViews.count; i++) {
        @autoreleasepool {
            UIView *view = subViews[i];
            if (view.tag >= 100) {
                [view removeFromSuperview];
                view = nil;
            }
        }
    }
    
    _imageCount = _mImageArray.count;
    for (int i = 0; i < _imageCount; i++) {
        @autoreleasepool {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(_contentRect.size.width*i, 0, _contentRect.size.width, _contentRect.size.height)];
            imageView.tag = i+100;
            imageView.userInteractionEnabled = YES;
            [imageView sd_setImageWithURL:[NSURL URLWithString:_mImageArray[i]] placeholderImage:nil];
            [self addSubview:imageView];
            UIControl *ct = [[UIControl alloc]initWithFrame:imageView.bounds];
            ct.tag = 150;
            if (_imageCount > 1)
            {
                ct.tag = i-1;
                //第一张和最后一张是一样的
                if (ct.tag == -1)
                {
                    ct.tag += _originalImageCount;
                }
                else if (ct.tag == _imageCount-2)
                {
                    ct.tag -= _originalImageCount;
                }
            }
            else
            {
                ct.tag = i;
            }
            [ct addTarget:self
                action:@selector(clickAd:)
                forControlEvents:UIControlEventTouchUpInside];
            [imageView addSubview:ct];
        }
    }
    self.contentSize = CGSizeMake(_contentRect.size.width*_mImageArray.count, _contentRect.size.height);
    
    if (_mImageArray.count > 1 && _delay > 0) {
        //设置好滚动视图，启动定时器
        if (!_timer) {
            self.contentOffset = CGPointMake(_contentRect.size.width, 0);
            //_pageControl.currentPage = 0;
            //_currentPageView.frame = CGRectMake(0, 0, _currentPageViewWidth, 2);
            _timer = [self createTimer];
            [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        }
    }
}

- (void)clickAd:(UIControl*)ct
{
    [_clickDelegate clickSomething:ct.tag];
}

- (NSTimer*)createTimer
{
    return [NSTimer scheduledTimerWithTimeInterval:_delay
                                            target:self
                                          selector:@selector(autoScrollAd)
                                          userInfo:nil
                                           repeats:YES];
}

- (void)autoScrollAd
{
    int page = 0;
    int x = self.contentOffset.x/_contentRect.size.width;
    page = x;
    //NSLog(@"x = %d",x);
    if (x == _imageCount-1)
    {
        self.contentOffset = CGPointMake(_contentRect.size.width, 0);
        x = 1;
        //_currentXoffset = 1;
        page = x;
    }
    if (x == _imageCount - 2) {
        page = 0;
    }
    [UIView animateWithDuration:0.5 animations:^{
        self.contentOffset = CGPointMake((x+1)*_contentRect.size.width, 0);
        //NSLog(@"自动滚动偏移量：%d",x);
    } completion:^(BOOL finished) {
        _pageControl.currentPage = page;
        _currentPageView.frame = CGRectMake(page*_currentPageViewWidth, 0, _currentPageViewWidth, 2);
    }];
}

#pragma mark scrollView代理方法
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger offX = scrollView.contentOffset.x/_contentRect.size.width;
    //DDLogInfo(@"手动滑动 x = %d",offX);
    NSInteger page = offX-1;
    if (offX == _currentXoffset) {
        return;
    }
    if (offX == 0)
    {
        //滑动到第一张
        scrollView.contentOffset = CGPointMake(_originalImageCount*_contentRect.size.width, 0);
        _currentXoffset = _originalImageCount;
        page = _originalImageCount-1;
    }
    else if (offX == _imageCount-1)
    {
        //滑动到最后一张
        scrollView.contentOffset = CGPointMake(_contentRect.size.width, 0);
        _currentXoffset = 1;
        page = 0;
    }
    else
    {
        _currentXoffset = offX;
    }
    _pageControl.currentPage = page;
    _currentPageView.frame = CGRectMake(page*_currentPageViewWidth, 0, _currentPageViewWidth, 2);
    if (_manual && _delay > 0)
    {
        //DDLogDebug(@"手动滑动");
        _timer = [self createTimer];
        _manual = NO;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //如果手动滑动，先取消定时器
    _manual = YES;
    if (_timer != nil)
    {
        [_timer invalidate];
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
