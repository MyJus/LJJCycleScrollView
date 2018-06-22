//
//  ViewController.m
//  LJJCycleScrollView
//
//  Created by peony on 2018/6/19.
//  Copyright © 2018年 peony. All rights reserved.
//

#import "ViewController.h"
#import "LJJCycleScrollView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet LJJCycleScrollView *cycleScrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor blackColor];
    self.cycleScrollView.backgroundColor = [UIColor blackColor];
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:@"https://www.baidu.com/img/bd_logo1.png?where=super"];
    [array addObject:[UIImage imageNamed:@"001.jpg"]];
    [array addObject:@"https://img-ads.csdn.net/2018/201805031042507491.png"];
    [array addObject:[UIImage imageNamed:@"002.jpg"]];
    [array addObject:@"https://ss.csdn.net/p?https://mmbiz.qpic.cn/mmbiz_jpg/5TO6hrJreyvWgibfTrAhgSlPBa5WxrVevnbG7FBZJWAYsXk4XafFBn6ficzO9Yx1wfwFcKy1pLiaOAgian4UXebyIg/640?wx_fmt=jpeg"];
    [array addObject:[UIImage imageNamed:@"003.jpg"]];
    [array addObject:@"https://ss.csdn.net/p?https://mmbiz.qpic.cn/mmbiz_png/5TO6hrJreyvWgibfTrAhgSlPBa5WxrVev65AaGY0g6gWIqztVspQEnRCI5icAGGDrZE2qxAlruGTIq6J7fWA86rQ/640?wx_fmt=png"];
    [array addObject:[UIImage imageNamed:@"004.jpg"]];
    [self.cycleScrollView resetScrollViewImages:array];
    
    LJJCycleScrollView *scrollView = [[LJJCycleScrollView alloc] initWithFrame:CGRectMake(0, 318, CGRectGetWidth([UIScreen mainScreen].bounds), 200) cycleDirection:LJJCycleDirectionLandscape pictures:array delegate:nil placeholderImage:nil];
    [self.view addSubview:scrollView];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self.cycleScrollView resetScrollViewPageControlHidden:NO];
    [self.cycleScrollView setCurrentShowIndex:6];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
