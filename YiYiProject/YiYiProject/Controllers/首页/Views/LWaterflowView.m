//
//  LWaterflowView.m
//  Waterflow
//
//  Created by lichaowei on 14/12/13.
//  Copyright (c) 2014年 yangjw . All rights reserved.
//

#import "LWaterflowView.h"

@implementation LWaterflowView

-(instancetype)initWithFrame:(CGRect)frame
               waterDelegate:(id<WaterFlowDelegate>)waterDelegate
             waterDataSource:(id<TMQuiltViewDataSource>)waterDatasource
{
    self = [super initWithFrame:frame];
    if (self) {
        
        qtmquitView = [[TMQuiltView alloc] initWithFrame:frame];
        qtmquitView.delegate = self;
        qtmquitView.dataSource = waterDatasource ? waterDatasource : self;
        self.waterDelegate = waterDelegate;
        
        [self addSubview:qtmquitView];
                
        [qtmquitView reloadData];
        [self createHeaderView];
        [self performSelector:@selector(testFinishedLoadData) withObject:nil afterDelay:0.0f];
    }
    return self;
}

- (NSMutableArray *)images
{
    if (!_images)
    {
        NSMutableArray *imageNames = [NSMutableArray array];
        for(int i = 0; i < 10; i++) {
            [imageNames addObject:[NSString stringWithFormat:@"%d.jpeg", i % 10 + 1]];
        }
        _images = [NSMutableArray arrayWithArray:imageNames];
    }
    return _images;
}


- (UIImage *)imageAtIndexPath:(NSIndexPath *)indexPath {
    return [UIImage imageNamed:[self.images objectAtIndex:indexPath.row]];
}


//＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
//初始化刷新视图
//＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
#pragma mark
#pragma methods for creating and removing the header view

-(void)createHeaderView{
    if (_refreshHeaderView && [_refreshHeaderView superview]) {
        [_refreshHeaderView removeFromSuperview];
    }
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:
                          CGRectMake(0.0f, 0.0f - self.bounds.size.height,
                                     self.frame.size.width, self.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    
    [qtmquitView addSubview:_refreshHeaderView];
    
    [_refreshHeaderView refreshLastUpdatedDate];
}

-(void)testFinishedLoadData{
    
    [self removeFooterView];
    [self finishReloadingData];
    [self setFooterView];
}

#pragma mark -
#pragma mark method that should be called when the refreshing is finished
- (void)finishReloadingData{
    
    //  model should call this when its done loading
    _reloading = NO;
    
    if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:qtmquitView];
    }
    
    if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:qtmquitView];
        [self setFooterView];
    }
    
    // overide, the actula reloading tableView operation and reseting position operation is done in the subclass
}

-(void)setFooterView{
    //    UIEdgeInsets test = self.aoView.contentInset;
    // if the footerView is nil, then create it, reset the position of the footer
    CGFloat height = MAX(qtmquitView.contentSize.height, qtmquitView.frame.size.height);
    if (_refreshFooterView && [_refreshFooterView superview])
    {
        // reset position
        _refreshFooterView.frame = CGRectMake(0.0f,
                                              height,
                                              qtmquitView.frame.size.width,
                                              self.bounds.size.height);
    }else
    {
        // create the footerView
        _refreshFooterView = [[EGORefreshTableFooterView alloc] initWithFrame:
                              CGRectMake(0.0f, height,
                                         qtmquitView.frame.size.width, self.bounds.size.height)];
        _refreshFooterView.delegate = self;
        [qtmquitView addSubview:_refreshFooterView];
    }
    
    if (_refreshFooterView)
    {
        [_refreshFooterView refreshLastUpdatedDate];
    }
}


-(void)removeFooterView
{
    if (_refreshFooterView && [_refreshFooterView superview])
    {
        [_refreshFooterView removeFromSuperview];
    }
    _refreshFooterView = nil;
}

//===============
//刷新delegate
#pragma mark -
#pragma mark data reloading methods that must be overide by the subclass

-(void)beginToReloadData:(EGORefreshPos)aRefreshPos{
    
    //  should be calling your tableviews data source model to reload
    _reloading = YES;
    
    if (aRefreshPos == EGORefreshHeader)
    {
        
        self.pageNum = 1;
        // pull down to refresh data
        [self performSelector:@selector(refreshView) withObject:nil afterDelay:2.0];
        
    }else if(aRefreshPos == EGORefreshFooter)
    {
        self.pageNum ++;
        
        // pull up to load more data
        [self performSelector:@selector(getNextPageView) withObject:nil afterDelay:2.0];
    }
    
    // overide, the actual loading data operation is done in the subclass
}

//刷新调用的方法
-(void)refreshView
{
    if (_waterDelegate && [_waterDelegate respondsToSelector:@selector(loadNewData)]) {
        [_waterDelegate loadNewData];
    }
    
    NSLog(@"刷新完成");
    [self testFinishedLoadData];
    
}
//加载调用的方法
-(void)getNextPageView
{
    if (_waterDelegate && [_waterDelegate respondsToSelector:@selector(loadMoreData)]) {
        [_waterDelegate loadMoreData];
        
        
        return;
    }
    
    for(int i = 0; i < 10; i++) {
        [_images addObject:[NSString stringWithFormat:@"%d.jpeg", i % 10 + 1]];
    }
    [qtmquitView reloadData];
    
    [self testFinishedLoadData];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_refreshHeaderView)
    {
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
    
    if (_refreshFooterView)
    {
        [_refreshFooterView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (_refreshHeaderView)
    {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
    
    if (_refreshFooterView)
    {
        [_refreshFooterView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}


#pragma mark -
#pragma mark EGORefreshTableDelegate Methods

- (void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos
{
    
    [self beginToReloadData:aRefreshPos];
    
}

- (BOOL)egoRefreshTableDataSourceIsLoading:(UIView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}


// if we don't realize this method, it won't display the refresh timestamp
- (NSDate*)egoRefreshTableDataSourceLastUpdated:(UIView*)view
{
    
    return [NSDate date]; // should return date data source was last changed
    
}

- (void)didReceiveMemoryWarning
{
    // Dispose of any resources that can be recreated.
}

#pragma mark - TMQuiltViewDataSource

- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView {
    return [self.images count];
}

- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath {
    TMPhotoQuiltViewCell *cell = (TMPhotoQuiltViewCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"PhotoCell"];
    if (!cell) {
        cell = [[TMPhotoQuiltViewCell alloc] initWithReuseIdentifier:@"PhotoCell"];
    }
    
    cell.photoView.image = [self imageAtIndexPath:indexPath];
    cell.titleLabel.text = [NSString stringWithFormat:@"%d", (int)indexPath.row];
    return cell;
}

#pragma mark - TMQuiltViewDelegate

//列数

- (NSInteger)quiltViewNumberOfColumns:(TMQuiltView *)quiltView {
    
    if (_waterDelegate && [_waterDelegate respondsToSelector:@selector(waterViewNumberOfColumns)]) {
        
        return [_waterDelegate waterViewNumberOfColumns];
    }
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft
        || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)
    {
        return 3;
    } else {
        return 2;
    }
}

- (CGFloat)quiltView:(TMQuiltView *)quiltView heightForCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (_waterDelegate && [_waterDelegate respondsToSelector:@selector(heightForCellAtIndexPath:)]) {
        
        return [_waterDelegate heightForCellIndexPath:indexPath];
    }
    
    return [self imageAtIndexPath:indexPath].size.height / [self quiltViewNumberOfColumns:quiltView];
}

- (void)quiltView:(TMQuiltView *)quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"index:%d",(int)indexPath.row);
    
    if (_waterDelegate && [_waterDelegate respondsToSelector:@selector(didSelectRowAtIndexPath:)]) {
        
        [_waterDelegate didSelectRowAtIndexPath:indexPath];
    }
}


@end
