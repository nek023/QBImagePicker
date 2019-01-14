//
//  QBCheckmarkView.m
//  QBImagePicker
//
//  Created by Katsuma Tanaka on 2015/04/03.
//  Copyright (c) 2015 Katsuma Tanaka. All rights reserved.
//

#import "QBCheckmarkView.h"

@implementation QBCheckmarkView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Set default values
    self.borderWidth = 1.0f;
    self.checkmarkLineWidth = 1.2f;
    
    self.borderColor = [UIColor whiteColor];
    self.bodyColor = [UIColor colorWithRed:(20.0f / 255.0f) green:(111.0f / 255.0f) blue:(223.0f / 255.0f) alpha:1.0f];
    self.checkmarkColor = [UIColor whiteColor];
    
    // Set shadow
    self.layer.shadowColor = [[UIColor grayColor] CGColor];
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowOpacity = 0.6f;
    self.layer.shadowRadius = 2.0f;
}

- (void)drawRect:(CGRect)rect
{
    // Border
    [self.borderColor setFill];
    [[UIBezierPath bezierPathWithOvalInRect:self.bounds] fill];
    
    // Body
    [self.bodyColor setFill];
    [[UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.bounds, self.borderWidth, self.borderWidth)] fill];
    
    // Checkmark
    UIBezierPath *checkmarkPath = [UIBezierPath bezierPath];
    checkmarkPath.lineWidth = self.checkmarkLineWidth;
    
    [checkmarkPath moveToPoint:CGPointMake(CGRectGetWidth(self.bounds) * (6.0f / 24.0f), CGRectGetHeight(self.bounds) * (12.0f / 24.0f))];
    [checkmarkPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) * (10.0f / 24.0f), CGRectGetHeight(self.bounds) * (16.0f / 24.0f))];
    [checkmarkPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) * (18.0f / 24.0f), CGRectGetHeight(self.bounds) * (8.0f / 24.0f))];
    
    [self.checkmarkColor setStroke];
    [checkmarkPath stroke];
}

@end
