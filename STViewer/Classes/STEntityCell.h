//
//  STEntityCell.h
//  STViewer
//
//  Created by Maxim Grigoriev on 10/21/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STEntityCell : UITableViewCell

@property (nonatomic, strong) UILabel *propertiesLabel;
@property (nonatomic) NSInteger numberOfLines;

+ (UIFont *)propertiesLabelFont;

@end
