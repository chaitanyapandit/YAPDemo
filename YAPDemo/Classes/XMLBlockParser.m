//
//  XMLBlockParser.m
//
//  Created by Robert Ryan on 5/10/13.
//  Copyright (c) 2013 Robert Ryan. All rights reserved.
//

#import "XMLBlockParser.h"

@interface XMLBlockParser () <NSXMLParserDelegate>

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSMutableArray *elements;
@property (nonatomic, strong) NSMutableString *value;

@end

@implementation XMLBlockParser

- (void)setDelegate:(id<NSXMLParserDelegate>)delegate
{
    NSLog(@"%s: You should not set delegate for this class", __FUNCTION__);
}

- (BOOL)parse
{
    [super setDelegate:self];
    return [super parse];
}

#pragma mark - NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    self.elements = [[NSMutableArray alloc] init];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    // We started another element, store the current value
    NSMutableDictionary *last = [self.elements lastObject];
    if (last && [last isKindOfClass:[NSDictionary class]])
    {
        [last setObject:self.value forKey:@"value"];
    }
    
    self.value = [[NSMutableString alloc] init];
    NSMutableDictionary *elememtInfo = [[NSMutableDictionary alloc] init];
    [elememtInfo setObject:attributeDict forKey:@"attributes"];
    [elememtInfo setObject:elementName forKey:@"name"];
    [self.elements addObject:elememtInfo];
     
    if (self.beginElementBlock)
        self.beginElementBlock(elementName, attributeDict);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    self.foundCharactersBlock([[self.elements lastObject] objectForKey:@"name"], string);
    [self.value appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (self.endElementBlock)
        self.endElementBlock(elementName, [[self.elements lastObject] objectForKey:@"attributes"], self.value);

    [self.elements removeLastObject];
    self.value = [[self.elements lastObject] objectForKey:@"value"]; // because we might still have some value
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    self.elements = nil;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    if (self.errorBlock)
        self.errorBlock(parseError);
}

@end
