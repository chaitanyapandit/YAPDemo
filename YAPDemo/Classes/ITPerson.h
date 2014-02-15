//
//  ITPerson.h
//  YapBenchmarks
//
//  Created by Chaitanya Pandit on 15/02/14.
//  Copyright (c) 2014 #include tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ITPerson : NSObject

@property (nonatomic, retain) NSString * about;
@property (nonatomic, retain) NSNumber * alive;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * udid;

@property (nonatomic, retain) NSString * searchSnippet;

- (void)updateWithInfo:(NSDictionary *)info;
- (NSAttributedString *)attributedSnippet;

@end
