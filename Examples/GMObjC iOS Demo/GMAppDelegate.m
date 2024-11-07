//
//  AppDelegate.m
//  GMObjC
//
//  Created by lifei on 2021/9/27.
//

#import "GMAppDelegate.h"
#import "GMViewController.h"

@interface GMAppDelegate ()

@end

@implementation GMAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    GMViewController *mainVC = [[GMViewController alloc]init];
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = mainVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
