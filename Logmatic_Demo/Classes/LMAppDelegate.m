//
//  LMAppDelegate.m
//  Logmatic_Demo
//
//  Created by Roland Borgese on 04/01/2016.
//  Copyright © 2016 Applidium. All rights reserved.
//

#import "LMAppDelegate.h"
#import <Logmatic/LMLogger.h>

static NSString * const kLogmaticKey = <#key#>; //TODO: set your personal key here

@implementation LMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    LMLogger * logger = [LMLogger sharedLogger];
    [logger setKey:kLogmaticKey];
    [logger setUserAgentTracking:@"uat"];
    [logger setIPTracking:@"ipt"];
    [logger startLogger];
    logger.logLevel = LMLogLevelShort;
    return YES;
}

@end
