//
//  AppDelegate.m
//  SMRT Board V3
//
//  Created by BOT01 on 17/3/31.
//  Copyright © 2017年 BizOpsTech. All rights reserved.
//
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "BoardDB.h"
#import "PrinterViewController.h"

@interface AppDelegate ()<JPUSHRegisterDelegate>{
    BOOL isOpen;
}
@property (nonatomic, strong) AFHTTPSessionManager *session;
@end

@implementation AppDelegate
-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    //SMRTBoard://CallPhone
    
    
    if ([url.absoluteString hasPrefix:@"smrtkeyboard"]) {
        UINavigationController *rootNav = (UINavigationController*)self.window.rootViewController;
        UIViewController *TagVC;
        if ([url.absoluteString hasSuffix:@"CallPhone"]) {
            TagVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CallPhoneNumberPage"];
            
        }else if([url.absoluteString hasSuffix:@"CreateOrder"]){
            TagVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CreateOrderPage"];
        }else if([url.absoluteString rangeOfString:@"CallPrinter"].length >0){
            TagVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]
                     instantiateViewControllerWithIdentifier:@"PrinterPage"];
            NSRange OrderIdRang = [url.absoluteString rangeOfString:@"="];
            NSInteger OrderId = [[url.absoluteString substringFromIndex:OrderIdRang.location+1]integerValue];
            ((PrinterViewController*)TagVC).OrderId = OrderId;
            
           
            
        }
        [rootNav pushViewController:TagVC animated:YES];
    }
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    
    if ([url.absoluteString hasPrefix:@"smrtkeyboard"]) {
        UINavigationController *rootNav = (UINavigationController*)self.window.rootViewController;
        UIViewController *TagVC;
        if ([url.absoluteString hasSuffix:@"CallPhone"]) {
            
            TagVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CallPhoneNumberPage"];
            
        }else if([url.absoluteString hasSuffix:@"CreateOrder"]){
            
            TagVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CreateOrderPage"];
        }else if([url.absoluteString rangeOfString:@"CallPrinter"].length >0){
            
            TagVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]
                     instantiateViewControllerWithIdentifier:@"PrinterPage"];
            NSRange OrderIdRang = [url.absoluteString rangeOfString:@"="];
            NSInteger OrderId = [[url.absoluteString substringFromIndex:OrderIdRang.location+1]integerValue];
            ((PrinterViewController*)TagVC).OrderId = OrderId;
            
            
            
        }
        [rootNav pushViewController:TagVC animated:YES];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    

    // Override point for customization after application launch.
    NSArray *centralManagerIdentifiers = launchOptions[UIApplicationLaunchOptionsBluetoothCentralsKey];
    NSLog(@"%@",centralManagerIdentifiers);
    
    
    //Required
    //notice: 3.0.0及以后版本注册可以这样写，也可以继续用之前的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    
    // Optional
    // 获取IDFA
    // 如需使用IDFA功能请添加此代码并在初始化方法的advertisingIdentifier参数中填写对应值
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    // Required
    // init Push
    // notice: 2.1.5版本的SDK新增的注册方法，改成可上报IDFA，如果没有使用IDFA直接传nil
    // 如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。
    [JPUSHService setupWithOption:launchOptions appKey:@"ea0e06855bef98583e66ffda"
                          channel:@"App Store"
                 apsForProduction:NO
            advertisingIdentifier:advertisingId];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

#pragma mark- JPUSHRegisterDelegate

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        [self UpdateAddressBookBegin];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        [self UpdateAddressBookBegin];
    }
    completionHandler();  // 系统要求执行这个方法
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    [self UpdateAddressBookBegin];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
    [self UpdateAddressBookBegin];
}

-(void)UpdateAddressBookBegin{
    self.session = [AFHTTPSessionManager manager];
    self.session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"application/x-json",@"text/html", nil];
    
    if (!isOpen) {
        //打开网络监测
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        isOpen = YES;
    } else {
        // 关闭网络监测
        [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
        isOpen = NO;
    }
    
    // 接下来会判断当前是WiFi状态还是3g状态,网络不可用状态
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {        
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"当前网络处于未知状态");
                
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"当前网络处于未链接状态");
                
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:{
                [self UpdateAddressBook];
            }
                break;
            default:
                break;
        }
    }];

}
-(void)UpdateAddressBook{
    NSString *api = @"http://u2898.com/ExcelApp/GetAddress.php";
    [self.session POST:api parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"== 获取成功:%@ ==",responseObject);
        BoardDB *db = [BoardDB new];
        //读取默认发件人
        ContactModel*DefaultSender = [db getDefaultSender];
        
        NSArray*list = [responseObject objectForKey:@"list"];
        for(NSInteger i=0; i< list.count; i++){
            ContactModel*itemAddress = [ContactModel new];
            itemAddress.strName = [list[i] objectForKey:@"user_name"];
            itemAddress.strPhone = [list[i] objectForKey:@"user_phone"];
            itemAddress.strProv = [list[i] objectForKey:@"user_provice"];
            itemAddress.strCity = [list[i] objectForKey:@"user_city"];
            itemAddress.strAddress = [NSString stringWithFormat:@"%@%@",[list[i] objectForKey:@"user_district"],[list[i] objectForKey:@"user_address"]];
            
            //导入到地址薄
            [db UpdateContact:itemAddress];
            
            //如果有默认发件人 -> 导入到运单
            if(DefaultSender){
                MailItemModel*mailItem = [MailItemModel new];
                mailItem.mailDescription = [NSString stringWithFormat:@"%@\n%@ X%@",
                                            [list[i] objectForKey:@"user_account"],
                                            [list[i] objectForKey:@"user_productName"],
                                            [list[i] objectForKey:@"user_buyCount"]
                                            ];
                [db UpdateMailList:mailItem withSender:DefaultSender withReceive:itemAddress];
            }
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"=== 获取失败 ===");
    }];

}
@end
