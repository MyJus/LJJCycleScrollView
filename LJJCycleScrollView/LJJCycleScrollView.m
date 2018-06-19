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


//私有方法
- (int)validPageValue:(NSInteger)value;
- (NSArray *)getDisplayImagesWithCurpage:(int)page;
- (void)refreshScrollView;
- (UIImage *)scaleImage:(UIImage *)image;
- (void)loadImage:(UIImageView *)imageView urlString:(NSString *)urlString;
- (void)handleTap:(UITapGestureRecognizer *)tap;

@end


@implementation LJJCycleScrollView
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        totalPage = 0;
        scrollDirection = LJJCycleDirectionLandscape;
        curImages = [[NSMutableArray alloc] init];
        imagesArray = nil;
        self.delegate = nil;
        
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
- (void)layoutSubviews {
    scrollFrame = self.frame;
    
    scrollView.frame = CGRectMake(0, 0, CGRectGetWidth(scrollFrame), CGRectGetHeight(scrollFrame));
    
    CGSize pageSize = [pageControl sizeForNumberOfPages:totalPage];
    pageControl.frame = CGRectMake(CGRectGetWidth(self.frame) / 2 - pageSize.width / 2, CGRectGetHeight(self.frame) - pageSize.height, pageSize.width, pageSize.height);
    for (int i = 0; i < 3; i ++) {
        UIImageView *imageView = [scrollView viewWithTag:1000 + i];
        imageView.frame = CGRectMake(0, 0, CGRectGetWidth(scrollFrame), CGRectGetHeight(scrollFrame));
        if(scrollDirection == LJJCycleDirectionLandscape) {
            imageView.frame = CGRectOffset(imageView.frame, scrollFrame.size.width * i, 0);
        }
        // 垂直滚动
        if(scrollDirection == LJJCycleDirectionPortait) {
            imageView.frame = CGRectOffset(imageView.frame, 0, scrollFrame.size.height * i);
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
//MARK: - 初始化
- (id)initWithFrame:(CGRect)frame cycleDirection:(LJJCycleDirection)direction pictures:(NSArray *)pictureArray delegate:(id<LJJCycleScrollViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if(self)
    {
        scrollFrame = frame;
        scrollDirection = direction;
        totalPage = (int)pictureArray.count;
        self.delegate = delegate;
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
            [self addSubview:scrollView];
        }
        
        
        if (pageControl == nil) {
            pageControl = [[UIPageControl alloc] init];
            CGSize pageSize = [pageControl sizeForNumberOfPages:totalPage];
            pageControl.frame = CGRectMake(CGRectGetWidth(frame) / 2 - pageSize.width / 2, CGRectGetHeight(frame) - pageSize.height, pageSize.width, pageSize.height);
            pageControl.numberOfPages = totalPage;
            pageControl.currentPage = curPage - 1;
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
//重置代理
- (void)resetScrollViewDelegate:(id<LJJCycleScrollViewDelegate>)delegate {
    self.delegate = delegate;
}
//MARK: - 修改数据源
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
    [self loadImage:firstImageView urlString:[curImages objectAtIndex:0]];
    
    UIImageView *secondImageView = [scrollView viewWithTag:1001];
    [self loadImage:secondImageView urlString:[curImages objectAtIndex:1]];
    
    UIImageView *thirdImageView = [scrollView viewWithTag:1002];
    [self loadImage:thirdImageView urlString:[curImages objectAtIndex:2]];
    
    [self refreshScrollView];
}
//MARK: - 刷新pagecontrol
- (void)refreshPageControl {
    pageControl.currentPage = curPage - 1;
}

//MARK: - 刷新展示（主要用于滑动后，位置调整及加载新图片）
- (void)refreshScrollView {
    [self refreshPageControl];
    scrollView.scrollEnabled = imagesArray.count > 1;
    pageControl.hidden = imagesArray.count == 1;
    
    [self getDisplayImagesWithCurpage:curPage];
    if (curImages.count == 0) {
        return;
    }
    @synchronized(self) {
        NSArray *subViews = [scrollView subviews];
        if([subViews count] == 0) {
            //        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            for (int i = 0; i < 3; i++) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(scrollFrame), CGRectGetHeight(scrollFrame))];
                imageView.tag = 1000 + i;
                imageView.userInteractionEnabled = YES;
                imageView.backgroundColor = [UIColor whiteColor];
                //[imageView sd_setImageWithURL:[NSURL URLWithString:[curImages objectAtIndex:i]]];
                //imageView.image = [][curImages objectAtIndex:i];
//                if (i == 1) {
                    [self loadImage:imageView urlString:[curImages objectAtIndex:i]];
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
        }else {
            // 水平滚动
            if(scrollDirection == LJJCycleDirectionLandscape) {
                int x = scrollView.contentOffset.x;
                // 往下翻一张
                UIImageView *firstImageView = [scrollView viewWithTag:1000];
                UIImageView *secondImageView = [scrollView viewWithTag:1001];
                UIImageView *thirdImageView = [scrollView viewWithTag:1002];
                if(x >= (2*scrollFrame.size.width)) {
                    firstImageView.image = secondImageView.image;
                    if (firstImageView.image == nil) {
                        [self loadImage:firstImageView urlString:[curImages objectAtIndex:0]];
                    }
                    secondImageView.image = thirdImageView.image;
                    if (secondImageView.image == nil) {
                        [self loadImage:secondImageView urlString:[curImages objectAtIndex:1]];
                    }
                    [self resetScrollViewContentOffset];
                    [self loadImage:thirdImageView urlString:[curImages objectAtIndex:2]];
                }
                if(x <= 0) {
                    UIImage *secondImage = secondImageView.image;
                    secondImageView.image = firstImageView.image;
                    if (secondImageView.image == nil) {
                        [self loadImage:secondImageView urlString:[curImages objectAtIndex:1]];
                    }
                    [self resetScrollViewContentOffset];
                    thirdImageView.image = secondImage;
                    if (thirdImageView.image == nil) {
                        [self loadImage:thirdImageView urlString:[curImages objectAtIndex:2]];
                    }
                    [self loadImage:firstImageView urlString:[curImages objectAtIndex:0]];
                }
            }
            
            // 垂直滚动
            if(scrollDirection == LJJCycleDirectionPortait) {
                int y = scrollView.contentOffset.y;
                // 往下翻一张
                UIImageView *firstImageView = [scrollView viewWithTag:1000];
                UIImageView *secondImageView = [scrollView viewWithTag:1001];
                UIImageView *thirdImageView = [scrollView viewWithTag:1002];
                if(y >= 2 * (scrollFrame.size.height)) {
                    firstImageView.image = secondImageView.image;
                    if (firstImageView.image == nil) {
                        [self loadImage:firstImageView urlString:[curImages objectAtIndex:0]];
                    }
                    secondImageView.image = thirdImageView.image;
                    if (secondImageView.image == nil) {
                        [self loadImage:secondImageView urlString:[curImages objectAtIndex:1]];
                    }
                    [self resetScrollViewContentOffset];
                    [self loadImage:thirdImageView urlString:[curImages objectAtIndex:2]];
                }
                if(y <= 0) {
                    UIImage *secondImage = secondImageView.image;
                    secondImageView.image = firstImageView.image;
                    if (secondImageView.image == nil) {
                        [self loadImage:secondImageView urlString:[curImages objectAtIndex:1]];
                    }
                    [self resetScrollViewContentOffset];
                    thirdImageView.image = secondImage;
                    if (thirdImageView.image == nil) {
                        [self loadImage:thirdImageView urlString:[curImages objectAtIndex:2]];
                    }
                    [self loadImage:firstImageView urlString:[curImages objectAtIndex:0]];
                }
            }
        }
        
        [self resetScrollViewContentOffset];
    }
    
    
}
//MARK: - 重置scrollView便宜位置
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

- (int)validPageValue:(NSInteger)value {
    
    if(value == 0) value = totalPage;                   // value＝1为第一张，value = 0为前面一张
    if(value == totalPage + 1) value = 1;
    
    return (int)value;
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
        [self.delegate cycleScrollViewDelegate:self didScrollImageView:curPage];
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
        [self.delegate cycleScrollViewDelegate:self didSelectImageView:curPage];
    }
}
//MARK: - 图片加载的工具方法
- (void)loadImage:(UIImageView *)imageView urlString:(NSString *)urlString {
    //还可以使用SD、AF或YYKit进行加载网络图片,现在的方式网路图片没有缓存，当然也可以自己写网络图片的缓存
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
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
            UIImage *image = [self scaleImage:showImage];
            //这里还可以增加图片的解压缩
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.image = image;
            });
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

@end
