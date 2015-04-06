//
//  QBAssetsViewController.m
//  QBImagePicker
//
//  Created by Katsuma Tanaka on 2015/04/06.
//  Copyright (c) 2015 Katsuma Tanaka. All rights reserved.
//

#import "QBAssetsViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

// Views
#import "QBAssetCell.h"
#import "QBVideoIndicatorView.h"

// ViewControllers
#import "QBImagePickerController.h"

@interface QBImagePickerController (Private)

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSBundle *assetBundle;

@end

@interface QBAssetsViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic, copy) NSArray *assets;
@property (nonatomic, assign) NSUInteger numberOfAssets;
@property (nonatomic, assign) NSUInteger numberOfPhotos;
@property (nonatomic, assign) NSUInteger numberOfVideos;

@property (nonatomic, assign) BOOL disableScrollToBottom;
@property (nonatomic, strong) NSIndexPath *indexPathForLastVisibleItem;
@property (nonatomic, strong) NSIndexPath *lastSelectedItemIndexPath;

@end

@implementation QBAssetsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpToolbarItems];
    
    // Register observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(assetsLibraryChanged:)
                                                 name:ALAssetsLibraryChangedNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Configure navigation item
    self.navigationItem.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    self.navigationItem.prompt = self.imagePickerController.prompt;
    
    // Configure collection view
    self.collectionView.allowsMultipleSelection = self.imagePickerController.allowsMultipleSelection;
    
    // Show/hide 'Done' button
    if (self.imagePickerController.allowsMultipleSelection) {
        [self.navigationItem setRightBarButtonItem:self.doneButton animated:NO];
    } else {
        [self.navigationItem setRightBarButtonItem:nil animated:NO];
    }
    
    [self updateDoneButtonState];
    [self updateSelectionInfo];
    
    // Scroll to bottom
    if (self.numberOfAssets > 0 && self.isMovingToParentViewController && !self.disableScrollToBottom) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(self.numberOfAssets - 1) inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.disableScrollToBottom = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.disableScrollToBottom = NO;
}

- (void)dealloc
{
    // Remove observer
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ALAssetsLibraryChangedNotification
                                                  object:nil];
}


#pragma mark - Accessors

- (void)setAssetsGroup:(ALAssetsGroup *)assetsGroup
{
    _assetsGroup = assetsGroup;
    
    [self updateAssets];
    
    if ([self isAutoDeselectEnabled] && self.imagePickerController.selectedAssetURLs.count > 0) {
        // Get index of previous selected asset
        NSURL *previousSelectedAssetURL = [self.imagePickerController.selectedAssetURLs firstObject];
        
        [self.assets enumerateObjectsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
            NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
            
            if ([assetURL isEqual:previousSelectedAssetURL]) {
                self.lastSelectedItemIndexPath = [NSIndexPath indexPathForItem:index inSection:0];
                *stop = YES;
            }
        }];
    }
    
    [self.collectionView reloadData];
}

- (BOOL)isAutoDeselectEnabled
{
    return (self.imagePickerController.maximumNumberOfSelection == 1
            && self.imagePickerController.maximumNumberOfSelection >= self.imagePickerController.minimumNumberOfSelection);
}


#pragma mark - Handling Device Rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // Save indexPath for the last item
    self.indexPathForLastVisibleItem = [[self.collectionView indexPathsForVisibleItems] lastObject];
    
    // Update layout
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // Restore scroll position
    [self.collectionView scrollToItemAtIndexPath:self.indexPathForLastVisibleItem atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    // Save indexPath for the last item
    NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] lastObject];
    
    // Update layout
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    // Restore scroll position
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }];
}


#pragma mark - Handling Assets Library Changes

- (void)assetsLibraryChanged:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSSet *updatedAssetsGroups = notification.userInfo[ALAssetLibraryUpdatedAssetGroupsKey];
        NSURL *assetsGroupURL = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyURL];
        
        for (NSURL *updatedAssetsGroupURL in updatedAssetsGroups) {
            if ([updatedAssetsGroupURL isEqual:assetsGroupURL]) {
                [self updateAssets];
                [self.collectionView reloadData];
            }
        }
    });
}


#pragma mark - Actions

- (IBAction)done:(id)sender
{
    if ([self.imagePickerController.delegate respondsToSelector:@selector(qb_imagePickerController:didSelectAssets:)]) {
        [self fetchAssetsFromSelectedAssetURLsWithCompletion:^(NSArray *assets) {
            [self.imagePickerController.delegate qb_imagePickerController:self.imagePickerController didSelectAssets:assets];
        }];
    }
}


#pragma mark - Toolbar

- (void)setUpToolbarItems
{
    // Space
    UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    UIBarButtonItem *rightSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    
    // Info label
    NSDictionary *attributes = @{ NSForegroundColorAttributeName: [UIColor blackColor] };
    UIBarButtonItem *infoButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
    infoButtonItem.enabled = NO;
    [infoButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [infoButtonItem setTitleTextAttributes:attributes forState:UIControlStateDisabled];
    
    self.toolbarItems = @[leftSpace, infoButtonItem, rightSpace];
}

- (void)updateSelectionInfo
{
    NSMutableOrderedSet *selectedAssetURLs = self.imagePickerController.selectedAssetURLs;
    
    if (selectedAssetURLs.count > 0) {
        NSBundle *bundle = self.imagePickerController.assetBundle;
        NSString *format;
        if (selectedAssetURLs.count > 1) {
            format = NSLocalizedStringFromTableInBundle(@"items_selected", @"QBImagePicker", bundle, nil);
        } else {
            format = NSLocalizedStringFromTableInBundle(@"item_selected", @"QBImagePicker", bundle, nil);
        }
        
        NSString *title = [NSString stringWithFormat:format, selectedAssetURLs.count];
        [(UIBarButtonItem *)self.toolbarItems[1] setTitle:title];
    } else {
        [(UIBarButtonItem *)self.toolbarItems[1] setTitle:@""];
    }
}


#pragma mark - Fetching Assets

- (void)updateAssets
{
    NSMutableArray *assets = [NSMutableArray array];
    __block NSUInteger numberOfAssets = 0;
    __block NSUInteger numberOfPhotos = 0;
    __block NSUInteger numberOfVideos = 0;
    
    [self.assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            numberOfAssets++;
            
            NSString *type = [result valueForProperty:ALAssetPropertyType];
            if ([type isEqualToString:ALAssetTypePhoto]) numberOfPhotos++;
            else if ([type isEqualToString:ALAssetTypeVideo]) numberOfVideos++;
            
            [assets addObject:result];
        }
    }];
    
    self.assets = assets;
    self.numberOfAssets = numberOfAssets;
    self.numberOfPhotos = numberOfPhotos;
    self.numberOfVideos = numberOfVideos;
}

- (void)fetchAssetsFromSelectedAssetURLsWithCompletion:(void (^)(NSArray *assets))completion
{
    // Load assets from URLs
    // The asset will be ignored if it is not found
    ALAssetsLibrary *assetsLibrary = self.imagePickerController.assetsLibrary;
    NSMutableOrderedSet *selectedAssetURLs = self.imagePickerController.selectedAssetURLs;
    
    __block NSMutableArray *assets = [NSMutableArray array];
    
    void (^checkNumberOfAssets)(void) = ^{
        if (assets.count == selectedAssetURLs.count) {
            if (completion) {
                completion([assets copy]);
            }
        }
    };
    
    for (NSURL *assetURL in selectedAssetURLs) {
        [assetsLibrary assetForURL:assetURL
                       resultBlock:^(ALAsset *asset) {
                           if (asset) {
                               // Add asset
                               [assets addObject:asset];
                               
                               // Check if the loading finished
                               checkNumberOfAssets();
                           } else {
                               [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                   [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                       if ([result.defaultRepresentation.url isEqual:assetURL]) {
                                           // Add asset
                                           [assets addObject:result];
                                           
                                           // Check if the loading finished
                                           checkNumberOfAssets();
                                           
                                           *stop = YES;
                                       }
                                   }];
                               } failureBlock:^(NSError *error) {
                                   NSLog(@"Error: %@", [error localizedDescription]);
                               }];
                           }
                       } failureBlock:^(NSError *error) {
                           NSLog(@"Error: %@", [error localizedDescription]);
                       }];
    }
}


#pragma mark - Checking for Selection Limit

- (BOOL)isMinimumSelectionLimitFulfilled
{
   return (self.imagePickerController.minimumNumberOfSelection <= self.imagePickerController.selectedAssetURLs.count);
}

- (BOOL)isMaximumSelectionLimitReached
{
    NSUInteger minimumNumberOfSelection = MAX(1, self.imagePickerController.minimumNumberOfSelection);
   
    if (minimumNumberOfSelection <= self.imagePickerController.maximumNumberOfSelection) {
        return (self.imagePickerController.maximumNumberOfSelection <= self.imagePickerController.selectedAssetURLs.count);
    }
   
    return NO;
}

- (void)updateDoneButtonState
{
    self.doneButton.enabled = [self isMinimumSelectionLimitFulfilled];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.numberOfAssets;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QBAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AssetCell" forIndexPath:indexPath];
    cell.tag = indexPath.item;
    cell.showsOverlayViewWhenSelected = self.imagePickerController.allowsMultipleSelection;
    
    // Image
    ALAsset *asset = self.assets[indexPath.item];
    UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
    cell.imageView.image = image;
    
    // Video indicator
    NSString *assetType = [asset valueForProperty:ALAssetPropertyType];
    
    if ([assetType isEqualToString:ALAssetTypeVideo]) {
        cell.videoIndicatorView.hidden = NO;
        
        NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
        NSInteger minutes = (NSInteger)(duration / 60.0);
        NSInteger seconds = (NSInteger)ceil(duration - 60.0 * (double)minutes);
        cell.videoIndicatorView.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    } else {
        cell.videoIndicatorView.hidden = YES;
    }
    
    // Selection state
    NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
    
    if ([self.imagePickerController.selectedAssetURLs containsObject:assetURL]) {
        [cell setSelected:YES];
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                  withReuseIdentifier:@"FooterView"
                                                                                         forIndexPath:indexPath];
        
        // Number of assets
        UILabel *label = (UILabel *)[footerView viewWithTag:1];
        NSBundle *bundle = self.imagePickerController.assetBundle;
        NSUInteger numberOfPhotos = self.numberOfPhotos;
        NSUInteger numberOfVideos = self.numberOfVideos;
        
        switch (self.imagePickerController.filterType) {
            case QBImagePickerControllerFilterTypeNone:
            {
                NSString *format;
                if (numberOfPhotos == 1) {
                    if (numberOfVideos == 1) {
                        format = NSLocalizedStringFromTableInBundle(@"format_photo_and_video", @"QBImagePicker", bundle, nil);
                    } else {
                        format = NSLocalizedStringFromTableInBundle(@"format_photo_and_videos", @"QBImagePicker", bundle, nil);
                    }
                } else if (numberOfVideos == 1) {
                    format = NSLocalizedStringFromTableInBundle(@"format_photos_and_video", @"QBImagePicker", bundle, nil);
                } else {
                    format = NSLocalizedStringFromTableInBundle(@"format_photos_and_videos", @"QBImagePicker", bundle, nil);
                }
                
                label.text = [NSString stringWithFormat:format, numberOfPhotos, numberOfVideos];
            }
                break;
                
            case QBImagePickerControllerFilterTypePhotos:
            {
                NSString *key = (numberOfPhotos == 1) ? @"format_photo" : @"format_photos";
                NSString *format = NSLocalizedStringFromTableInBundle(key, @"QBImagePicker", bundle, nil);
                
                label.text = [NSString stringWithFormat:format, numberOfPhotos];
            }
                break;
                
            case QBImagePickerControllerFilterTypeVideos:
            {
                NSString *key = (numberOfVideos == 1) ? @"format_video" : @"format_videos";
                NSString *format = NSLocalizedStringFromTableInBundle(key, @"QBImagePicker", bundle, nil);
                
                label.text = [NSString stringWithFormat:format, numberOfVideos];
            }
                break;
        }
        
        return footerView;
    }
    
    return nil;
}


#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.imagePickerController.delegate respondsToSelector:@selector(qb_imagePickerController:shouldSelectAsset:)]) {
        ALAsset *asset = self.assets[indexPath.item];
        return [self.imagePickerController.delegate qb_imagePickerController:self.imagePickerController shouldSelectAsset:asset];
    }
    
    if ([self isAutoDeselectEnabled]) {
        return YES;
    }
    
    return ![self isMaximumSelectionLimitReached];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    QBImagePickerController *imagePickerController = self.imagePickerController;
    NSMutableOrderedSet *selectedAssetURLs = imagePickerController.selectedAssetURLs;
    
    ALAsset *asset = self.assets[indexPath.item];
    NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
    
    if (imagePickerController.allowsMultipleSelection) {
        if ([self isAutoDeselectEnabled] && selectedAssetURLs.count > 0) {
            // Remove previous selected asset from set
            [imagePickerController willChangeValueForKey:@"selectedAssetURLs"];
            [selectedAssetURLs removeObjectAtIndex:0];
            [imagePickerController didChangeValueForKey:@"selectedAssetURLs"];
            
            // Deselect previous selected asset
            if (self.lastSelectedItemIndexPath) {
                [collectionView deselectItemAtIndexPath:self.lastSelectedItemIndexPath animated:NO];
            }
        }
        
        // Add asset to set
        [imagePickerController willChangeValueForKey:@"selectedAssetURLs"];
        [selectedAssetURLs addObject:assetURL];
        [imagePickerController didChangeValueForKey:@"selectedAssetURLs"];
        
        self.lastSelectedItemIndexPath = indexPath;
        
        [self updateDoneButtonState];
        
        if (imagePickerController.showsNumberOfSelectedAssets) {
            [self updateSelectionInfo];
            
            if (selectedAssetURLs.count == 1) {
                // Show toolbar
                [self.navigationController setToolbarHidden:NO animated:YES];
            }
        }
    } else {
        if ([imagePickerController.delegate respondsToSelector:@selector(qb_imagePickerController:didSelectAsset:)]) {
            [imagePickerController.delegate qb_imagePickerController:imagePickerController didSelectAsset:asset];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.imagePickerController.allowsMultipleSelection) {
        return;
    }
    
    QBImagePickerController *imagePickerController = self.imagePickerController;
    NSMutableOrderedSet *selectedAssetURLs = imagePickerController.selectedAssetURLs;
    
    // Remove asset from set
    ALAsset *asset = self.assets[indexPath.item];
    NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
    
    [imagePickerController willChangeValueForKey:@"selectedAssetURLs"];
    [selectedAssetURLs removeObject:assetURL];
    [imagePickerController didChangeValueForKey:@"selectedAssetURLs"];
    
    self.lastSelectedItemIndexPath = nil;
    
    [self updateDoneButtonState];
    
    if (imagePickerController.showsNumberOfSelectedAssets) {
        [self updateSelectionInfo];
        
        if (selectedAssetURLs.count == 0) {
            // Hide toolbar
            [self.navigationController setToolbarHidden:YES animated:YES];
        }
    }
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger numberOfColumns;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        numberOfColumns = self.imagePickerController.numberOfColumnsInPortrait;
    } else {
        numberOfColumns = self.imagePickerController.numberOfColumnsInLandscape;
    }
    
    CGFloat width = (CGRectGetWidth(self.view.frame) - 2.0 * (numberOfColumns + 1)) / numberOfColumns;
    
    return CGSizeMake(width, width);
}

@end
