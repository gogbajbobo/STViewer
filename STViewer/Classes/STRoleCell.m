//
//  STRoleCell.m
//  STViewer
//
//  Created by Maxim Grigoriev on 10/17/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STRoleCell.h"

@implementation STRoleCell

+ (UIFont *)dataLabelFont {
    return [UIFont boldSystemFontOfSize:13];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.dataLabel.font = [[self class] dataLabelFont];
    self.dataLabel.textAlignment = NSTextAlignmentRight;
    self.dataLabel.backgroundColor = [UIColor clearColor];

    CGFloat labelPaddingX = 0;
    CGFloat labelPaddingY = 0;
    CGSize dataLabelSize = [self.dataLabel.text sizeWithFont:self.dataLabel.font];
    CGSize textLabelSize = [self.textLabel.text sizeWithFont:self.textLabel.font];
        
    CGFloat framePaddingY = 11;
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, dataLabelSize.height + textLabelSize.height + framePaddingY * 2);

    CGFloat x = self.textLabel.frame.origin.x;
    CGFloat y = framePaddingY;
    CGRect frame = CGRectMake(x, y, textLabelSize.width + 2 * labelPaddingX, textLabelSize.height + 2 * labelPaddingY);
    self.textLabel.frame = frame;

    x = self.textLabel.frame.origin.x + 22;
    y = self.textLabel.frame.origin.y + self.textLabel.frame.size.height;
    frame = CGRectMake(x, y, dataLabelSize.width + 2 * labelPaddingX, dataLabelSize.height + 2 * labelPaddingY);
    self.dataLabel.frame = frame;

//    NSLog(@"self %@", self);
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.dataLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.dataLabel];
        
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
