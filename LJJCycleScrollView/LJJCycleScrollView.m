//
//  LJJCycleScrollView.m
//  LJJCycleScrollView
//
//  Created by peony on 2018/6/19.
//  Copyright © 2018年 peony. All rights reserved.
//

#import "LJJCycleScrollView.h"

@interface LJJCycleScrollView ()<UIScrollViewDelegate> {
    
    UIScrollView *scrollView;
    UIImageView *curImageView;
    
    int totalPage;
    int curPage;
    CGRect scrollFrame;
    
    LJJCycleDirection scrollDirection;     // scrollView滚动的方向
    NSArray *imagesArray;               // 存放所有需要滚动的图片 UIImage
    NSMutableArray *curImages;          // 存放当前滚动的三张图片
    NSArray *beforeShowImages;          // 之前展示的三张图片
    UIPageControl *pageControl;
}

@property (nonatomic, weak) id<LJJCycleScrollViewDelegate> delegate;
@property (strong,nonatomic) UIImage *placeholderImage;
@property (assign,nonatomic) BOOL pageControlHidden;
@property (strong,nonatomic) NSMutableDictionary *currentRequestImage;


//私有方法
- (int)validPageValue:(NSInteger)value;
- (NSArray *)getDisplayImagesWithCurpage:(int)page;
- (void)refreshScrollView;
- (UIImage *)scaleImage:(UIImage *)image;
- (void)loadImage:(UIImageView *)imageView urlString:(NSString *)urlString;
- (void)handleTap:(UITapGestureRecognizer *)tap;

@end


@implementation LJJCycleScrollView
//MARK: - xib或storyBoard初始化调用的方法
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        totalPage = 0;
        scrollDirection = LJJCycleDirectionLandscape;
        curImages = [[NSMutableArray alloc] init];
        imagesArray = nil;
        self.delegate = nil;
        self.pageControlHidden = NO;
        
        if (scrollView == nil) {
            scrollView = [[UIScrollView alloc] init];
            scrollView.backgroundColor = [UIColor blackColor];
            scrollView.showsHorizontalScrollIndicator = NO;
            scrollView.showsVerticalScrollIndicator = NO;
            scrollView.pagingEnabled = YES;
            scrollView.delegate = self;
            [self addSubview:scrollView];
        }
        if (pageControl == nil) {
            pageControl = [[UIPageControl alloc] init];
            CGSize pageSize = [pageControl sizeForNumberOfPages:totalPage];
//            pageControl.frame = CGRectMake(CGRectGetWidth(frame) / 2 - pageSize.width / 2, CGRectGetHeight(frame) - pageSize.height, pageSize.width, pageSize.height);
            pageControl.numberOfPages = totalPage;
            pageControl.currentPage = curPage - 1;
            [self addSubview:pageControl];
        }
        
    }
    return self;
}
//MARK: - 代码初始化方法
//便利初始化方法
- (id)initWithFrame:(CGRect)frame cycleDirection:(LJJCycleDirection)direction {
    return [self initWithFrame:frame cycleDirection:direction pictures:nil];
}
- (id)initWithFrame:(CGRect)frame cycleDirection:(LJJCycleDirection)direction pictures:(NSArray *)pictureArray {
    return [self initWithFrame:frame cycleDirection:direction pictures:pictureArray delegate:nil placeholderImage:nil];
}
- (id)initWithFrame:(CGRect)frame cycleDirection:(LJJCycleDirection)direction pictures:(NSArray *)pictureArray delegate:(id<LJJCycleScrollViewDelegate>)delegate placeholderImage:(UIImage *)placeholderImage {
    return [self initWithFrame:frame cycleDirection:direction pictures:pictureArray delegate:delegate placeholderImage:placeholderImage pageControlHidden:NO];
}
//指定初始化方法
- (id)initWithFrame:(CGRect)frame cycleDirection:(LJJCycleDirection)direction pictures:(NSArray *)pictureArray delegate:(id<LJJCycleScrollViewDelegate>)delegate placeholderImage:(UIImage *)placeholderImage pageControlHidden:(BOOL)hidden
{
    self = [super initWithFrame:frame];
    if(self)
    {
        scrollFrame = frame;
        scrollDirection = direction;
        totalPage = (int)pictureArray.count;
        self.delegate = delegate;
        self.placeholderImage = placeholderImage;
        self.pageControlHidden = hidden;
        curPage = 1;                                    // 显示的是图片数组里的第一张图片
        curImages = [[NSMutableArray alloc] init];
        imagesArray = [[NSArray alloc] initWithArray:pictureArray];
        
        if (scrollView == nil) {
            scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(scrollFrame), CGRectGetHeight(scrollFrame))];
            scrollView.backgroundColor = [UIColor blackColor];
            scrollView.showsHorizontalScrollIndicator = NO;
            scrollView.showsVerticalScrollIndicator = NO;
            scrollView.pagingEnabled = YES;
            scrollView.delegate = self;
            scrollView.scrollEnabled = totalPage > 1;
            [self addSubview:scrollView];
        }
        
        
        if (pageControl == nil) {
            pageControl = [[UIPageControl alloc] init];
            CGSize pageSize = [pageControl sizeForNumberOfPages:totalPage];
            pageControl.frame = CGRectMake(CGRectGetWidth(frame) / 2 - pageSize.width / 2, CGRectGetHeight(frame) - pageSize.height, pageSize.width, pageSize.height);
            pageControl.numberOfPages = totalPage;
            pageControl.currentPage = curPage - 1;
            pageControl.hidden = (totalPage <= 1 || self.pageControlHidden);
            [self addSubview:pageControl];
        }
        
        // 在水平方向滚动
        if(scrollDirection == LJJCycleDirectionLandscape) {
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * 3,
                                                scrollView.frame.size.height);
        }
        // 在垂直方向滚动
        if(scrollDirection == LJJCycleDirectionPortait) {
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,
                                                scrollView.frame.size.height * 3);
        }
        [self refreshScrollView];
    }
    
    return self;
}
//MARK: - 子视图重新布局（理论上只有Xib和storyboard创建的会调用该方法，当然后来改变frame也会调用）
- (void)layoutSubviews {
    scrollFrame = self.frame;
    
    scrollView.frame = CGRectMake(0, 0, CGRectGetWidth(scrollFrame), CGRectGetHeight(scrollFrame));
    
    CGSize pageSize = [pageControl sizeForNumberOfPages:totalPage];
    pageControl.frame = CGRectMake(CGRectGetWidth(self.frame) / 2 - pageSize.width / 2, CGRectGetHeight(self.frame) - pageSize.height, pageSize.width, pageSize.height);
    for (int i = 0; i < 3; i ++) {
        UIImageView *imageView = [scrollView viewWithTag:1000 + i];
        if (imageView) {
            imageView.frame = CGRectMake(0, 0, CGRectGetWidth(scrollFrame), CGRectGetHeight(scrollFrame));
            if(scrollDirection == LJJCycleDirectionLandscape) {
                imageView.frame = CGRectOffset(imageView.frame, scrollFrame.size.width * i, 0);
            }
            // 垂直滚动
            if(scrollDirection == LJJCycleDirectionPortait) {
                imageView.frame = CGRectOffset(imageView.frame, 0, scrollFrame.size.height * i);
            }
        }
    }
    // 在水平方向滚动
    if(scrollDirection == LJJCycleDirectionLandscape) {
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * 3,
                                            scrollView.frame.size.height);
    }
    // 在垂直方向滚动
    if(scrollDirection == LJJCycleDirectionPortait) {
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,
                                            scrollView.frame.size.height * 3);
    }
    [self resetScrollViewContentOffset];
}



//MARK: - 重置图片数据源、代理、占位图
//重置图片数据源
- (void)resetScrollViewImages:(NSArray *)pictureArray {
    totalPage = (int)pictureArray.count;
    curPage = 1;                                    // 显示的是图片数组里的第一张图片
    curImages = [[NSMutableArray alloc] init];
    imagesArray = [[NSArray alloc] initWithArray:pictureArray];
    
    CGSize pageSize = [pageControl sizeForNumberOfPages:totalPage];
    pageControl.frame = CGRectMake(CGRectGetWidth(self.frame) / 2 - pageSize.width / 2, CGRectGetHeight(self.frame) - pageSize.height, pageSize.width, pageSize.height);
    pageControl.numberOfPages = totalPage;
    pageControl.currentPage = curPage - 1;
    
    [self getDisplayImagesWithCurpage:curPage];
    UIImageView *firstImageView = [scrollView viewWithTag:1000];
    [self loadImage:firstImageView urlString:[curImages objectAtIndex:0] curPage:curPage index:0];
    
    UIImageView *secondImageView = [scrollView viewWithTag:1001];
    [self loadImage:secondImageView urlString:[curImages objectAtIndex:1]  curPage:curPage index:1];
    
    UIImageView *thirdImageView = [scrollView viewWithTag:1002];
    [self loadImage:thirdImageView urlString:[curImages objectAtIndex:2]  curPage:curPage index:2];
    scrollView.scrollEnabled = totalPage > 1;
    pageControl.hidden = (totalPage <= 1 || self.pageControlHidden);
    [self refreshScrollView];
}
//重置代理
- (void)resetScrollViewDelegate:(id<LJJCycleScrollViewDelegate>)delegate {
    self.delegate = delegate;
}
//修改占位图
- (void)resetScrollViewPlaceholderImage:(UIImage *)placeholderImage {
    self.placeholderImage = placeholderImage;
}
//修改pageControl隐藏状态
- (void)resetScrollViewPageControlHidden:(BOOL)hidden {
    self.pageControlHidden = hidden;
    pageControl.hidden = hidden;
    pageControl.currentPage = curPage - 1;
}
//MARK: - 刷新pagecontrol
- (void)refreshPageControl {
    if (!self.pageControlHidden) {
        pageControl.currentPage = curPage - 1;
    }
    
}
//MARK: - 设置当前展示第几个
- (void)setCurrentShowIndex:(NSInteger)index {
    //首先判断是否越界
    if (index >= totalPage || index < 0) {//越界
        NSLog(@"设置的展示下标越界了");
    }else {
        curPage = (int)index + 1;
        [self refreshScrollView];
    }
}

//MARK: - 刷新展示（主要用于滑动后，位置调整及加载新图片，另外重置图片数据源，设置当前展示的下标和初始化也会调用该方法）
- (void)refreshScrollView {
    [self refreshPageControl];
    
    [self getDisplayImagesWithCurpage:curPage];
    if (curImages.count == 0) {
        return;
    }
    @synchronized(self) {
        NSArray *subViews = [scrollView subviews];
        if([subViews count] == 0) {//第一次进入，需要创建
            //        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            for (int i = 0; i < 3; i++) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(scrollFrame), CGRectGetHeight(scrollFrame))];
                imageView.tag = 1000 + i;
                imageView.userInteractionEnabled = YES;
                imageView.backgroundColor = [UIColor whiteColor];
                //[imageView sd_setImageWithURL:[NSURL URLWithString:[curImages objectAtIndex:i]]];
                //imageView.image = [][curImages objectAtIndex:i];
//                if (i == 1) {
                    [self loadImage:imageView urlString:[curImages objectAtIndex:i] curPage:curPage index:i];
//                }
                //图片的显示模式，可以自己设置
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(handleTap:)];
                [imageView addGestureRecognizer:singleTap];
                
                //设置位置
                // 水平滚动
                if(scrollDirection == LJJCycleDirectionLandscape) {
                    imageView.frame = CGRectOffset(imageView.frame, scrollFrame.size.width * i, 0);
                }
                // 垂直滚动
                if(scrollDirection == LJJCycleDirectionPortait) {
                    imageView.frame = CGRectOffset(imageView.frame, 0, scrollFrame.size.height * i);
                }
                
                [scrollView addSubview:imageView];
            }
        }else {//之后的进入，不需要创建，仅需要调整位置和加载View等
            // 水平滚动
            if(scrollDirection == LJJCycleDirectionLandscape) {
                int x = scrollView.contentOffset.x;
                
                UIImageView *firstImageView = [scrollView viewWithTag:1000];
                UIImageView *secondImageView = [scrollView viewWithTag:1001];
                UIImageView *thirdImageView = [scrollView viewWithTag:1002];
                if(x >= (2*scrollFrame.size.width)) {// 往后翻一张
                    firstImageView.image = secondImageView.image;
                    [self reloadImage:firstImageView sourceIndex:0];
                    secondImageView.image = thirdImageView.image;
                    [self reloadImage:secondImageView sourceIndex:1];
                    [self resetScrollViewContentOffset];
                    [self loadImage:thirdImageView urlString:[curImages objectAtIndex:2] curPage:curPage index:2];
                }else if(x <= 0) {// 往前翻一张
                    UIImage *secondImage = secondImageView.image;
                    secondImageView.image = firstImageView.image;
                    [self reloadImage:secondImageView sourceIndex:1];
                    [self resetScrollViewContentOffset];
                    thirdImageView.image = secondImage;
                    [self reloadImage:thirdImageView sourceIndex:2];
                    [self loadImage:firstImageView urlString:[curImages objectAtIndex:0] curPage:curPage index:0];
                }else {//重载
                    [self reloadScrollSubviews];
                }
            }else if(scrollDirection == LJJCycleDirectionPortait) {// 垂直滚动
                int y = scrollView.contentOffset.y;
                UIImageView *firstImageView = [scrollView viewWithTag:1000];
                UIImageView *secondImageView = [scrollView viewWithTag:1001];
                UIImageView *thirdImageView = [scrollView viewWithTag:1002];
                if(y >= 2 * (scrollFrame.size.height)) {// 向上滑动一张
                    firstImageView.image = secondImageView.image;
                    [self reloadImage:firstImageView sourceIndex:0];
                    secondImageView.image = thirdImageView.image;
                    [self reloadImage:secondImageView sourceIndex:1];
                    [self resetScrollViewContentOffset];
                    [self loadImage:thirdImageView urlString:[curImages objectAtIndex:2] curPage:curPage index:2];
                }else if(y <= 0) {// 往下滑动一张
                    UIImage *secondImage = secondImageView.image;
                    secondImageView.image = firstImageView.image;
                    [self reloadImage:secondImageView sourceIndex:1];
                    [self resetScrollViewContentOffset];
                    thirdImageView.image = secondImage;
                    [self reloadImage:thirdImageView sourceIndex:2];
                    [self loadImage:firstImageView urlString:[curImages objectAtIndex:0] curPage:curPage index:0];
                }else {//重载
                    [self reloadScrollSubviews];
                }
            }
        }
        [self resetScrollViewContentOffset];
    }
}
//scrollView滑动后的调整
- (void)reloadImage:(UIImageView *)imageView sourceIndex:(NSInteger)curIndex {
    if (imageView.image == nil || imageView.image == self.placeholderImage) {
        NSLog(@"图片为空，或展示的是占位图");
        [self loadImage:imageView urlString:[curImages objectAtIndex:curIndex] curPage:curPage index:curIndex];
    }else {
        NSLog(@"不需要重新加载");
    }
}

//重载scrollView的所有子view（重置图片数据源，设置当前展示的下标会调用）
- (void)reloadScrollSubviews {
    for (int i = 0; i < 3; i++) {
        UIImageView *imageView = [scrollView viewWithTag:1000 + i];
        [self loadImage:imageView urlString:[curImages objectAtIndex:i] curPage:curPage index:i];
    }
}

//MARK: - 重置scrollView偏移位置
- (void)resetScrollViewContentOffset {
    if (scrollDirection == LJJCycleDirectionLandscape) {
        [scrollView setContentOffset:CGPointMake(scrollFrame.size.width, 0)];
    }
    if (scrollDirection == LJJCycleDirectionPortait) {
        [scrollView setContentOffset:CGPointMake(0, scrollFrame.size.height)];
    }
}
//MARK: - 展示的三张图片的数据源更换逻辑
- (NSArray *)getDisplayImagesWithCurpage:(int)page {
    
    int pre = [self validPageValue:curPage-1];
    int last = [self validPageValue:curPage+1];
    
    if([curImages count] != 0) [curImages removeAllObjects];
    
    if (imagesArray.count > 0) {
        [curImages addObject:[imagesArray objectAtIndex:pre-1]];
        [curImages addObject:[imagesArray objectAtIndex:curPage-1]];
        [curImages addObject:[imagesArray objectAtIndex:last-1]];
    }
    
    return curImages;
}
//MARK: - 获取下标
//获取内部使用的下标，从1开始
- (int)validPageValue:(NSInteger)value {
    
    if(value == 0) value = totalPage;                   // value＝1为第一张，value = 0为前面一张
    if(value == totalPage + 1) value = 1;
    
    return (int)value;
}

//根据当前展示的下标，获取前一个或后一个的实际下标,从0开始
- (NSInteger)indexPageValue:(NSInteger)curPage value:(NSInteger)value {
    NSInteger returnValue = curPage;
    switch (value) {
        case 0:
            returnValue = [self validPageValue:curPage - 1] - 1;
            break;
        case 1:
            returnValue = curPage - 1;
            break;
        case 2:
            returnValue = [self validPageValue:curPage + 1] - 1;
            break;
            
        default:
            NSLog(@"value数值错误");
            break;
    }
    return returnValue;
}

//MARK: - scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    
    int x = aScrollView.contentOffset.x;
    int y = aScrollView.contentOffset.y;
    NSLog(@"did  x=%d  y=%d", x, y);
    
    // 水平滚动
    if(scrollDirection == LJJCycleDirectionLandscape) {
        // 往下翻一张
        if(x >= (2*scrollFrame.size.width)) {
            curPage = [self validPageValue:curPage+1];
            [self refreshScrollView];
        }
        if(x <= 0) {
            curPage = [self validPageValue:curPage-1];
            [self refreshScrollView];
        }
    }
    
    // 垂直滚动
    if(scrollDirection == LJJCycleDirectionPortait) {
        // 往下翻一张
        if(y >= 2 * (scrollFrame.size.height)) {
            curPage = [self validPageValue:curPage+1];
            [self refreshScrollView];
        }
        if(y <= 0) {
            curPage = [self validPageValue:curPage-1];
            [self refreshScrollView];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(cycleScrollViewDelegate:didScrollImageView:)]) {
        [self.delegate cycleScrollViewDelegate:self didScrollImageView:curPage - 1];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView {
    
    int x = aScrollView.contentOffset.x;
    int y = aScrollView.contentOffset.y;
    
    NSLog(@"--end  x=%d  y=%d", x, y);
    
    if (scrollDirection == LJJCycleDirectionLandscape) {
        [scrollView setContentOffset:CGPointMake(scrollFrame.size.width, 0) animated:YES];
    }
    if (scrollDirection == LJJCycleDirectionPortait) {
        [scrollView setContentOffset:CGPointMake(0, scrollFrame.size.height) animated:YES];
    }
}
//MARK: - showImageViewTap事件
- (void)handleTap:(UITapGestureRecognizer *)tap {
    
    if ([self.delegate respondsToSelector:@selector(cycleScrollViewDelegate:didSelectImageView:)]) {
        [self.delegate cycleScrollViewDelegate:self didSelectImageView:curPage - 1];
    }
}

//MARK: - 图片加载的工具方法
- (void)loadImage:(UIImageView *)imageView urlString:(NSString *)urlString curPage:(NSInteger)currentPage index:(NSInteger)index {
    if (imageView == nil) {
        NSLog(@"还没有创建ImageView");
        return;
    }
    if ([self.placeholderImage isKindOfClass:[UIImage class]]) {
        imageView.image = self.placeholderImage;
    }
    //判断是否实现数据加载的代理方法
    if (self.delegate && [self.delegate respondsToSelector:@selector(cycleScrollViewDatasource:showView:source:index:)]) {
        [self.delegate cycleScrollViewDatasource:self showView:imageView source:urlString index:[self indexPageValue:curPage value:index]];
    }else {//没有实现的话，调用默认加载方法
        [self loadImage:imageView urlString:urlString];
    }
}
- (void)loadImage:(UIImageView *)imageView urlString:(NSString *)urlString {
    //还可以使用SD、AF或YYKit进行加载网络图片,现在的方式网路图片没有缓存，当然也可以自己写网络图片的缓存
    NSString *key = [NSString stringWithFormat:@"%ld",imageView.tag];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.currentRequestImage setValue:urlString forKey:key];
        UIImage *showImage = nil;
        if ([urlString isKindOfClass:[NSString class]]) {
            showImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]];
        }else if ([urlString isKindOfClass:[NSURL class]]) {
            showImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:(NSURL *)urlString]];//[curImages objectAtIndex:i];
        }else if ([urlString isKindOfClass:[NSData class]]) {
            showImage = [UIImage imageWithData:(NSData *)urlString];//[curImages objectAtIndex:i];
        }else if ([urlString isKindOfClass:[UIImage class]]) {
            showImage = (UIImage *)urlString;
        }else {
            //不支持的类型
            showImage = nil;
        }
        
        if (showImage != nil) {
            if ([[self.currentRequestImage valueForKey:key] isEqual:urlString]) {
                UIImage *image = [self scaleImage:showImage];
                dispatch_async(dispatch_get_main_queue(), ^{
                    imageView.image = image;
                });
            }else {
                //请求的图片发生了修改
                NSLog(@"请求发生了修改");
            }
        }
    });
}

/*
 使用压缩的原因：当加载相册图片，或加载拍照图片的时候，这时的图片都是原图，因为原图像素比较高，图片质量比较好，图片的体量比较大。但是有没有想过，手机上可能根本不需要这样的高清图片，这是的几张图片可能就能使app被杀掉。那么我们可不可以牺牲图片的清晰度，来使内存占用降低呢。当然可以，经过实际测试，把图片根据手机屏幕等比缩小，然后利用JPEG有损压缩，压缩比例0.5左右，可以百倍千倍的缩小内存占用。当然在手机上看到的图片和原图，在不缩放的情况下没有明显的区别。
 */
//图片压缩,如果宽或者高大于了屏幕宽或高才会进行等比缩小
- (UIImage *)scaleImage:(UIImage *)image {
    //实现等比例缩放
    CGFloat screnWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat screnHeight =CGRectGetHeight([UIScreen mainScreen].bounds);
    
    if (image.size.width > screnWidth || image.size.height > screnHeight) {
        CGFloat hfactor = image.size.width / screnWidth;
        CGFloat vfactor = image.size.height / screnHeight;
        CGFloat factor = fmax(hfactor, vfactor);
        //画布大小
        CGFloat newWith = image.size.width / factor;
        CGFloat newHeigth = image.size.height / factor;
        CGSize newSize = CGSizeMake(newWith, newHeigth);//CGSize(width: newWith, height: newHeigth)
        
        UIGraphicsBeginImageContext(newSize);
        [image drawInRect:CGRectMake(0, 0, newWith, newHeigth)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        //图像压缩
        NSData *newImageData = UIImageJPEGRepresentation(newImage, 0.5);
        return [UIImage imageWithData:newImageData];
    }else {
        return image;
    }
    
    
}
- (NSDictionary *)currentRequestImage{
    if (_currentRequestImage == nil) {
        _currentRequestImage = [NSMutableDictionary dictionary];
    }
    return _currentRequestImage;
}


//MARK: - 当前版本号
+ (NSString *)version {
    return [NSString stringWithFormat:@"0.0.%d",2];
}


@end
