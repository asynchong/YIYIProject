//
//  HomeViewController.m
//  YiYiProject
//
//  Created by lichaowei on 14/12/10.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeBuyController.h"
#import "HomeClothController.h"
#import "HomeMatchController.h"

@interface HomeViewController ()
{
    UIView *menu_view;
    
    HomeBuyController   *buy_viewcontroller;
    HomeClothController *cloth_viewcontroller;
    HomeMatchController *match_viewcontroller;
}

@end

@implementation HomeViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (IOS7_OR_LATER) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createMemuView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 创建视图

- (void)createMemuView
{
    
    CGFloat aWidth = (ALL_FRAME_WIDTH - 166)/ 3.f;
    menu_view = [[UIView alloc]initWithFrame:CGRectMake(0, 20, aWidth * 3, 30)];
    menu_view.clipsToBounds = YES;
    menu_view.layer.cornerRadius = 15.f;
    
    self.navigationItem.titleView = menu_view;

    NSArray *titles = @[@"值得买",@"衣+衣",@"搭配师"];
    
    NSArray *selectedImages = @[@"zhidemai_botton_up",@"1+1_botton_up",@"dapeishi_botton_up"];
    NSArray *normalImages = @[@"zhidemai_botton",@"1+1_botton",@"dapeishi_botton"];
    
    for (int i = 0; i < titles.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(aWidth * i + 0.5 * i, 0, aWidth, 30);
        
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor clearColor];
        [btn setHighlighted:NO];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:13]];
        btn.tag = 100 + i;
//        [btn setBackgroundImage:[UIImage imageNamed:normalImages[i]] forState:UIControlStateNormal];
//        [btn setBackgroundImage:[UIImage imageNamed:selectedImages[i]] forState:UIControlStateSelected];
        
//        [btn setBackgroundImage:[UIImage imageNamed:normalImages[i]] forState:UIControlStateNormal];
//        [btn setBackgroundImage:[UIImage imageNamed:selectedImages[i]] forState:UIControlStateSelected];

        
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithHexString:@"d7425c"] forState:UIControlStateSelected];
        
        [menu_view addSubview:btn];
        [btn addTarget:self action:@selector(clickToSwap:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIButton *btn = (UIButton *)[menu_view viewWithTag:100];
    [self clickToSwap:btn];

}

#pragma mark - 事件处理

- (void)clickToSwap:(UIButton *)sender
{
    int tag = (int)sender.tag;
    
    NSLog(@"sender %@",sender);
    
    CGFloat aFrameY = 0;
    switch (tag) {
        case 100:
        {
            if (buy_viewcontroller)
            {
                buy_viewcontroller.view.hidden = NO;
            }
            else
            {
                buy_viewcontroller = [[HomeBuyController alloc]init];
                buy_viewcontroller.view.frame = CGRectMake(0, aFrameY, self.view.frame.size.width, self.view.frame.size.height);
                buy_viewcontroller.rootViewController = self;
                [self.view addSubview:buy_viewcontroller.view];
            }
            
            buy_viewcontroller.view.backgroundColor = [UIColor redColor];
            
            [self controlViewController:buy_viewcontroller];
            
        }
            break;
        case 101:
        {
            if (cloth_viewcontroller)
            {
                cloth_viewcontroller.view.hidden = NO;
            }
            else
            {
                cloth_viewcontroller = [[HomeClothController alloc]init];
                cloth_viewcontroller.view.frame = CGRectMake(0, aFrameY, self.view.frame.size.width, self.view.frame.size.height-35);
                cloth_viewcontroller.rootViewController = self;
                [self.view addSubview:cloth_viewcontroller.view];
            }
            
            [self controlViewController:cloth_viewcontroller];
            
            
        }
            break;
        case 102:
        {
            if (match_viewcontroller)
            {
                match_viewcontroller.view.hidden = NO;
            }
            else
            {
                match_viewcontroller = [[HomeMatchController alloc]init];
                match_viewcontroller.view.frame = CGRectMake(0, aFrameY, self.view.frame.size.width, self.view.frame.size.height  -35);
                match_viewcontroller.rootViewController = self;
                [self.view addSubview:match_viewcontroller.view];
            }
            
            match_viewcontroller.view.backgroundColor = [UIColor purpleColor];
            
            [self controlViewController:match_viewcontroller];
            
        }
            break;
        default:
            NSLog(@"Controller-Error");
            break;
    }
}

- (void)controlViewController:(UIViewController *)vc
{
    buy_viewcontroller.view.hidden = [vc isKindOfClass:[HomeBuyController class]] ? NO : YES;//服务介绍
    cloth_viewcontroller.view.hidden = [vc isKindOfClass:[HomeClothController class]] ? NO : YES;//商家介绍
    match_viewcontroller.view.hidden = [vc isKindOfClass:[HomeMatchController class]] ? NO : YES;//商家服务
    
//    ((UIButton *)[menu_view viewWithTag:100]).selected = [vc isKindOfClass:[HomeBuyController class]] ? NO : YES;//服务介绍;
//    ((UIButton *)[menu_view viewWithTag:101]).selected = [vc isKindOfClass:[HomeClothController class]] ? NO : YES;//服务介绍;
//    ((UIButton *)[menu_view viewWithTag:102]).selected = [vc isKindOfClass:[HomeMatchController class]] ? NO : YES;//服务介绍;
    
    UIColor *normalColor = [UIColor colorWithHexString:@"f07a8e"];
    UIColor *selectColor = [UIColor colorWithHexString:@"d43b55"];
    
    ((UIButton *)[menu_view viewWithTag:100]).backgroundColor = [vc isKindOfClass:[HomeBuyController class]] ? normalColor : selectColor;//服务介绍;
    ((UIButton *)[menu_view viewWithTag:101]).backgroundColor = [vc isKindOfClass:[HomeClothController class]] ? normalColor : selectColor;//服务介绍;
    ((UIButton *)[menu_view viewWithTag:102]).backgroundColor = [vc isKindOfClass:[HomeMatchController class]] ? normalColor : selectColor;//服务介绍;
}

@end
