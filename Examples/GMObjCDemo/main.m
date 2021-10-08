//
//  main.m
//  GMObjCDemo
//
//  Created by lifei on 2021/10/8.
//

#import <UIKit/UIKit.h>
#import "GMAppDelegate.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([GMAppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
