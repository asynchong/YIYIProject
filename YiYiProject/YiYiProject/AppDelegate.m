//
//  AppDelegate.m
//  YiYiProject
//
//  Created by lichaowei on 14/12/10.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"

#import "UMSocial.h"
#import "MobClick.h"

#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaHandler.h"
//#import "UMSocialTencentWeiboHandler.h"
#import "BMapKit.h"

#import "RCIM.h"

#import "RCIMClient.h"

//融云cloud

//18600912932
//cocos2d

#define RONGCLOUD_IM_APPKEY    @"kj7swf8o7zaf2"
#define RONGCLOUD_IM_APPSECRET @"2cCSWhaLcCm37"

#define UmengAppkey @"5423e48cfd98c58eed00664f"


/**
 *  先用骑叭的做测试
 */
//骑叭
#define SinaAppKey @"2470821654"
#define SinaAppSecret @"bea7d21c9647406a25960a617a8e40a8"
#define QQAPPID @"1103196390" //十六进制:41C170E6; 生成方法:echo 'ibase=10;obase=16;1103196390'|bc
#define QQAPPKEY @"zc8ykXXrvWjKpyuh"

//fbauto （没用）
#define WXAPPID @"wx10280ad0d507a8933b9d"
#define WXAPPSECRET @"SADSDAS"

#define RedirectUrl @"http://sns.whalecloud.com/sina2/callback" //回调地址


//================正式

//umeng后台：mobile@jiruijia.com
//密码:mobile2014
//微博开放平台账号szkyaojiayou@163.com
//密码：mobile2014
//微信开放平台账号：mobile@jiruijia.com
//密码：mobile2014
//腾讯开放平台：2451479286
//密码：mobile2014

//boundlid com.fblife.yijiayi

//新浪

//#define SinaAppKey @"2208620241"
//#define SinaAppSecret @"fe596bc4ac8c92316ad5f255fbc49432"

//#define QQAPPID @"1103196390" //十六进制:41C170E6; 生成方法:echo 'ibase=10;obase=16;1103196390'|bc
//#define QQAPPKEY @"zc8ykXXrvWjKpyuh"

//#define WXAPPID @"wx47f54e431de32846"
//#define WXAPPSECRET @"a71699732e3bef01aefdaf324e2f522c"
//
//#define RedirectUrl @"http://sns.whalecloud.com/sina2/callback" //回调地址

@interface AppDelegate ()<BMKGeneralDelegate,RCIMConnectionStatusDelegate,RCConnectDelegate>
{
    BMKMapManager* _mapManager;
    CLLocationManager *_locationManager;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [RCIM initWithAppKey:RONGCLOUD_IM_APPKEY deviceToken:nil];
    
    //系统登录成功通知 登录融云
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginToRongCloud) name:NOTIFICATION_LOGIN object:nil];
    
    [self rondCloudDefaultLoginWithToken:[LTools cacheForKey:RONGCLOUD_TOKEN]];
    
    if (IOS7_OR_LATER) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
    
#ifdef __IPHONE_8_0
    // 在 iOS 8 下注册苹果推送，申请推送权限。
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert) categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
#else
    // 注册苹果推送，申请推送权限。
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
#endif
    
    //UIApplicationLaunchOptionsRemoteNotificationKey,判断是通过推送消息启动的
    
    NSDictionary *infoDic = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    if (infoDic)
    {
        NSLog(@"infoDic %@",infoDic);
        
    }

    
    [self umengShare];
    
    RootViewController *root = [[RootViewController alloc]init];
    
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=8.0)) {
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager requestAlwaysAuthorization];
        [_locationManager startUpdatingLocation];
    }
    
#pragma mark 百度地图相关
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:@"9PuBXw0V1mKYjsfaZtMVTzF3"  generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
    UINavigationController *unVc = [[UINavigationController alloc]initWithRootViewController:root];
    unVc.navigationBarHidden = YES;
    self.window.rootViewController = unVc;
    self.window.backgroundColor = [UIColor whiteColor];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = [[RCIM sharedRCIM] getTotalUnreadCount];//融云
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/**
 这里处理新浪微博SSO授权之后跳转回来，和微信分享完成之后跳转回来
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    return  [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
}

/**
 这里处理新浪微博SSO授权进入新浪微博客户端后进入后台，再返回原来应用
 */
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [UMSocialSnsService  applicationDidBecomeActive];
}

#pragma mark - 友盟分享

- (void)umengShare
{
    [UMSocialData setAppKey:UmengAppkey];
    
    //使用友盟统计
    [MobClick startWithAppkey:UmengAppkey];
    
    //打开调试log的开关
    [UMSocialData openLog:YES];
    
    //打开新浪微博的SSO开关
    [UMSocialSinaHandler openSSOWithRedirectURL:RedirectUrl];
    
    //设置分享到QQ空间的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:QQAPPID appKey:QQAPPKEY url:@"http://www.umeng.com/social"];
    
    //设置支持没有客户端情况下使用SSO授权
    [UMSocialQQHandler setSupportWebView:YES];
    
    //设置微信AppId，设置分享url，默认使用友盟的网址
    [UMSocialWechatHandler setWXAppId:WXAPPID appSecret:WXAPPSECRET url:@"http://www.umeng.com/social"];
    
//    [UMSocialTencentWeiboHandler openSSOWithRedirectUrl:@"http://sns.whalecloud.com/tencent2/callback"];
    
}


#pragma mark 远程推送

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    // Register to receive notifications.
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    // Handle the actions.
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif

// 获取苹果推送权限成功。

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);
    
    [[RCIM sharedRCIM]setDeviceToken:deviceToken];//融云
    
    NSString *string_pushtoken=[NSString stringWithFormat:@"%@",deviceToken];
    
    while ([string_pushtoken rangeOfString:@"<"].length||[string_pushtoken rangeOfString:@">"].length||[string_pushtoken rangeOfString:@" "].length) {
        string_pushtoken=[string_pushtoken stringByReplacingOccurrencesOfString:@"<" withString:@""];
        string_pushtoken=[string_pushtoken stringByReplacingOccurrencesOfString:@">" withString:@""];
        string_pushtoken=[string_pushtoken stringByReplacingOccurrencesOfString:@" " withString:@""];
        
    }
    
    [LTools cache:string_pushtoken ForKey:USER_DEVICE_TOKEN];
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSString *str = [NSString stringWithFormat: @"Error: %@", error];
    NSLog(@"erro  %@",str);
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"注册失败" message:str delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
//    [alert show];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
}


#pragma mark 事件处理

#pragma - mark - 获取融云token -

- (void)loginToRongCloud
{
    [self loginToRoncloudUserId:[GMAPI getUid] userName:[GMAPI getUsername] userHeadImage:[GMAPI getUerHeadImageUrl]];
}

- (void)loginToRoncloudUserId:(NSString *)userId
                     userName:(NSString *)userName
                userHeadImage:(NSString *)headImage
{
    
    NSString *url = [NSString stringWithFormat:RONCLOUD_GET_TOKEN,userId,userName,headImage];
    LTools *tool = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"result %@",result);
        
        [LTools cache:result[@"token"] ForKey:RONGCLOUD_TOKEN];
        
        [RCIM connectWithToken:result[@"token"] completion:^(NSString *userId) {
            
            NSLog(@"------> rongCloud success %@",userId);
            
//            [LTools showMBProgressWithText:@"聊天登录成功!" addToView:self.window];

            
        } error:^(RCConnectErrorCode status) {
            
            NSString *errInfo = @"融云错误";
            
            if (status == ConnectErrorCode_TOKEN_INCORRECT) {
                
                errInfo = @"融云token无效";
            }
            
            NSLog(@"------> rongCloud fail %@",errInfo);
            
        }];
        
        
    } failBlock:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"获取融云token失败 %@",result);
        
        [LTools showMBProgressWithText:result[RESULT_INFO] addToView:self.window];
        
    }];
}

/**
 *  聊天登录失败
 */
- (void)chatLoginFailInfo:(NSString *)errInfo
{
    UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"" message:errInfo delegate:self cancelButtonTitle:@"取消" otherButtonTitles: @"确定",nil];
    alert.tag = 2001;
    [alert show];
}

- (void)rondCloudDefaultLoginWithToken:(NSString *)loginToken
{
    //测试token
    
//    [LTools cache:@"Z+v61ga3tUUkgHbgG6eFblki5ktT/tK95honsc0yvtV+p7lzHFE9Vop/XwArqiec9DnDrmeC0is=" ForKey:RONGCLOUD_TOKEN];
    
    //默认测试
    
    if (loginToken.length > 0) {
        
        [RCIM connectWithToken:loginToken completion:^(NSString *userId) {
            
            NSLog(@"------> rongCloud success %@",userId);
            
            [LTools cacheBool:YES ForKey:USER_LONGIN];
            
        } error:^(RCConnectErrorCode status) {
           
            NSLog(@"------> rongCloud fail %d",(int)status);
            
            [LTools cacheBool:NO ForKey:USER_LONGIN];
            
        }];
    }
}

/**
 *  监测融云连接状态
 */
-(void)rongCloudConnectionState{
    
    [[RCIM sharedRCIM]setConnectionStatusDelegate:self];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[RCIM sharedRCIM] setConnectionStatusDelegate:nil];
}

-(void)responseConnectionStatus:(RCConnectionStatus)status{
    if (ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT == status) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"" message:@"您已下线，重新连接？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles: @"确定",nil];
            alert.tag = 2000;
            [alert show];
        });
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (2000 == alertView.tag) {
        
        if (0 == buttonIndex) {
            
            NSLog(@"NO");
        }
        
        if (1 == buttonIndex) {
            
            NSLog(@"YES");
            
            [RCIMClient reconnect:self];
        }
    }
    
}

#pragma mark - ReConnectDelegate
/**
 *  回调成功。
 *
 *  @param userId 当前登录的用户 Id，既换取登录 Token 时，App 服务器传递给融云服务器的用户 Id。
 */
- (void)responseConnectSuccess:(NSString*)userId{
    
    NSLog(@"userId %@ rongCloud登录成功",userId);
}

/**
 *  回调出错。
 *
 *  @param errorCode 连接错误代码。
 */
- (void)responseConnectError:(RCConnectErrorCode)errorCode
{
    NSLog(@"rongCloud重新连接失败--- %d",(int)errorCode);
}

@end
