//
//  QBImagePickerController.h
//  QBImagePickerController
//
//  Created by Tanaka Katsuma on 2013/12/30.
//  Copyright (c) 2013年 Katsuma Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef NS_ENUM(NSUInteger, QBImagePickerControllerFilterType) {
    QBImagePickerControllerFilterTypeNone,
    QBImagePickerControllerFilterTypePhotos,
    QBImagePickerControllerFilterTypeVideos
};

UIKIT_EXTERN ALAssetsFilter * ALAssetsFilterFromQBImagePickerControllerFilterType(QBImagePickerControllerFilterType type);

@class QBImagePickerController;

@protocol QBImagePickerControllerDelegate <NSObject>

@optional
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets;
- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController;

- (BOOL)qb_imagePickerController:(QBImagePickerController *)imagePickerController shouldSelectAsset:(ALAsset *)asset;
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset;
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didDeselectAsset:(ALAsset *)asset;

@end

@interface QBImagePickerController : UIViewController

@property (nonatomic, copy, readonly) NSArray *assetsGroups;
@property (nonatomic, strong, readonly) NSMutableOrderedSet *selectedAssetURLs;

@property (nonatomic, weak) id<QBImagePickerControllerDelegate> delegate;

@property (nonatomic, copy) NSArray *groupTypes;
@property (nonatomic, assign) QBImagePickerControllerFilterType filterType;

@property (nonatomic, assign) BOOL allowsMultipleSelection;
@property (nonatomic, assign) NSUInteger minimumNumberOfSelection;
@property (nonatomic, assign) NSUInteger maximumNumberOfSelection;

@property (nonatomic, copy) NSString *prompt;
@property (nonatomic, assign) BOOL showsNumberOfSelectedAssets;

@property (nonatomic, assign) NSUInteger numberOfColumnsInPortrait;
@property (nonatomic, assign) NSUInteger numberOfColumnsInLandscape;

@end
