//
//  QBAssetCollectionViewControllerDelegate.h
//  QBImagePickerController
//
//  Created by questbeat on 2013/01/21.
//  Copyright (c) 2013年 Katsuma Tanaka. All rights reserved.
//

@class QBAssetCollectionViewController;

@protocol QBAssetCollectionViewControllerDelegate <NSObject>

@required
- (void)assetCollectionViewController:(QBAssetCollectionViewController *)assetCollectionViewController didFinishPickingAsset:(ALAsset *)asset;
- (void)assetCollectionViewController:(QBAssetCollectionViewController *)assetCollectionViewController didFinishPickingAssets:(NSArray *)assets;
- (void)assetCollectionViewControllerDidCancel:(QBAssetCollectionViewController *)assetCollectionViewController;

@optional
- (NSString *)assetCollectionViewController:(QBAssetCollectionViewController *)assetCollectionViewController descriptionForNumberOfPhotos:(NSUInteger)numberOfPhotos numberOfVideos:(NSUInteger)numberOfVideos;

@end
