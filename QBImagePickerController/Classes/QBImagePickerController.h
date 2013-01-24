//
//  QBImagePickerController.h
//  QBImagePickerController
//
//  Created by Katsuma Tanaka on 2013/01/21.
//  Copyright (c) 2013年 Katsuma Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

// Delegate
#import "QBAssetCollectionViewControllerDelegate.h"

typedef enum {
    QBImagePickerFilterTypeAllAssets,
    QBImagePickerFilterTypeAllPhotos,
    QBImagePickerFilterTypeAllVideos
} QBImagePickerFilterType;

@class QBImagePickerController;

@protocol QBImagePickerControllerDelegate <NSObject>

@optional
- (void)imagePickerControllerWillFinishPickingMedia:(QBImagePickerController *)imagePickerController;
- (void)imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(id)info;
- (void)imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController;
- (NSString *)descriptionForSelectingAllAssets:(QBImagePickerController *)imagePickerController;
- (NSString *)descriptionForDeselectingAllAssets:(QBImagePickerController *)imagePickerController;
- (NSString *)imagePickerController:(QBImagePickerController *)imagePickerController descriptionForNumberOfPhotos:(NSUInteger)numberOfPhotos numberOfVideos:(NSUInteger)numberOfVideos;

@end

@interface QBImagePickerController : UIViewController <UITableViewDataSource, UITableViewDelegate, QBAssetCollectionViewControllerDelegate>

@property (nonatomic, assign) id<QBImagePickerControllerDelegate> delegate;
@property (nonatomic, assign) QBImagePickerFilterType filterType;
@property (nonatomic, assign) BOOL showsCancelButton;
@property (nonatomic, assign) BOOL fullScreenLayoutEnabled;

@property (nonatomic, assign) BOOL allowsMultipleSelection;
@property (nonatomic, assign) BOOL limitMinimumNumberOfSelection;
@property (nonatomic, assign) BOOL limitMaximumNumberOfSelection;
@property (nonatomic, assign) NSUInteger minimumNumberOfSelection;
@property (nonatomic, assign) NSUInteger maximumNumberOfSelection;

@end
