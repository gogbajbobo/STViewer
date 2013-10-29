//
//  STResponseParser.m
//  STViewer
//
//  Created by Maxim Grigoriev on 10/10/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STResponseParser.h"
#import "STViewerCore.h"

@interface STResponseParser()

@property (nonatomic, strong) id responseJSON;
@property (nonatomic) BOOL gotName;

@end

@implementation STResponseParser


- (void)parseResponse:(NSData *)responseData {
    
    NSError *error;
    self.responseJSON = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    
    if (![self.responseJSON isKindOfClass:[NSDictionary class]]) {

//        [[(STSession *)self.session logger] saveLogMessageWithText:@"Sync: response is not dictionary" type:@"error"];
        NSLog(@"Response is not a JSON: %@", error);
        
    } else {
        
//        NSLog(@"responseJSON %@", self.responseJSON);
        
        NSString *errorMessage = [self.responseJSON valueForKey:@"error"];
        
        if (errorMessage) {

            NSLog(@"errorMessage %@", errorMessage);
            
            if ([errorMessage isEqualToString:@"Not authorized"]) {
                
                [[STViewerCore sharedViewerCore] accessTokenExpired];
                
            }
            
        } else {

            if ([self.mode isEqualToString:@"getAccessToken"]) {
                
                [self getAccessToken];
                
            } else if ([self.mode isEqualToString:@"getRoles"]) {
                
                [self getRoles];
                
            } else if ([self.mode isEqualToString:@"getEntities"]) {
                
                [self getEntities];
                
            } else if ([self.mode isEqualToString:@"getEntityRoles"]) {
                
                [self getEntityRoles];
                
            } else if ([self.mode isEqualToString:@"getItemList"]) {
                
                [self getItemList];
                
            } else if ([self.mode isEqualToString:@"getPropertiesForItem"]) {
                
                [self getItemList];
                
            }

        }
        
    }

}

- (void)getAccessToken {
    
    NSDictionary *accessTokenDic = [self.responseJSON objectForKey:@"accessToken"];
    NSString *accessToken = [accessTokenDic valueForKey:@"token"];
    
    if (!accessToken) {
        
        NSLog(@"No access token");
        
    } else {

        [STViewerCore sharedViewerCore].accessToken = accessToken;
        NSLog(@"accessToken %@", accessToken);

    }
    
}

- (void)getRoles {
    
    NSDictionary *tokenDic = [self.responseJSON objectForKey:@"token"];
    NSNumber *expireAfter = [tokenDic valueForKey:@"expireAfter"];
//    NSLog(@"expireAfter %@", expireAfter);
    
    if ([expireAfter intValue] < TOKEN_THRESHOLD) {
        
        [[STViewerCore sharedViewerCore] getAccessToken];
        
    } else {

        NSDictionary *rolesDic = [self.responseJSON objectForKey:@"roles"];
//        NSLog(@"rolesDic %@", rolesDic);
        
        NSDictionary *accountDic = [self.responseJSON objectForKey:@"account"];
//        NSLog(@"accountDic %@", accountDic);
        
        [[STViewerCore sharedViewerCore] gotRoles:rolesDic forAccount:accountDic];

    }
    
    
}

- (void)getEntities {
    
    [[STViewerCore sharedViewerCore] gotEntityProperties:self.responseJSON];
    
}

- (void)getEntityRoles {

    [[STViewerCore sharedViewerCore] gotEntityRoles:self.responseJSON];

}

- (void)getItemList {
    
    [[STViewerCore sharedViewerCore] gotItemList:self.responseJSON];

}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"s"]) {
        
        if ([[attributeDict valueForKey:@"name"] isEqualToString:@"name"]) {
            
            self.gotName = YES;
            
        }
        
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {

}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {

    if (self.gotName) {
        
        NSLog(@"string %@", string);
        self.gotName = NO;
        
    }
    
}

@end
