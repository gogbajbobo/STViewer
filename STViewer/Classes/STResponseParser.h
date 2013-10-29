//
//  STResponseParser.h
//  STViewer
//
//  Created by Maxim Grigoriev on 10/10/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STResponseParser : NSObject <NSXMLParserDelegate>

@property (nonatomic, strong) NSString *mode;
@property (nonatomic, strong) NSString *entityName;

-(void)parseResponse:(NSData *)responseData;

@end
