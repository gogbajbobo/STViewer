//
//  STEntityItemContoller.m
//  STViewer
//
//  Created by Maxim Grigoriev on 10/25/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STItemContoller.h"
#import "STViewerCore.h"
#import "STEntityCell.h"

@interface STItemContoller() <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, strong) STSession *session;
@property (nonatomic, strong) NSIndexPath *tallIndexPath;

@end

@implementation STItemContoller

- (STSession *)session {
    
    return [[self class] viewer].session;
}

+ (STViewerCore *)viewer {
    return [STViewerCore sharedViewerCore];
}

+ (STItem *)itemWithXid:(NSString *)xid andEntityName:(NSString *)itemName {
    
    NSString *xidString = [xid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSData *xidData = [self dataFromString:xidString];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STItem class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"SELF.xid == %@", xidData];
    
    NSError *error;
    NSArray *fetchResult = [self.viewer.session.document.managedObjectContext executeFetchRequest:request error:&error];
    
    STItem *item;
    
    if ([fetchResult lastObject]) {
        item = [fetchResult lastObject];
        if (![item.name isEqualToString:itemName]) {
            NSLog(@"Error! Stored and recieved entity name doesn't match for xid:%@", xid);
            NSLog(@"stored item %@", item);
            NSLog(@"recieved itemName %@", itemName);
            NSLog(@"Delete old and create new object with xid:%@", xid);
            [self.viewer.session.document.managedObjectContext deleteObject:item];
            item = [self itemWithXid:xid andEntityName:itemName];
        }
    } else {
        item = (STItem *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STItem class]) inManagedObjectContext:self.viewer.session.document.managedObjectContext];
        item.xid = xidData;
        item.name = itemName;
    }

    //    NSLog(@"entity %@", entity);
    
    return item;

}

+ (void)setValue:(NSString *)value forPropertyId:(NSString *)propertyId atItem:(STItem *)item {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STItemProperty class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"SELF.propertyId == %@ && SELF.item == %@", propertyId, item];
    
    NSError *error;
    NSArray *fetchResult = [self.viewer.session.document.managedObjectContext executeFetchRequest:request error:&error];
    
    STItemProperty *itemProperty;
    
    if ([fetchResult lastObject]) {
        itemProperty = [fetchResult lastObject];
    } else {
        itemProperty = (STItemProperty *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STItemProperty class]) inManagedObjectContext:self.viewer.session.document.managedObjectContext];
        itemProperty.propertyId = propertyId;
        itemProperty.item = item;
    }
    
    itemProperty.value = value;
    
}

+ (void)setRoleWithName:(NSString *)roleName actorEntityName:(NSString *)actorName andActorXid:(NSString *)actorXid atItem:(STItem *)item {
    
    STItem *actorItem = [self itemWithXid:actorXid andEntityName:actorName];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STItemRole class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"SELF.name == %@ && SELF.hostItem == %@", roleName, item];
    
    NSError *error;
    NSArray *fetchResult = [self.viewer.session.document.managedObjectContext executeFetchRequest:request error:&error];
    
    STItemRole *itemRole;
    
    if ([fetchResult lastObject]) {
        itemRole = [fetchResult lastObject];
    } else {
        itemRole = (STItemRole *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STItemRole class]) inManagedObjectContext:self.viewer.session.document.managedObjectContext];
        itemRole.name = roleName;
        itemRole.hostItem = item;
    }
    
    itemRole.actorItem = actorItem;

}

+ (NSData *)dataFromString:(NSString *)string {
    NSMutableData *data = [NSMutableData data];
    int i;
    for (i = 0; i+2 <= string.length; i+=2) {
        NSRange range = NSMakeRange(i, 2);
        NSString* hexString = [string substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexString];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}


- (id) init {
    self = [super init];
    if (self) {
//        [self performFetch];
    }
    return self;
}

- (void)setItemEntityName:(NSString *)itemEntityName {
    
    _itemEntityName = itemEntityName;
    [self performFetch];
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STItem class])];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"SELF.name == %@", self.itemEntityName];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.session.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _resultsController.delegate = self;
        
    }
    
    return _resultsController;
    
}

- (void)performFetch {
    
    self.resultsController = nil;
    NSError *error;
    if (![self.resultsController performFetch:&error]) {
        NSLog(@"performFetch error %@", error);
    } else {
        //            NSLog(@"fetchedObjects %@", self.resultsController.fetchedObjects);
    }
    
}


#pragma mark - NSFetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    //    NSLog(@"controllerWillChangeContent");
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    //    NSLog(@"taskControllerDidChangeContent");
    //    [self.tableView reloadData];
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"entityControllerDidChangeContent" object:self];
    //    [self checkNoAddressTasks];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    //    NSLog(@"controller didChangeObject");
    //    NSLog(@"indexPath %@, newIndexPath %@", indexPath, newIndexPath);
    
    if ([[self.session status] isEqualToString:@"running"]) {
        
        
        if (type == NSFetchedResultsChangeDelete) {
            
            //            NSLog(@"NSFetchedResultsChangeDelete");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"numberOfItemsDidChange" object:self];
            [self.tableView reloadData];
            
        } else if (type == NSFetchedResultsChangeInsert) {
            
            //            NSLog(@"NSFetchedResultsChangeInsert");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"numberOfItemsDidChange" object:self];
            [self.tableView reloadData];
            
        } else if (type == NSFetchedResultsChangeUpdate) {
            
            //            NSLog(@"NSFetchedResultsChangeUpdate");
            //            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
        } else if (type == NSFetchedResultsChangeMove) {
            
            //            NSLog(@"NSFetchedResultsChangeMove");
            
        }
        
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    //    NSLog(@"controller didChangeSection");
    //    NSLog(@"sectionIndex %d", sectionIndex);
    
    if (type == NSFetchedResultsChangeDelete) {
        
        //        NSLog(@"NSFetchedResultsChangeDelete");
        
    } else if (type == NSFetchedResultsChangeInsert) {
        
        //        NSLog(@"NSFetchedResultsChangeInsert");
        
        
    }
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.resultsController.fetchedObjects.count;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *sectionTitle = nil;
    
    switch (section) {
            
        case 0:
            sectionTitle = @"Items:";
            break;
            
        default:
            break;
            
    }
    
    return sectionTitle;
    
}



- (STEntityCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"itemCell";
    STEntityCell *cell = [[STEntityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    STItem *item = self.resultsController.fetchedObjects[indexPath.row];
    
    NSString *text = nil;
    
    for (STItemProperty *itemProperty in item.itemProperties) {
        if ([itemProperty.propertyId isEqualToString:@"name"]) {
            text = itemProperty.value;
        } else {
        }
    }
    
    if (!text) {
        text = [NSString stringWithFormat:@"%@", item.xid];
    }
    
    cell.textLabel.text = text;
    cell.numberOfLines = item.itemProperties.count + item.itemRoles.count;
    
//    if (cell.numberOfLines > 0) {
//        
//        cell.accessoryType = UITableViewCellAccessoryDetailButton;
//        
//    } else {
//        
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        
//    }
    
    
    if ([indexPath compare:self.tallIndexPath] == NSOrderedSame) {
        
        cell.propertiesLabel.text = [[self propertiesTextFor:item] stringByAppendingString:[self rolesTextFor:item]];
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSString *)propertiesTextFor:(STItem *)item {
    
    NSString *propertiesText = @"";
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"propertyId" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    NSArray *propertiesArray = [item.itemProperties sortedArrayUsingDescriptors:sortDescriptors];
    
    for (STItemProperty *property in propertiesArray) {
        
        propertiesText = [propertiesText stringByAppendingFormat:@"%@ - %@\r\n", property.propertyId, property.value];
        
        //        NSLog(@"propertyId %@", property.propertyId);
        //        NSLog(@"propertiesText %@", propertiesText);
        
    }
    
    return propertiesText;
    
}

- (NSString *)rolesTextFor:(STItem *)item {
    
    NSString *rolesText = @"";
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    NSArray *roles = [item.itemRoles sortedArrayUsingDescriptors:sortDescriptors];
    
    for (STItemRole *role in roles) {
        
        NSString *text = nil;
        
        for (STItemProperty *itemProperty in role.actorItem.itemProperties
             ) {
            if ([itemProperty.propertyId isEqualToString:@"name"]) {
                text = itemProperty.value;
            }
        }
        
        if (!text) {
            text = [NSString stringWithFormat:@"%@", role.actorItem.xid];
        }

        
        
        rolesText = [rolesText stringByAppendingFormat:@"%@ %@\r\n", role.name, text];
        
        //        NSLog(@"propertyId %@", property.propertyId);
        //        NSLog(@"propertiesText %@", propertiesText);
        
    }
    
    return rolesText;
    
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 44;
    
    if ([indexPath compare:self.tallIndexPath] == NSOrderedSame) {
        
        STItem *item = self.resultsController.fetchedObjects[indexPath.row];
        NSString *text = [[self propertiesTextFor:item] stringByAppendingString:[self rolesTextFor:item]];
        CGSize dataLabelSize = [text sizeWithFont:[STEntityCell propertiesLabelFont]];
        height += dataLabelSize.height * (item.itemProperties.count + item.itemRoles.count);
        
    }
    
    return height;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STEntityCell *cell = (STEntityCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if ([indexPath compare:self.tallIndexPath] == NSOrderedSame) {
        
        self.tallIndexPath = nil;
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    } else {
        
        NSIndexPath *previousTallIndexPath = self.tallIndexPath;
        self.tallIndexPath = indexPath;
        if (previousTallIndexPath) {
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:previousTallIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    
    if (cell.accessoryType == UITableViewCellAccessoryDetailButton) {
        
    }

}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
}

@end
