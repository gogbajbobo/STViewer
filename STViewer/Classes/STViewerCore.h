//
//  STViewerCore.h
//  STViewer
//
//  Created by Maxim Grigoriev on 9/30/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STCoreSyncer.h"
#import <STManagedTracker/STSessionManager.h>

@interface STViewerCore : NSObject

@property (nonatomic, strong) STCoreSyncer *syncer;
@property (nonatomic, strong) NSString *refreshToken;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) STSession *session;


+ (STViewerCore *)sharedViewerCore;

- (void)start;
- (void)getAccessToken;
- (void)getRoles;
- (void)gotRoles:(NSDictionary *)roles forAccount:(NSDictionary *)account;
- (void)accessTokenExpired;
- (void)gotEntityProperties:(NSDictionary *)entityProperties;
- (void)getEntityRolesPage:(int)pageNumber;
- (void)gotEntityRoles:(NSDictionary *)entityRoles;
- (void)getItemsForEntityName:(NSString *)entityName page:(int)pageNumber;
- (void)gotItemList:(NSDictionary *)itemList;
- (void)selectCellWithEntityName:(NSString *)entityName;

@end
