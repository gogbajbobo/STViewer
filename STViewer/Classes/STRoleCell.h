//
//  STRoleCell.h
//  STViewer
//
//  Created by Maxim Grigoriev on 10/17/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STRoleCell : UITableViewCell

@property (nonatomic, strong) UILabel *dataLabel;

+ (UIFont *)dataLabelFont;

@end
