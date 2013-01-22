//
//  QBImagePickerFooterCell.m
//  QBImagePickerController
//
//  Created by questbeat on 2013/01/21.
//  Copyright (c) 2013年 Katsuma Tanaka. All rights reserved.
//

#import "QBImagePickerFooterCell.h"

@implementation QBImagePickerFooterCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        /* Initialization */
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        titleLabel.font = [UIFont systemFontOfSize:20];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor colorWithRed:0.502 green:0.533 blue:0.58 alpha:1.0];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        [titleLabel release];
    }
    
    return self;
}

- (void)dealloc
{
    [_titleLabel release];
    
    [super dealloc];
}

@end
