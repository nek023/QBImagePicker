//
//  QBAssetCollectionViewController.h
//  QBImagePickerController
//
//  Created by questbeat on 2013/01/21.
//  Copyright (c) 2013年 Katsuma Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>

// Delegate
#import "QBAssetCollectionViewControllerDelegate.h"
#import "QBImagePickerAssetCellDelegate.h"

// Controllers
#import "QBImagePickerController.h"

@interface QBAssetCollectionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, QBImagePickerAssetCellDelegate>

@property (nonatomic, assign) id<QBAssetCollectionViewControllerDelegate> delegate;
@property (nonatomic, retain) ALAssetsGroup *assetsGroup;

@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) QBImagePickerFilterType filterType;
@property (nonatomic, assign) BOOL showsCancelButton;
@property (nonatomic, assign) BOOL fullScreenLayoutEnabled;

@property (nonatomic, assign) BOOL allowsMultipleSelection;
@property (nonatomic, assign) BOOL limitMinimumNumberOfSelection;
@property (nonatomic, assign) BOOL limitMaximumNumberOfSelection;
@property (nonatomic, assign) NSUInteger minimumNumberOfSelection;
@property (nonatomic, assign) NSUInteger maximumNumberOfSelection;

@end
