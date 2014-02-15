//
//  ITAppDelegate.h
//  YAPDemo
//
//  Created by Chaitanya Pandit on 15/02/14.
//  Copyright (c) 2014 #include tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ITAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (ITAppDelegate *)sharedInstance;
- (NSURL *)applicationDocumentsDirectory;

@end
