//
//  QBImagePickerController.h
//  QBImagePicker
//
//  Created by Katsuma Tanaka on 2015/04/03.
//  Copyright (c) 2015 Katsuma Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@class QBImagePickerController;

@protocol QBImagePickerControllerDelegate <NSObject>

@optional
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets;
- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController;

- (BOOL)qb_imagePickerController:(QBImagePickerController *)imagePickerController shouldSelectAsset:(id)asset;
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAsset:(id)asset;
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didDeselectAsset:(id)asset;

@end

typedef NS_ENUM(NSUInteger, QBImagePickerMediaType) {
    QBImagePickerMediaTypeAny = 0,
    QBImagePickerMediaTypeImage,
    QBImagePickerMediaTypeVideo
};

typedef NS_ENUM(NSUInteger, QBImagePickerCollectionSubtype) {
    
    QBImagePickerCollectionSubtypeAll,
    QBImagePickerCollectionSubtypeLibrary,
    QBImagePickerCollectionSubtypeAlbum,
    QBImagePickerCollectionSubtypeStream,
    QBImagePickerCollectionSubtypePanoramas,
    QBImagePickerCollectionSubtypeVideos,
    QBImagePickerCollectionSubtypeBursts,

};

@interface QBImagePickerController : UIViewController

+ (BOOL) usingPhotosLibrary;

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@property (nonatomic, weak) id<QBImagePickerControllerDelegate> delegate;

@property (nonatomic, strong, readonly) NSMutableOrderedSet *selectedAssets;

@property (nonatomic, copy) NSArray *collectionSubtypes;
@property (nonatomic, assign) QBImagePickerMediaType mediaType;

@property (nonatomic, assign) BOOL allowsMultipleSelection;
@property (nonatomic, assign) NSUInteger minimumNumberOfSelection;
@property (nonatomic, assign) NSUInteger maximumNumberOfSelection;

@property (nonatomic, copy) NSString *prompt;
@property (nonatomic, assign) BOOL showsNumberOfSelectedAssets;

@property (nonatomic, assign) NSUInteger numberOfColumnsInPortrait;
@property (nonatomic, assign) NSUInteger numberOfColumnsInLandscape;

@end
