//
//  STCoreSyncer.h
//  STViewer
//
//  Created by Maxim Grigoriev on 9/30/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STViewerConstants.h"
#import "STResponseParser.h"

@interface STCoreSyncer : NSObject

@property (nonatomic, strong) STResponseParser *responseParser;

- (void)getAccessTokenWithRefreshToken:(NSString *)refreshToken clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret;
- (void)getRolesForAccessToken:(NSString *)accessToken;
- (void)getEntityPropertiesPage:(int)pageNumber;
- (void)getEntityRolesPage:(int)pageNumber;
- (void)getItemListForEntityName:(NSString *)entityName page:(int)pageNumber;
- (void)getPropertiesForItemWithXid:(NSString *)xid andEntityName:(NSString *)entityName;

@end
