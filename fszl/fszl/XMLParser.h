//
//  XMLParser.h
//  fszl
//
//  Created by huqin on 1/4/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import <Foundation/Foundation.h>

//该类提供XML去封装方法
@interface XMLParser : NSObject <NSXMLParserDelegate>

//将xml去封装，获取json
-(id)parseToJson:(id) xml;

//将xml去封装，获取string
-(NSString *)parseToString:(id) xml;

@end
