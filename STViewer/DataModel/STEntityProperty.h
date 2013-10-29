//
//  STEntityProperty.h
//  STViewer
//
//  Created by Maxim Grigoriev on 10/26/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STComment.h"

@class STEntity;

@interface STEntityProperty : STComment

@property (nonatomic, retain) NSString * propertyId;
@property (nonatomic, retain) NSSet *hostEntities;
@end

@interface STEntityProperty (CoreDataGeneratedAccessors)

- (void)addHostEntitiesObject:(STEntity *)value;
- (void)removeHostEntitiesObject:(STEntity *)value;
- (void)addHostEntities:(NSSet *)values;
- (void)removeHostEntities:(NSSet *)values;

@end
