//
//  STEntityController.m
//  STViewer
//
//  Created by Maxim Grigoriev on 10/15/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STEntityController.h"
#import "STViewerCore.h"
#import "STEntityCell.h"
#import "STItemContoller.h"

@interface STEntityController() <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, strong) STSession *session;
@property (nonatomic, strong) NSIndexPath *tallIndexPath;

@end

@implementation STEntityController

+ (STViewerCore *)viewer {
    return [STViewerCore sharedViewerCore];
}

+ (STEntity *)entityForName:(NSString *)entityName {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STEntity class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"SELF.name == %@", entityName];
    request.includesSubentities = NO;

    NSError *error;
    NSArray *fetchResult = [self.viewer.session.document.managedObjectContext executeFetchRequest:request error:&error];
    
    STEntity *entity;
    
    if ([fetchResult lastObject]) {
        entity = [fetchResult lastObject];
    } else {
        entity = (STEntity *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STEntity class]) inManagedObjectContext:self.viewer.session.document.managedObjectContext];
        entity.name = entityName;
    }
    
//    NSLog(@"entity %@", entity);

    return entity;
    
}

+ (STEntityProperty *)entityPropertyForId:(NSString *)propertyId {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STEntityProperty class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"SELF.propertyId == %@", propertyId];
    request.includesSubentities = NO;

    NSError *error;
    NSArray *fetchResult = [self.viewer.session.document.managedObjectContext executeFetchRequest:request error:&error];
    
    STEntityProperty *entityProperty;
    
    if ([fetchResult lastObject]) {
        entityProperty = [fetchResult lastObject];
    } else {
        entityProperty = (STEntityProperty *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STEntityProperty class]) inManagedObjectContext:self.viewer.session.document.managedObjectContext];
        entityProperty.propertyId = propertyId;
    }
    
//    NSLog(@"entityProperty %@", entityProperty);
    
    return entityProperty;

}

+ (STEntityRole *)entityRoleWithName:(NSString *)roleName forEntityName:(NSString *)entityName {
    
    STEntity *entity = [self entityForName:entityName];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STEntityRole class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"SELF.name == %@ && SELF.hostEntity == %@", roleName, entity];
    request.includesSubentities = NO;

    NSError *error;
    NSArray *fetchResult = [self.viewer.session.document.managedObjectContext executeFetchRequest:request error:&error];
    
    STEntityRole *entityRole;
    
    if ([fetchResult lastObject]) {
        entityRole = [fetchResult lastObject];
    } else {
        entityRole = (STEntityRole *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STEntityRole class]) inManagedObjectContext:self.viewer.session.document.managedObjectContext];
        entityRole.name = roleName;
        entityRole.hostEntity = entity;
    }
    
    //    NSLog(@"entityProperty %@", entityProperty);
    
    return entityRole;

}

- (id) init {
    self = [super init];
    if (self) {
        [self performFetch];
    }
    return self;
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STEntity class])];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.includesSubentities = NO;

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

- (int)numberOfEntities {
    
    return self.resultsController.fetchedObjects.count;
    
}

- (STSession *)session {
    
    return [[self class] viewer].session;
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
            [[NSNotificationCenter defaultCenter] postNotificationName:@"numberOfEntitiesDidChange" object:self];
            [self.tableView reloadData];
            
        } else if (type == NSFetchedResultsChangeInsert) {
            
            //            NSLog(@"NSFetchedResultsChangeInsert");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"numberOfEntitiesDidChange" object:self];
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
            sectionTitle = @"Entities:";
            break;
            
        default:
            break;
            
    }
    
    return sectionTitle;
    
}



- (STEntityCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"entityCell";
    STEntityCell *cell = [[STEntityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    STEntity *entity = self.resultsController.fetchedObjects[indexPath.row];
    
    cell.textLabel.text = entity.name;
    cell.numberOfLines = entity.properties.count + entity.roles.count;

    if (cell.numberOfLines > 0) {
        
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        
    } else {
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    
    
    if ([indexPath compare:self.tallIndexPath] == NSOrderedSame) {
        
        cell.propertiesLabel.text = [[self propertiesTextFor:entity] stringByAppendingString:[self rolesTextFor:entity]];
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    return cell;
}

- (NSString *)propertiesTextFor:(STEntity *)entity {
    
    NSString *propertiesText = @"";
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"propertyId" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    NSArray *propertiesArray = [entity.properties sortedArrayUsingDescriptors:sortDescriptors];
    
    for (STEntityProperty *property in propertiesArray) {
        
        propertiesText = [propertiesText stringByAppendingFormat:@"%@\r\n", property.propertyId];
        
//        NSLog(@"propertyId %@", property.propertyId);
//        NSLog(@"propertiesText %@", propertiesText);
        
    }
    
    return propertiesText;
    
}

- (NSString *)rolesTextFor:(STEntity *)entity {
    
    NSString *rolesText = @"";
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    NSArray *roles = [entity.roles sortedArrayUsingDescriptors:sortDescriptors];
    
    for (STEntityRole *role in roles) {
        
        rolesText = [rolesText stringByAppendingFormat:@"%@\r\n", role.name];
        
        //        NSLog(@"propertyId %@", property.propertyId);
        //        NSLog(@"propertiesText %@", propertiesText);
        
    }
    
    return rolesText;

}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 44;
    
    if ([indexPath compare:self.tallIndexPath] == NSOrderedSame) {
        
        STEntity *entity = self.resultsController.fetchedObjects[indexPath.row];
        NSString *text = [[self propertiesTextFor:entity] stringByAppendingString:[self rolesTextFor:entity]];
        CGSize dataLabelSize = [text sizeWithFont:[STEntityCell propertiesLabelFont]];
        height += dataLabelSize.height * (entity.properties.count + entity.roles.count);
        
    }
    
    return height;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STEntity *entity = self.resultsController.fetchedObjects[indexPath.row];
    [[[self class] viewer] selectCellWithEntityName:entity.name];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectEntity" object:self userInfo:[NSDictionary dictionaryWithObject:entity forKey:@"entity"]];

}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    STEntityCell *cell = (STEntityCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryDetailDisclosureButton) {
        
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
        
    }
    
}


@end
