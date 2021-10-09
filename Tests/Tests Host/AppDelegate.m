//
//  AppDelegate.m
//  Tests Host
//
//  Created by lifei on 2021/10/9.
//

#import "AppDelegate.h"
#import "TestsHostVC.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    TestsHostVC *mainVC = [[TestsHostVC alloc]init];
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = mainVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
