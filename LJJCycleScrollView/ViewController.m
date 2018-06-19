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
    [array addObject:@"https://www.baidu.com/img/bd_logo1.png?where=super"];
    [array addObject:[UIImage imageNamed:@"002.jpg"]];
    [array addObject:@"https://www.baidu.com/img/bd_logo1.png?where=super"];
    [array addObject:[UIImage imageNamed:@"003.jpg"]];
    [array addObject:@"https://www.baidu.com/img/bd_logo1.png?where=super"];
    [array addObject:[UIImage imageNamed:@"004.jpg"]];
    [self.cycleScrollView resetScrollViewImages:array];
    
    LJJCycleScrollView *scrollView = [[LJJCycleScrollView alloc] initWithFrame:CGRectMake(0, 318, CGRectGetWidth([UIScreen mainScreen].bounds), 200) cycleDirection:LJJCycleDirectionLandscape pictures:array delegate:nil];
    [self.view addSubview:scrollView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
