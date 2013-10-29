//
//  STRolesController.m
//  STViewer
//
//  Created by Maxim Grigoriev on 10/17/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STRolesController.h"
#import "STRole.h"
#import "STRoleCell.h"

@interface STRolesController() <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, strong) NSIndexPath *tallIndexPath;


@end


@implementation STRolesController

- (void)setSession:(STSession *)session {
    
    if (session != _session) {
 
        _session = session;
        [self performFetch];
        
    }
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STRole class])];
        request.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], nil];
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.session.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
//        _resultsController.delegate = self;
        
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
        for (NSManagedObject *object in self.resultsController.fetchedObjects) {
            //                NSLog(@"distance %@", [object valueForKey:@"distance"]);
        }
    }
}


#pragma mark - NSFetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    //    NSLog(@"controllerWillChangeContent");
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    //    NSLog(@"taskControllerDidChangeContent");
    [self.tableView reloadData];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"taskControllerDidChangeContent" object:self];
//    [self checkNoAddressTasks];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    //    NSLog(@"controller didChangeObject");
    //    NSLog(@"indexPath %@, newIndexPath %@", indexPath, newIndexPath);
    
    if ([[self.session status] isEqualToString:@"running"]) {
        
        
        if (type == NSFetchedResultsChangeDelete) {
            
            //            NSLog(@"NSFetchedResultsChangeDelete");
            
        } else if (type == NSFetchedResultsChangeInsert) {
            
            //            NSLog(@"NSFetchedResultsChangeInsert");
            
        } else if (type == NSFetchedResultsChangeUpdate) {
            
            //            NSLog(@"NSFetchedResultsChangeUpdate");
            
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
            sectionTitle = @"Roles:";
            break;

        default:
            break;
            
    }
    
    return sectionTitle;
    
}



- (STRoleCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"roleCell";
    STRoleCell *cell = [[STRoleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    STRole *role = self.resultsController.fetchedObjects[indexPath.row];
    
    cell.textLabel.text = role.code;
    
    if (role.data) {
        
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
        
    }

//    NSLog(@"indexPath %@", indexPath);
//    NSLog(@"tallIndexPath %@", self.tallIndexPath);
    
    if ([indexPath compare:self.tallIndexPath] == NSOrderedSame) {
        
        cell.dataLabel.text = role.data;
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 44;
    
    if ([indexPath compare:self.tallIndexPath] == NSOrderedSame) {

        STRole *role = self.resultsController.fetchedObjects[indexPath.row];
        CGSize dataLabelSize = [role.data sizeWithFont:[STRoleCell dataLabelFont]];
        height += dataLabelSize.height;
        
    }
    
    return height;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    

}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    STRoleCell *cell = (STRoleCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryDetailButton) {

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
