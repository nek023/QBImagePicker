//
//  QBAssetsCollectionCameraView.m
//  QBImagePickerControllerDemo
//
//  Created by Dan Marinescu on 23/04/14.
//  Copyright (c) 2014 Katsuma Tanaka. All rights reserved.
//

#import "QBAssetsCollectionCameraView.h"

@implementation QBAssetsCollectionCameraView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    //setup with color
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *lightGrayColor = [UIColor colorWithWhite:0.846 alpha:1.000];
    CGContextSetFillColorWithColor(context, lightGrayColor.CGColor);
    CGContextSetStrokeColorWithColor(context, lightGrayColor.CGColor);
    
    //rectangle part of the camera
    CGRect bodyRect = CGRectMake(0, 0, 8.0, self.bounds.size.height);
    CGContextFillRect(context, bodyRect);
    
    //triangle part of the camera (i.e. the lens)
    CGContextMoveToPoint(context, 8.0, 3.0);
    CGContextAddLineToPoint(context, 12.0, 0.0);
    CGContextAddLineToPoint(context, 12.0, 6.0);
    CGContextAddLineToPoint(context, 8.0, 3.0);
    CGContextFillPath(context);
}


@end
