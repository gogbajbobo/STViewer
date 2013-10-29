//
//  STViewerCore.m
//  STViewer
//
//  Created by Maxim Grigoriev on 9/30/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STViewerCore.h"
#import "STAccount.h"
#import "STRole.h"
#import "STEntityController.h"
#import "STItemContoller.h"
#import <STManagedTracker/STQueue.h>

@interface STViewerCore()

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSDictionary *rolesDic;
@property (nonatomic, strong) NSDictionary *accountDic;
@property (nonatomic, strong) STAccount *account;
@property (nonatomic, strong) NSString *entityName;
@property (nonatomic, strong) STQueue *noPropertiesItems;

@end

@implementation STViewerCore

@synthesize accessToken = _accessToken;

+ (STViewerCore *)sharedViewerCore {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedViewerCore = nil;
    
    dispatch_once(&pred, ^{
        
        _sharedViewerCore = [[self alloc] init];
        [_sharedViewerCore addNotificationObservers];
//        NSLog(@"_sharedViewerCore init");
        
    });
    
    return _sharedViewerCore;
    
}

- (STQueue *)noPropertiesItems {
    
    if (!_noPropertiesItems) {
        _noPropertiesItems = [[STQueue alloc] init];
        _noPropertiesItems.queueLength = 1;
    }
    return _noPropertiesItems;
    
}

- (void)addNotificationObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStatusChanged:) name:@"sessionStatusChanged" object:nil];
    
}

- (void)removeNotificationObservers {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sessionStatusChanged" object:nil];

}

- (STCoreSyncer *)syncer {
    
    if (!_syncer) {
        _syncer = [[STCoreSyncer alloc] init];
    }
    return  _syncer;
    
}

- (NSString *)accessToken {
    
    if (!_accessToken) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *accessToken = [defaults objectForKey:@"accessToken"];
        
//        if (!accessToken) {
//            
//            [self getAccessToken];
//            
//        }
        
        _accessToken = accessToken;
        
    }
    
    return _accessToken;
    
}

- (void)setAccessToken:(NSString *)accessToken {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"accessToken"];
    [defaults synchronize];
    _accessToken = accessToken;
    if (_accessToken) {
        [self getRoles];
    }
    
}

- (void)start {
    
    [self checkAccessToken];
    
}

- (void)checkAccessToken {
    
    if (!self.accessToken) {
        
        [self getAccessToken];
        
    } else {
        
        NSLog(@"self.accessToken %@", self.accessToken);
        [self getRoles];
        
    }
    
}

- (void)getAccessToken {
    
    [self.syncer getAccessTokenWithRefreshToken:REFRESH_TOKEN clientId:CLIENT_ID clientSecret:CLIENT_SECRET];

}

- (void)accessTokenExpired {
    
    self.accessToken = nil;
    [self checkAccessToken];
    
}

- (void)getRoles {
    
    [self.syncer getRolesForAccessToken:self.accessToken];
    
}

- (void)gotRoles:(NSDictionary *)roles forAccount:(NSDictionary *)account {
    
    self.rolesDic = roles;
    self.accountDic = account;
    self.uid = [[self.accountDic valueForKey:@"id"] stringValue];
    [self startSession];
    
}

- (void)startSession {
    
    [[STSessionManager sharedManager] startSessionForUID:self.uid authDelegate:nil controllers:nil settings:nil documentPrefix:@"STV"];

}

- (void)sessionStatusChanged:(NSNotification *)notification {
    
    STSession *session = [notification object];
    
    if ([session.uid isEqualToString:self.uid] && [session.status isEqualToString:@"running"]) {
        
        self.session = session;
        [self storeAccount];
        [self storeRoles];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionStarted" object:self];
        
    }
    
}

- (void)storeAccount {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STAccount class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"SELF.serverId == %@", [NSNumber numberWithInt:[self.uid intValue]]];

    NSError *error;
    NSArray *fetchResult = [self.session.document.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([fetchResult lastObject]) {
        self.account = [fetchResult lastObject];
    } else {
        self.account = (STAccount *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STAccount class]) inManagedObjectContext:self.session.document.managedObjectContext];
    }
    
    self.account.code = [self.accountDic valueForKey:@"code"];
    self.account.email = [self.accountDic valueForKey:@"email"];
    self.account.serverId = [self.accountDic valueForKey:@"id"];
    self.account.name = [self.accountDic valueForKey:@"name"];
    self.account.roles = nil;

//    NSLog(@"account %@", self.account);
    
}

- (void)storeRoles {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STRole class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
    
    NSError *error;
    NSArray *fetchResult = [self.session.document.managedObjectContext executeFetchRequest:request error:&error];

    for (STRole *role in fetchResult) {
        [self.session.document.managedObjectContext deleteObject:role];
    }
    
    for (NSDictionary *roleDic in self.rolesDic) {
        
        STRole *role = (STRole *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STRole class]) inManagedObjectContext:self.session.document.managedObjectContext];
        
        for (NSString *key in [[[role entity] propertiesByName] allKeys]) {
            
            id value = [roleDic valueForKey:key];
            
            if (value) {
                
                [role setValue:value forKey:key];
                
            }
            
        }
        
//        NSLog(@"role %@", role);
        
        [self.account addRolesObject:role];
        
        if ([role.code isEqualToString:@"ch.entity"]) {
            [self getEntityPropertiesPage:1];
        }
        
    }
    
//    NSLog(@"self.account with roles %@", self.account);
    
}

- (void)getEntityPropertiesPage:(int)pageNumber {
    
    [self.syncer getEntityPropertiesPage:pageNumber];
    
}

- (void)gotEntityProperties:(NSDictionary *)entityProperties {
    
    int pageRowCount = [[entityProperties valueForKey:@"pageRowCount"] intValue];
    int pageSize = [[entityProperties valueForKey:@"pageSize"] intValue];
    int pageNumber = [[entityProperties valueForKey:@"pageNumber"] intValue];
    
//    NSLog(@"pageNumber %d, pageRowCount %d, pageSize %d", pageNumber, pageRowCount, pageSize);
    
    if (pageRowCount >= pageSize) {
        [self getEntityPropertiesPage:pageNumber+1];
    } else {
        NSLog(@"got all entity properties");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"gotAllEntityProperties" object:self];
    }
    
    NSArray *data = [entityProperties objectForKey:@"data"];
    
    for (NSDictionary *entityPropertyDic in data) {
        
        NSDictionary *properties = [entityPropertyDic objectForKey:@"properties"];
        NSString *entityName = [properties valueForKey:@"entity"];
        
//        NSLog(@"entityName %@", entityName);
        
        STEntity *entity = [STEntityController entityForName:entityName];
        
        NSDictionary *property = [properties valueForKey:@"property"];
        NSString *propertyId = [property valueForKey:@"id"];
        
//        NSLog(@"propertyName %@", propertyId);
        
        STEntityProperty *entityProperty = [STEntityController entityPropertyForId:propertyId];
        
        [entity addPropertiesObject:entityProperty];
        
    }
    
}

- (void)getEntityRolesPage:(int)pageNumber {
    
    [self.syncer getEntityRolesPage:pageNumber];
    
}

- (void)gotEntityRoles:(NSDictionary *)entityRoles {
    
    int pageRowCount = [[entityRoles valueForKey:@"pageRowCount"] intValue];
    int pageSize = [[entityRoles valueForKey:@"pageSize"] intValue];
    int pageNumber = [[entityRoles valueForKey:@"pageNumber"] intValue];
    
    //    NSLog(@"pageNumber %d, pageRowCount %d, pageSize %d", pageNumber, pageRowCount, pageSize);
    
    if (pageRowCount >= pageSize) {
//        NSLog(@"pageNumber %d", pageNumber);
        [self getEntityRolesPage:pageNumber+1];
    } else {
        NSLog(@"got all entity roles");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"gotAllEntityRoles" object:self];
    }
    
    NSArray *data = [entityRoles objectForKey:@"data"];

    for (NSDictionary *entityRolesDic in data) {
        
        NSDictionary *properties = [entityRolesDic objectForKey:@"properties"];
        NSString *entityName = [properties valueForKey:@"entity"];
        NSString *roleName = [properties valueForKey:@"name"];
        NSString *actorName = [properties valueForKey:@"actor"];
        
        //        NSLog(@"entityName %@", entityName);
        
        STEntityRole *entityRole = [STEntityController entityRoleWithName:roleName forEntityName:entityName];
        STEntity *actorEntity = [STEntityController entityForName:actorName];
        entityRole.actorEntity = actorEntity;
        
    }

}

- (void)getItemsForEntityName:(NSString *)entityName page:(int)pageNumber {
    
    self.entityName = entityName;
    [self.syncer getItemListForEntityName:entityName page:pageNumber];
    
}

- (void)gotItemList:(NSDictionary *)itemList {

    int pageRowCount = [[itemList valueForKey:@"pageRowCount"] intValue];
    int pageSize = [[itemList valueForKey:@"pageSize"] intValue];
//    int pageNumber = [[itemList valueForKey:@"pageNumber"] intValue];
    
    //    NSLog(@"pageNumber %d, pageRowCount %d, pageSize %d", pageNumber, pageRowCount, pageSize);
    
    if (pageRowCount >= pageSize) {
//        NSLog(@"pageNumber %d", pageNumber);
//        [self getEntityListForName:self.entityName page:pageNumber+1];
    } else {
        NSLog(@"got all item list");
    }

    NSArray *data = [itemList objectForKey:@"data"];
    
    NSLog(@"data.count %d", data.count);

    for (NSDictionary *recievedItem in data) {
        
//        NSLog(@"recievedItem %@", recievedItem);
        
        NSString *xid = [recievedItem valueForKey:@"xid"];
        NSString *entityName = [[recievedItem valueForKey:@"name"] componentsSeparatedByString:@"ch."][1];
        
//        NSLog(@"entityName %@, xid:%@", entityName, xid);
        
        STEntity *entity = [STEntityController entityForName:entityName];
        STItem *item = [STItemContoller itemWithXid:xid andEntityName:entityName];

        NSDictionary *itemProperties = [recievedItem valueForKey:@"properties"];
        
//        NSLog(@"entity %@", entity);
//        NSLog(@"item %@", item);
//        NSLog(@"entity.properties.count %d", entity.properties.count);
        
        for (STEntityProperty *entityProperty in entity.properties) {
            
            NSString *propertyId = entityProperty.propertyId;
            NSString *value = [itemProperties valueForKey:propertyId];

//            NSLog(@"propertyId %@", propertyId);
//            NSLog(@"value %@", value);

            [STItemContoller setValue:value forPropertyId:propertyId atItem:item];
            
        }
        
//        NSLog(@"entity.roles.count %d", entity.roles.count);
        
        for (STEntityRole *role in entity.roles) {

            NSDictionary *dicValue = [itemProperties valueForKey:role.name];
            
            if (dicValue) {
                
                NSString *actorXid = [dicValue valueForKey:@"xid"];
                
                //            NSLog(@"roleName %@", role.name);
                //            NSLog(@"actorXid %@", actorXid);
                //            NSLog(@"role.actorEntity.name %@", role.actorEntity.name);
                
                if (actorXid) {
                    
                    [STItemContoller setRoleWithName:role.name actorEntityName:role.actorEntity.name andActorXid:actorXid atItem:item];
                    
//                    NSLog(@"item.roles.count %d", item.itemRoles.count);
                    
                    for (STItemRole *itemRole in item.itemRoles) {
                        
//                        NSLog(@"itemRole.actorItem.name %@", itemRole.actorItem.name);
//                        NSLog(@"itemRole.actorItem.itemProperties.count %d", itemRole.actorItem.itemProperties.count);
                        
                        if (itemRole.actorItem.itemProperties.count == 0) {
                            
                            if (![self.noPropertiesItems containsObject:itemRole.actorItem]) {

                                if (self.noPropertiesItems.queueLength == self.noPropertiesItems.count) {
                                    self.noPropertiesItems.queueLength += 1;
                                }
                                [self.noPropertiesItems enqueue:itemRole.actorItem];
                                
                                NSLog(@"self.noPropertiesItems.count %d", self.noPropertiesItems.count);

                            }
                            
                        }
                        
                    }
                    
                }

            }
            
        }
        
        

        
        
        
        
//        NSString *xmlData = [properties valueForKey:@"xmlData"];
//        NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:[xmlData dataUsingEncoding:NSUTF8StringEncoding]];
//        xmlParser.delegate = self.syncer.responseParser;
//        self.syncer.responseParser.entityName = entityName;
//        [xmlParser parse];
        
    }
    
    if (self.noPropertiesItems.count > 0) {
        [self getPropertiesForItems];
    }
    
//    [self checkNoPropertiesItem];
    
}

//- (void)checkNoPropertiesItem {
//    
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STItem class])];
//    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
//    request.predicate = [NSPredicate predicateWithFormat:@"SELF. == %@", xidData];
//    
//    NSError *error;
//    NSArray *fetchResult = [self.viewer.session.document.managedObjectContext executeFetchRequest:request error:&error];
//
//}

- (void)getPropertiesForItems {
    
    STItem *item = [self.noPropertiesItems dequeue];
    NSString *xidString = [NSString stringWithFormat:@"%@", item.xid];
    xidString = [xidString stringByReplacingOccurrencesOfString:@" " withString:@""];
    xidString = [xidString stringByReplacingOccurrencesOfString:@"<" withString:@""];
    xidString = [xidString stringByReplacingOccurrencesOfString:@">" withString:@""];

    NSLog(@"item.name %@ xidString %@ have no properties", item.name, xidString);
    [self.syncer getPropertiesForItemWithXid:xidString andEntityName:item.name];
    NSLog(@"self.noPropertiesItems.count %d", self.noPropertiesItems.count);
    
}

- (void)selectCellWithEntityName:(NSString *)entityName {
    
    [self getItemsForEntityName:entityName page:1];

}

@end
