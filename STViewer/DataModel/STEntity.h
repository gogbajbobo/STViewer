//
//  STEntity.h
//  STViewer
//
//  Created by Maxim Grigoriev on 10/25/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STComment.h"

@class STEntityProperty, STEntityRole;

@interface STEntity : STComment

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *actingRoles;
@property (nonatomic, retain) NSSet *properties;
@property (nonatomic, retain) NSSet *roles;
@end

@interface STEntity (CoreDataGeneratedAccessors)

- (void)addActingRolesObject:(STEntityRole *)value;
- (void)removeActingRolesObject:(STEntityRole *)value;
- (void)addActingRoles:(NSSet *)values;
- (void)removeActingRoles:(NSSet *)values;

- (void)addPropertiesObject:(STEntityProperty *)value;
- (void)removePropertiesObject:(STEntityProperty *)value;
- (void)addProperties:(NSSet *)values;
- (void)removeProperties:(NSSet *)values;

- (void)addRolesObject:(STEntityRole *)value;
- (void)removeRolesObject:(STEntityRole *)value;
- (void)addRoles:(NSSet *)values;
- (void)removeRoles:(NSSet *)values;

@end
