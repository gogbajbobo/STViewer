//
//  STItem.h
//  STViewer
//
//  Created by Maxim Grigoriev on 10/25/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STEntity.h"

@class STItemProperty, STItemRole;

@interface STItem : STEntity

@property (nonatomic, retain) NSSet *itemActingRoles;
@property (nonatomic, retain) NSSet *itemProperties;
@property (nonatomic, retain) NSSet *itemRoles;
@end

@interface STItem (CoreDataGeneratedAccessors)

- (void)addItemActingRolesObject:(STItemRole *)value;
- (void)removeItemActingRolesObject:(STItemRole *)value;
- (void)addItemActingRoles:(NSSet *)values;
- (void)removeItemActingRoles:(NSSet *)values;

- (void)addItemPropertiesObject:(STItemProperty *)value;
- (void)removeItemPropertiesObject:(STItemProperty *)value;
- (void)addItemProperties:(NSSet *)values;
- (void)removeItemProperties:(NSSet *)values;

- (void)addItemRolesObject:(STItemRole *)value;
- (void)removeItemRolesObject:(STItemRole *)value;
- (void)addItemRoles:(NSSet *)values;
- (void)removeItemRoles:(NSSet *)values;

@end
