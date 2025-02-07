//
//  GCycleScrollView.h
//  YiYiProject
//
//  Created by gaomeng on 14/12/21.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol GCycleScrollViewDelegate;
@protocol GCycleScrollViewDatasource;

@interface GCycleScrollView : UIView<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
    
//    id<XLCycleScrollViewDelegate> _delegate;
//    id<XLCycleScrollViewDatasource> _datasource;
    
    NSInteger _totalPages;
    NSInteger _curPage;
    
    NSMutableArray *_curViews;
}

@property (nonatomic,readonly) UIScrollView *scrollView;
@property (nonatomic,readonly) UIPageControl *pageControl;
@property (nonatomic,assign) NSInteger currentPage;
@property (nonatomic,assign,setter = setDataource:) id<GCycleScrollViewDatasource> datasource;
@property (nonatomic,assign,setter = setDelegate:) id<GCycleScrollViewDelegate> delegate;

- (void)reloadData;
- (void)setViewContent:(UIView *)view atIndex:(NSInteger)index;
@end

@protocol GCycleScrollViewDelegate <NSObject>
@optional
- (void)didClickPage:(GCycleScrollView *)csView atIndex:(NSInteger)index;
@end


@protocol GCycleScrollViewDatasource <NSObject>
@required
- (NSInteger)numberOfPages;
- (UIView *)pageAtIndex:(NSInteger)index;

@end