//
//  STMainTVC.m
//  STViewer
//
//  Created by Maxim Grigoriev on 10/16/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STMainTVC.h"
#import "STViewerCore.h"
#import "STAccount.h"
#import "STRolesController.h"
#import "STEntityController.h"
#import "STItemContoller.h"

@interface STMainTVC ()

@property (nonatomic, strong) STAccount *account;
@property (nonatomic, strong) STSession *session;
@property (nonatomic) BOOL sessionRunning;
@property (nonatomic, strong) NSArray *accountKeys;
@property (nonatomic, strong) STRolesController *rolesController;
@property (nonatomic, strong) STEntityController *entityController;
@property (nonatomic, strong) STItemContoller *itemController;
@property (nonatomic) BOOL gotAllEntity;

@end

@implementation STMainTVC

@synthesize sessionRunning = _sessionRunning;

- (void)setSessionRunning:(BOOL)sessionRunning {
    
    if (_sessionRunning != sessionRunning) {
        
        _sessionRunning = sessionRunning;
        [self.tableView reloadData];
        
    }
    
}

- (NSArray *)accountKeys {
    
    if (!_accountKeys) {

        NSMutableArray *accountKeys = [[self.account.entity.attributesByName allKeys] mutableCopy];
        NSArray *parentKeys = [self.account.entity.superentity.attributesByName allKeys];
        [accountKeys removeObjectsInArray:parentKeys];
        _accountKeys = accountKeys;
        
    }
    
    return _accountKeys;
    
}

- (STSession *)session {
    
    if (!_session) {
        
        _session = [STViewerCore sharedViewerCore].session;

    }
    
    return _session;
    
}

- (STAccount *)account {
    
    if (!_account) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STAccount class])];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"SELF.serverId == %@", [NSNumber numberWithInt:[self.session.uid intValue]]];
        
        NSError *error;
        NSArray *fetchResult = [self.session.document.managedObjectContext executeFetchRequest:request error:&error];
        
        _account = [fetchResult lastObject];

    }
    
    return _account;

}

- (STEntityController *)entityController {
    
    if (!_entityController) {
        
        if (self.sessionRunning) {
            
            _entityController = [[STEntityController alloc] init];
//            _entityController.navigationController = self.navigationController;
            
        }

    }
    
    return _entityController;
    
}

- (STItemContoller *)itemController {
    
    if (!_itemController) {
        
        if (self.sessionRunning) {
            
            _itemController = [[STItemContoller alloc] init];
            
        }
        
    }
    
    return _itemController;
    
}


#pragma mark - view lifecycle

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addNotificationObservers];
    [self waitingDataLoading];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)waitingDataLoading {

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.tag = 1;
    [spinner startAnimating];
    
//    NSLog(@"self.view %@", self.view);
//    NSLog(@"self.tableView %@", self.tableView);
//    NSLog(@"navigationBar %@", self.navigationController.navigationBar);
//    NSLog(@"tabBar %@", self.tabBarController.tabBar);

    CGFloat statusBarHeight = self.navigationController.navigationBar.frame.origin.y;
    CGFloat viewHeight = self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - self.tabBarController.tabBar.frame.size.height - statusBarHeight;
    CGFloat x = (self.view.frame.size.width - spinner.frame.size.width) / 2;
    CGFloat y = (viewHeight - spinner.frame.size.height) / 2;
    CGRect frame = CGRectMake(x, y, spinner.frame.size.width, spinner.frame.size.height);
    spinner.frame = frame;
    [[self.view viewWithTag:1] removeFromSuperview];
    [self.view addSubview:spinner];

}

- (void)sessionStarted {

    [[self.view viewWithTag:1] removeFromSuperview];
    self.sessionRunning = YES;

}

- (void)addNotificationObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStarted) name:@"sessionStarted" object:[STViewerCore sharedViewerCore]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(numberOfEntityDidChange) name:@"numberOfEntityDidChange" object:self.entityController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotAllEntityProperties) name:@"gotAllEntityProperties" object:[STViewerCore sharedViewerCore]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotAllEntityRoles) name:@"gotAllEntityRoles" object:[STViewerCore sharedViewerCore]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectEntity:) name:@"selectEntity" object:self.entityController];

}

- (void)removeNotificationObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sessionStarted" object:[STViewerCore sharedViewerCore]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"numberOfEntityDidChange" object:self.entityController];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"gotAllEntityProperties" object:[STViewerCore sharedViewerCore]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"gotAllEntityRoles" object:[STViewerCore sharedViewerCore]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"selectEntity" object:self.entityController];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectEntity" object:self userInfo:[NSDictionary dictionaryWithObject:entity forKey:@"entity"]];

}

- (void)selectEntity:(NSNotification *)notification {
    
    STEntity *entity = [notification.userInfo valueForKey:@"entity"];
    
    UITableViewController *itemsTVC = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];

    self.itemController.tableView = itemsTVC.tableView;
    itemsTVC.tableView.delegate = self.itemController;
    itemsTVC.tableView.dataSource = self.itemController;
    itemsTVC.title = entity.name;
    self.itemController.itemEntityName = entity.name;

    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [itemsTVC.tableView addGestureRecognizer:swipe];

    [self.navigationController pushViewController:itemsTVC animated:YES];
    
}

- (void)numberOfEntityDidChange {
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
    
}

- (void)gotAllEntityProperties {
    
    [[STViewerCore sharedViewerCore] getEntityRolesPage:1];
    
}

- (void)gotAllEntityRoles {
    
    self.gotAllEntity = YES;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.sessionRunning) {
        
        return 3;
        
    } else {
        
        return 0;
        
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return self.accountKeys.count;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return 1;
            break;
            
        default:
            return 0;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *sectionTitle = nil;
    switch (section) {
        case 0:
            sectionTitle = @"Account:";
            break;
        case 1:
            sectionTitle = @"Roles:";
            break;
        case 2:
            sectionTitle = @"Entities:";
            break;
            
        default:
            break;
    }
    return sectionTitle;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"accountCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellIdentifier];
    
    if (indexPath.section == 0) {
        
        NSString *keySting = self.accountKeys[indexPath.row];
//        NSLog(@"keySting %@", keySting);
        NSString *valueString = [NSString stringWithFormat:@"%@", [self.account valueForKey:keySting]];
//        NSLog(@"valueString %@", valueString);
        
        cell.textLabel.text = keySting;
        cell.detailTextLabel.text = valueString;
        
    } else if (indexPath.section == 1) {
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Number of roles: %d", self.account.roles.count];
        
        if (self.account.roles.count > 0) {
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
        
    } else if (indexPath.section == 2) {
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Number of entities: %d", [self.entityController numberOfEntities]];
        
        if ([self.entityController numberOfEntities] > 0 && self.gotAllEntity) {
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        } else {

            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            CGFloat x = cell.frame.size.width - 22;
            CGFloat y = cell.frame.size.height / 2;
            spinner.center = CGPointMake(x, y);
            [spinner startAnimating];
            cell.accessoryView = spinner;

        }
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            // do nothing
            break;
        case 1:
            
            switch (indexPath.row) {
                case 0:
                    if (self.account.roles.count > 0) {
                        [self showRolesTable];
                    }
                    break;
                    
                default:
                    break;
            }
            
            break;
        case 2:
            
            switch (indexPath.row) {
                case 0:
                    if ([self.entityController numberOfEntities] > 0 && self.gotAllEntity) {
                        [self showEntitiesTable];
                    }
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        default:
            break;
    }
    
}


- (void)showRolesTable {
    
    UITableViewController *rolesTVC = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    self.rolesController.session = self.session;
    rolesTVC.tableView.delegate = self.rolesController;
    rolesTVC.tableView.dataSource = self.rolesController;
    self.rolesController.tableView = rolesTVC.tableView;
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [rolesTVC.tableView addGestureRecognizer:swipe];
    
    [self.navigationController pushViewController:rolesTVC animated:YES];
    
}

- (void)showEntitiesTable {
    
    UITableViewController *entitiesTVC = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    entitiesTVC.tableView.delegate = self.entityController;
    entitiesTVC.tableView.dataSource = self.entityController;
    self.entityController.tableView = entitiesTVC.tableView;
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [entitiesTVC.tableView addGestureRecognizer:swipe];
    
    [self.navigationController pushViewController:entitiesTVC animated:YES];
    
}


- (void)swipe {
    [self.navigationController popViewControllerAnimated:YES];
}

- (STRolesController *)rolesController {
    
    if (!_rolesController) {
        
        _rolesController = [[STRolesController alloc] init];
        
    }
    
    return _rolesController;
    
}

@end
