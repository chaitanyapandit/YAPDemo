//
//  ITPerson.m
//  YapBenchmarks
//
//  Created by Chaitanya Pandit on 15/02/14.
//  Copyright (c) 2014 #include tech. All rights reserved.
//

#import "ITPerson.h"

@implementation ITPerson

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        self.about = [aDecoder decodeObjectForKey:@"about"];
        self.alive = [aDecoder decodeObjectForKey:@"alive"];
        self.id = [aDecoder decodeObjectForKey:@"id"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.udid = [aDecoder decodeObjectForKey:@"udid"];

    }
    
    return self;
}

- (void)updateWithInfo:(NSDictionary *)info
{
    [info enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key];
    }];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.about forKey:@"about"];
    [aCoder encodeObject:self.alive forKey:@"alive"];
    [aCoder encodeObject:self.id forKey:@"id"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.udid forKey:@"udid"];
}

- (id)copyWithZone:(NSZone *)zone
{
    ITPerson *newObject = [[[self class] allocWithZone:zone] init];
    if(newObject)
    {
        newObject.about = self.about.copy;
        newObject.alive = self.alive.copy;
        newObject.id = self.id.copy;
        newObject.name = self.name.copy;
        newObject.udid = self.udid.copy;

    }
    
    return newObject;
}

@end
