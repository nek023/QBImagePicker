//
//  QBAssetCell.m
//  QBImagePicker
//
//  Created by Katsuma Tanaka on 2015/04/03.
//  Copyright (c) 2015 Katsuma Tanaka. All rights reserved.
//

#import "QBAssetCell.h"
#import "QBCheckmarkView.h"

@interface QBAssetCell ()

@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet QBCheckmarkView *checkmarkView;

@end

@implementation QBAssetCell

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    // Show/hide overlay view
    self.overlayView.hidden = !(selected && self.showsOverlayViewWhenSelected);
}

-(void)setCheckmarkColor:(UIColor *)checkmarkColor
{
    _checkmarkColor = checkmarkColor;
    self.checkmarkView.bodyColor = checkmarkColor;
}

@end
