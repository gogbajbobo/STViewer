//
//  STEntityCell.m
//  STViewer
//
//  Created by Maxim Grigoriev on 10/21/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STEntityCell.h"

@implementation STEntityCell

+ (UIFont *)propertiesLabelFont {
    return [UIFont boldSystemFontOfSize:13];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.propertiesLabel.font = [[self class] propertiesLabelFont];
    self.propertiesLabel.textAlignment = NSTextAlignmentLeft;
    self.propertiesLabel.backgroundColor = [UIColor clearColor];
    
    CGFloat labelPaddingX = 0;
    CGFloat labelPaddingY = 0;
    
    NSArray *stringComponents = [self.propertiesLabel.text componentsSeparatedByString:@"\r\n"];
    CGFloat width = 0;
    for (NSString *string in stringComponents) {
        
        CGFloat stringWidth = [string sizeWithFont:self.propertiesLabel.font].width;
        if (stringWidth > width) {
            width = stringWidth;
        }
        
    }
    
    CGSize propertiesLabelSize = [self.propertiesLabel.text sizeWithFont:self.propertiesLabel.font];
    CGFloat height = propertiesLabelSize.height * self.numberOfLines;
    CGSize textLabelSize = [self.textLabel.text sizeWithFont:self.textLabel.font];
    
//    NSLog(@"propertiesLabel.text %@", self.propertiesLabel.text);
//    NSLog(@"propertiesLabelSize.height %f", propertiesLabelSize.height);
    
    CGFloat framePaddingY = 11;
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height + textLabelSize.height + framePaddingY * 2);
    
    CGFloat x = self.textLabel.frame.origin.x;
    CGFloat y = framePaddingY;
//    CGRect frame = CGRectMake(x, y, textLabelSize.width + 2 * labelPaddingX, textLabelSize.height + 2 * labelPaddingY);
    CGRect frame = CGRectMake(x, y, self.textLabel.frame.size.width, textLabelSize.height);
    self.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.textLabel.frame = frame;
    
    x = self.textLabel.frame.origin.x + 22;
    y = self.textLabel.frame.origin.y + self.textLabel.frame.size.height;
    frame = CGRectMake(x, y, width + 2 * labelPaddingX, height + 2 * labelPaddingY);
    self.propertiesLabel.frame = frame;
    
    //    NSLog(@"self %@", self);
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.propertiesLabel = [[UILabel alloc] init];
//        self.propertiesLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.propertiesLabel.numberOfLines = self.numberOfLines;
        [self.contentView addSubview:self.propertiesLabel];
        
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
