//
//  STItemRoles.h
//  STViewer
//
//  Created by Maxim Grigoriev on 10/25/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STEntityRole.h"

@class STItem;

@interface STItemRole : STEntityRole

@property (nonatomic, retain) STItem *actorItem;
@property (nonatomic, retain) STItem *hostItem;

@end
