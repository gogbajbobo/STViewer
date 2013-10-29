//
//  STRole.h
//  STViewer
//
//  Created by Maxim Grigoriev on 10/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STComment.h"

@class STAccount;

@interface STRole : STComment

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * data;
@property (nonatomic, retain) NSSet *accounts;
@end

@interface STRole (CoreDataGeneratedAccessors)

- (void)addAccountsObject:(STAccount *)value;
- (void)removeAccountsObject:(STAccount *)value;
- (void)addAccounts:(NSSet *)values;
- (void)removeAccounts:(NSSet *)values;

@end
