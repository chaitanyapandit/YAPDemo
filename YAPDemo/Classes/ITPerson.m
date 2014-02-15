//
//  ITPerson.m
//  YapBenchmarks
//
//  Created by Chaitanya Pandit on 15/02/14.
//  Copyright (c) 2014 #include tech. All rights reserved.
//

#import "ITPerson.h"
#import "XMLBlockParser.h"

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

- (NSAttributedString *)attributedSnippet
{
    NSAttributedString *retVal = nil;
    if (self.searchSnippet)
    {
        NSString *text = [NSString stringWithFormat:@"<xyzw>%@</xyzw>", self.searchSnippet];
        __block NSMutableAttributedString  *mutAttrStr = [[NSMutableAttributedString alloc] initWithString:@""];
        NSMutableDictionary *baseAttributes = [[NSMutableDictionary alloc] init];
        [baseAttributes setValue:[UIColor darkTextColor] forKey:NSForegroundColorAttributeName];
        [baseAttributes setValue:[UIFont systemFontOfSize:14.0f] forKey:NSFontAttributeName];

                XMLBlockParser *parser = [[XMLBlockParser alloc] initWithData:[text dataUsingEncoding:NSUTF8StringEncoding]];
        __block BOOL  hasAttributes = NO;
        parser.beginElementBlock = ^(NSString* elementName, NSDictionary *attributeDict) {
            if (![elementName isEqualToString:@"xyzw"])
            {
                hasAttributes = YES;
            }
        };
        parser.foundCharactersBlock = ^(NSString* elementName, NSString *value) {
            if (![elementName isEqualToString:@"b"])
            {
                NSMutableAttributedString *attrSubstring = [[NSMutableAttributedString alloc] initWithString:value];
                [attrSubstring setAttributes:baseAttributes range:NSMakeRange(0, value.length)];
                [mutAttrStr appendAttributedString:attrSubstring];
            }
        };
        parser.endElementBlock = ^(NSString *elementName, NSDictionary *attributes, NSString *value){
            if ([elementName isEqualToString:@"b"])
            {
                NSMutableAttributedString *attrSubstring = [[NSMutableAttributedString alloc] initWithString:value];
                NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithDictionary:baseAttributes];
                [attributes setValue:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
                [attributes setValue:[UIColor colorWithRed:0.04f green:0.36f blue:1.0f alpha:1.0f] forKey:NSBackgroundColorAttributeName];
                [attrSubstring setAttributes:attributes range:NSMakeRange(0, value.length)];
                [mutAttrStr appendAttributedString:attrSubstring];
            }
        };
        [parser parse];
        
        retVal = mutAttrStr;
    }
    
    return retVal;
}

@end
