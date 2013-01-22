//
//  QBImagePickerAssetView.h
//  QBImagePickerController
//
//  Created by Katsuma Tanaka on 2013/01/21.
//  Copyright (c) 2013年 Katsuma Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

// Delegate
#import "QBImagePickerAssetViewDelegate.h"

@interface QBImagePickerAssetView : UIView

@property (nonatomic, assign) id<QBImagePickerAssetViewDelegate> delegate;
@property (nonatomic, retain) ALAsset *asset;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL allowsMultipleSelection;

@end
