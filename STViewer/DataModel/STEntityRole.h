//
//  STEntityRole.h
//  STViewer
//
//  Created by Maxim Grigoriev on 10/25/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STComment.h"

@class STEntity;

@interface STEntityRole : STComment

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) STEntity *actorEntity;
@property (nonatomic, retain) STEntity *hostEntity;

@end
