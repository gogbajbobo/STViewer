//
//  STEntityItemContoller.h
//  STViewer
//
//  Created by Maxim Grigoriev on 10/25/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STItem.h"
#import "STItemProperty.h"
#import "STItemRole.h"

@interface STItemContoller : NSObject <UITableViewDataSource, UITableViewDelegate>

+ (STItem *)itemWithXid:(NSString *)xid andEntityName:(NSString *)itemName;
+ (void)setValue:(NSString *)value forPropertyId:(NSString *)propertyId atItem:(STItem *)item;
+ (void)setRoleWithName:(NSString *)roleName actorEntityName:(NSString *)actorName andActorXid:(NSString *)actorXid atItem:(STItem *)item;

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSString *itemEntityName;

@end
