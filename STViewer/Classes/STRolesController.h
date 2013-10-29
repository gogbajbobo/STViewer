//
//  STRolesController.h
//  STViewer
//
//  Created by Maxim Grigoriev on 10/17/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <STManagedTracker/STSession.h>

@interface STRolesController : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) STSession *session;

@end
