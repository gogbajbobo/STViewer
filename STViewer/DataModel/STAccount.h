//
//  STAccount.h
//  STViewer
//
//  Created by Maxim Grigoriev on 10/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STComment.h"

@class STRole;

@interface STAccount : STComment

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * serverId;
@property (nonatomic, retain) NSSet *roles;
@end

@interface STAccount (CoreDataGeneratedAccessors)

- (void)addRolesObject:(STRole *)value;
- (void)removeRolesObject:(STRole *)value;
- (void)addRoles:(NSSet *)values;
- (void)removeRoles:(NSSet *)values;

@end
