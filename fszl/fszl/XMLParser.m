//
//  XMLParser.m
//  fszl
//
//  Created by huqin on 1/4/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import "XMLParser.h"

@interface XMLParser()

//结果
@property (nonatomic, strong) NSDictionary *jsonResult;

//临时变量、结果
@property (nonatomic, strong) NSString *tmpStr;

@end

@implementation XMLParser

-(id)parseToJson:(id) xml{
    self.tmpStr= @"";
    NSXMLParser *xmlParser = xml;
    xmlParser.delegate = self;
    [xmlParser parse];
    
    return self.jsonResult;
}

-(NSString *)parseToString:(id) xml{
    self.tmpStr= @"";
    NSXMLParser *xmlParser = xml;
    xmlParser.delegate = self;
    [xmlParser parse];
    
    return self.tmpStr;
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    NSData *data = [self.tmpStr dataUsingEncoding: NSUTF8StringEncoding];
    self.jsonResult = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    self.tmpStr = [self.tmpStr stringByAppendingString:string];
}

@end
