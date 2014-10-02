//
//  DDAppDelegate.m
//  DDriver
//
//  Created by ZBN on 14-7-31.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import "DDAppDelegate.h"
#import <MMDrawerController.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <BMapKit.h>
#import "DDLeftViewController.h"
#import "DDMainViewController.h"
#import <CoreLocation/CoreLocation.h>


@interface DDAppDelegate ()<BMKLocationServiceDelegate, CLLocationManagerDelegate>{
    BMKMapManager *_mapManager;
    CLLocationManager *_CLManager;
}

@end

@implementation DDAppDelegate

//- (void)removeObserverSelf
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    _CLManager = [[CLLocationManager alloc] init];
    [_CLManager requestAlwaysAuthorization];
    _CLManager = nil;
    
    _mapManager = [[BMKMapManager alloc] init];
    BOOL ret = [_mapManager start:@"vfVrVokhocQlBZEZTksDbPOT" generalDelegate:nil];
    if (!ret) {
        NSLog(@"AppDelegate: manager start failed!");
    } else {
        NSLog(@"AppDelegate: manager started");
//        self.locHandler = [[DDLocHandler alloc] init];
        [[DDLocHandler sharedLocater] updateCurrentLocationAndAddress];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeObserverSelf) name:nil object:[DDLocHandler sharedLocater]];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    UINavigationController *leftNavi = [st instantiateViewControllerWithIdentifier:@"LeftNavi"];
    UINavigationController *centerVC = [st instantiateViewControllerWithIdentifier:@"CenterNavi"];
    MMDrawerController *drawerVC = [[MMDrawerController alloc] initWithCenterViewController:centerVC leftDrawerViewController:leftNavi];
    
    drawerVC.showsShadow = NO;
    [drawerVC setOpenDrawerGestureModeMask:MMOpenDrawerGestureModePanningNavigationBar];
    [drawerVC setCloseDrawerGestureModeMask:MMCloseDrawerGestureModePanningNavigationBar];
    
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"naviBG"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    
    
    self.window.rootViewController = drawerVC;
    [self.window makeKeyAndVisible];
    
    [WXApi registerApp:@"wxb7e2e278d5c68576"];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    self.locHandler = [[DDLocHandler alloc] init];
    if (![DDLocHandler sharedLocater].isActive) {
        [[DDLocHandler sharedLocater] updateCurrentLocationAndAddress];
    }
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeObserverSelf) name:nil object:[DDLocHandler sharedLocater]];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:self];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [WXApi handleOpenURL:url delegate:self];
}

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        
    }
}


@end
