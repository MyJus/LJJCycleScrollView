//
//  LJJCycleScrollView.h
//  LJJCycleScrollView
//
//  Created by peony on 2018/6/19.
//  Copyright © 2018年 peony. All rights reserved.
//
/**
 说明：
    1、该类加载网络图片和缩放图片的时候都没有进行图片缓存，所以如果需要完美的话需要自己去实现，（比如网络图片使用SD、YYKit、AF等。对于缩放的图片，修改源码，在缩放方法里面加入缓存策略，或者在加入数组数据源之前自定义缓存策略即数据源内的数据可直接使用）
    2、该类允许Xib和代码形式两种方式进行初始化
    3、图片的展示方式可以根据需要自己修改
    4、对于图片，默认都经过等比缩放和有损压缩（其实并不影响展示的清晰度），目的是为了减少内存占用。对于图片宽小于屏幕宽 且图片高小于屏幕高的，不进行缩放和压缩
 */

#import <UIKit/UIKit.h>

typedef enum {
    LJJCycleDirectionLandscape = 0,         // 水平滚动
    LJJCycleDirectionPortait,          // 垂直滚动
    
}LJJCycleDirection;

@class LJJCycleScrollView;

@protocol LJJCycleScrollViewDelegate <NSObject>
@optional

/**
 代理回调方法，点击选择
 
 @param cycleScrollView 调用代理的类
 @param index 选择的下标，从1开始。比如数据源数组有三张图片，返回的index数值可能是1、2、3
 */
- (void)cycleScrollViewDelegate:(LJJCycleScrollView *)cycleScrollView didSelectImageView:(int)index;
/**
 代理回调方法，scrollView滚动到第几张图片
 
 @param cycleScrollView 调用代理的类
 @param index 滚动到的下标，从1开始。比如数据源数组有三张图片，返回的index数值可能是1、2、3
 */
- (void)cycleScrollViewDelegate:(LJJCycleScrollView *)cycleScrollView didScrollImageView:(int)index;

@end

@interface LJJCycleScrollView : UIView


/**
 初始化方法
 
 @param frame 展示的位置
 @param direction 滑动方向
 @param pictureArray 图片数据源，（支持URLString、NSURL、ImageData、Image，支持多样混合）
 @param delegate 代理（用于手机循环滚动图片的点击之间）
 @return 返回实例
 */
- (id)initWithFrame:(CGRect)frame cycleDirection:(LJJCycleDirection)direction pictures:(NSArray *)pictureArray delegate:(id<LJJCycleScrollViewDelegate>)delegate;


/**
 重置代理

 @param delegate 回调的代理
 */
- (void)resetScrollViewDelegate:(id<LJJCycleScrollViewDelegate>)delegate;

/**
 重置循环滚动的数据源
 
 @param pictureArray 图片数据源
 */
- (void)resetScrollViewImages:(NSArray *)pictureArray;

@end


