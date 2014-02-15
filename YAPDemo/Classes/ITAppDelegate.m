//
//  ITAppDelegate.m
//  YAPDemo
//
//  Created by Chaitanya Pandit on 15/02/14.
//  Copyright (c) 2014 #include tech. All rights reserved.
//

#import "ITAppDelegate.h"

@implementation ITAppDelegate

+ (ITAppDelegate *)sharedInstance;
{
    return (ITAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
