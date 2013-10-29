//
//  STEntityController.h
//  STViewer
//
//  Created by Maxim Grigoriev on 10/15/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STEntity.h"
#import "STEntityProperty.h"
#import "STEntityRole.h"

@interface STEntityController : NSObject <UITableViewDataSource, UITableViewDelegate>

+ (STEntity *)entityForName:(NSString *)entityName;
+ (STEntityProperty *)entityPropertyForId:(NSString *)propertyId;
+ (STEntityRole *)entityRoleWithName:(NSString *)roleName forEntityName:(NSString *)entityName;

- (int)numberOfEntities;

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) UINavigationController *navigationController;

@end
