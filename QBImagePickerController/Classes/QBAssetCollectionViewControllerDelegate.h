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
- (NSString *)descriptionForSelectingAllAssets:(QBAssetCollectionViewController *)assetCollectionViewController;
- (NSString *)descriptionForDeselectingAllAssets:(QBAssetCollectionViewController *)assetCollectionViewController;
- (NSString *)assetCollectionViewController:(QBAssetCollectionViewController *)assetCollectionViewController descriptionForNumberOfPhotos:(NSUInteger)numberOfPhotos numberOfVideos:(NSUInteger)numberOfVideos;

@end
