//
//  QBImagePickerThumbnailView.m
//  QBImagePickerController
//
//  Created by Tanaka Katsuma on 2013/12/31.
//  Copyright (c) 2013年 Katsuma Tanaka. All rights reserved.
//

#import "QBImagePickerThumbnailView.h"

@interface QBImagePickerThumbnailView ()

@property (nonatomic, copy) NSArray *thumbnailImages;
@property (nonatomic, strong, readonly) UIImage *blankImage;
@end

@implementation QBImagePickerThumbnailView

@synthesize blankImage = _blankImage;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(70.0, 74.0);
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    
    if (self.thumbnailImages.count == 3) {
        UIImage *thumbnailImage = [self.thumbnailImages objectAtIndex:2];
        
        CGRect thumbnailImageRect = CGRectMake(4.0, 0, 62.0, 62.0);
        CGContextFillRect(context, thumbnailImageRect);
        [thumbnailImage drawInRect:CGRectInset(thumbnailImageRect, 0.5, 0.5)];
    }
    
    if (self.thumbnailImages.count >= 2) {
        UIImage *thumbnailImage = [self.thumbnailImages objectAtIndex:1];
        
        CGRect thumbnailImageRect = CGRectMake(2.0, 2.0, 66.0, 66.0);
        CGContextFillRect(context, thumbnailImageRect);
        [thumbnailImage drawInRect:CGRectInset(thumbnailImageRect, 0.5, 0.5)];
    }
    
    UIImage *thumbnailImage = [self.thumbnailImages objectAtIndex:0];
    
    CGRect thumbnailImageRect = CGRectMake(0, 4.0, 70.0, 70.0);
    CGContextFillRect(context, thumbnailImageRect);
    [thumbnailImage drawInRect:CGRectInset(thumbnailImageRect, 0.5, 0.5)];
}


#pragma mark - Accessors

- (void)setAssetsGroup:(ALAssetsGroup *)assetsGroup
{
    _assetsGroup = assetsGroup;
    
    // Extract three thumbnail images
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, MIN(3, assetsGroup.numberOfAssets))];
    NSMutableArray *thumbnailImages = [NSMutableArray array];
    [assetsGroup enumerateAssetsAtIndexes:indexes
                                  options:0
                               usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                   if (result) {
                                       UIImage *thumbnailImage = [UIImage imageWithCGImage:[result thumbnail]];
                                       [thumbnailImages addObject:thumbnailImage ? : self.blankImage];
                                   }
                               }];
    self.thumbnailImages = thumbnailImages;
}

- (UIImage *)blankImage
{
    if (!_blankImage) {
        CGSize size = CGSizeMake(200, 200);
        UIGraphicsBeginImageContextWithOptions(size, YES, 0);
        [[UIColor colorWithRed:(240.f / 255.f) green:(240.f / 255.f) blue:(240.f / 255.f) alpha:1.f] setFill];
        UIRectFill(CGRectMake(0, 0, size.width, size.height));
        _blankImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return _blankImage;
}

@end
