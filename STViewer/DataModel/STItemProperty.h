//
//  STItemProperty.h
//  STViewer
//
//  Created by Maxim Grigoriev on 10/25/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STEntityProperty.h"

@class STItem;

@interface STItemProperty : STEntityProperty

@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) STItem *item;

@end
