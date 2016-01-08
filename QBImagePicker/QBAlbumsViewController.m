//
//  QBAlbumsViewController.m
//  QBImagePicker
//
//  Created by Katsuma Tanaka on 2015/04/03.
//  Copyright (c) 2015 Katsuma Tanaka. All rights reserved.
//

#import "QBAlbumsViewController.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

// Views
#import "QBAlbumCell.h"

// ViewControllers
#import "QBImagePickerController.h"
#import "QBAssetsViewController.h"

static CGSize CGSizeScale(CGSize size, CGFloat scale) {
    return CGSizeMake(size.width * scale, size.height * scale);
}

@interface QBImagePickerController (Private)

@property (nonatomic, strong) NSBundle *assetBundle;

@end

@interface QBAlbumsViewController () <PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic, copy) NSArray *fetchResults;
@property (nonatomic, copy) NSArray *assetCollections;

@property (nonatomic, copy) NSArray *assetsGroups;

@end

@implementation QBAlbumsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpToolbarItems];
    
    if ([QBImagePickerController usingPhotosLibrary]) {
        
        // Fetch user albums and smart albums
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
        PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
        self.fetchResults = @[smartAlbums, userAlbums];
        
        [self updateAssetCollections];
        
        // Register observer
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        
    }
    else {
        
        [self updateAssetsGroupsWithCompletion:^{
            [self.tableView reloadData];
        }];
        
        
        // Register observer
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(assetsLibraryChanged:)
                                                     name:ALAssetsLibraryChangedNotification
                                                   object:nil];
    }
    
}

- (void)assetsLibraryChanged:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateAssetsGroupsWithCompletion:^{
            [self.tableView reloadData];
        }];
    });
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Configure navigation item
    self.navigationItem.title = NSLocalizedStringFromTableInBundle(@"albums.title", @"QBImagePicker", self.imagePickerController.assetBundle, nil);
    self.navigationItem.prompt = self.imagePickerController.prompt;
    
    // Show/hide 'Done' button
    if (self.imagePickerController.allowsMultipleSelection) {
        [self.navigationItem setRightBarButtonItem:self.doneButton animated:NO];
    } else {
        [self.navigationItem setRightBarButtonItem:nil animated:NO];
    }
    
    [self updateControlState];
    [self updateSelectionInfo];
}

- (void)dealloc
{
    if ([QBImagePickerController usingPhotosLibrary]) {

        // Deregister observer
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    }
    else {

        // Remove observer
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:ALAssetsLibraryChangedNotification
                                                      object:nil];
    }
}


#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    QBAssetsViewController *assetsViewController = segue.destinationViewController;
    assetsViewController.imagePickerController = self.imagePickerController;
    
    if ([QBImagePickerController usingPhotosLibrary]) {

        assetsViewController.assetCollection = self.assetCollections[self.tableView.indexPathForSelectedRow.row];
    }
    else {
        
        assetsViewController.assetsGroup = self.assetsGroups[self.tableView.indexPathForSelectedRow.row];
    }
}


#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
    if ([self.imagePickerController.delegate respondsToSelector:@selector(qb_imagePickerControllerDidCancel:)]) {
        [self.imagePickerController.delegate qb_imagePickerControllerDidCancel:self.imagePickerController];
    }
}


- (IBAction)done:(id)sender
{
    if ([self.imagePickerController.delegate respondsToSelector:@selector(qb_imagePickerController:didFinishPickingAssets:)]) {
        
        if ([QBImagePickerController usingPhotosLibrary]) {
            
            [self.imagePickerController.delegate qb_imagePickerController:self.imagePickerController
                                                   didFinishPickingAssets:self.imagePickerController.selectedAssets.array];
        }
        else {
            
            [self fetchAssetsFromSelectedAssetURLsWithCompletion:^(NSArray *assets) {
                [self.imagePickerController.delegate qb_imagePickerController:self.imagePickerController
                                                       didFinishPickingAssets:assets];
            }];
        }
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
    NSMutableOrderedSet *selectedAssets = self.imagePickerController.selectedAssets;
    
    if (selectedAssets.count > 0) {
        NSBundle *bundle = self.imagePickerController.assetBundle;
        NSString *format;
        if (selectedAssets.count > 1) {
            format = NSLocalizedStringFromTableInBundle(@"assets.toolbar.items-selected", @"QBImagePicker", bundle, nil);
        } else {
            format = NSLocalizedStringFromTableInBundle(@"assets.toolbar.item-selected", @"QBImagePicker", bundle, nil);
        }
        
        NSString *title = [NSString stringWithFormat:format, selectedAssets.count];
        [(UIBarButtonItem *)self.toolbarItems[1] setTitle:title];
    } else {
        [(UIBarButtonItem *)self.toolbarItems[1] setTitle:@""];
    }
}


#pragma mark - Fetching Asset Collections

    //platform specific
- (NSArray*) assetCollectionSubtypesForSubtypes:(NSArray*) subtypes  {
    
    NSMutableArray* platformSubtypes = [NSMutableArray array];
    
    if ([QBImagePickerController usingPhotosLibrary]) {
        
        if ([subtypes containsObject: @(QBImagePickerCollectionSubtypeAll)]) {
            
            //PHAssetCollectionSubtypeAny ??
            [platformSubtypes addObjectsFromArray: @[@(PHAssetCollectionSubtypeSmartAlbumUserLibrary),
                                                     @(PHAssetCollectionSubtypeAlbumMyPhotoStream),
                                                     @(PHAssetCollectionSubtypeSmartAlbumPanoramas),
                                                     @(PHAssetCollectionSubtypeSmartAlbumVideos),
                                                     @(PHAssetCollectionSubtypeSmartAlbumBursts)]];
        }
        else {
        
            if ([subtypes containsObject: @(QBImagePickerCollectionSubtypeLibrary)]) {
                
                [platformSubtypes addObject: @(PHAssetCollectionSubtypeSmartAlbumUserLibrary)];
            }

            if ([subtypes containsObject: @(QBImagePickerCollectionSubtypeAlbum)]) {
                
                [platformSubtypes addObject: @(PHAssetCollectionSubtypeAlbumRegular)];
            }

            if ([subtypes containsObject: @(QBImagePickerCollectionSubtypeStream)]) {
                
                [platformSubtypes addObject: @(PHAssetCollectionSubtypeAlbumMyPhotoStream)];
            }
            
            if ([subtypes containsObject: @(QBImagePickerCollectionSubtypePanoramas)]) {
                
                [platformSubtypes addObject: @(PHAssetCollectionSubtypeSmartAlbumPanoramas)];
            }
            
            if ([subtypes containsObject: @(QBImagePickerCollectionSubtypeVideos)]) {
                
                [platformSubtypes addObject: @(PHAssetCollectionSubtypeSmartAlbumVideos)];
            }
            
            if ([subtypes containsObject: @(QBImagePickerCollectionSubtypeBursts)]) {
                
                [platformSubtypes addObject: @(PHAssetCollectionSubtypeSmartAlbumBursts)];
            }
        }
    }
    else {
        
        if ([subtypes containsObject: @(QBImagePickerCollectionSubtypeAll)]) {

            [platformSubtypes addObjectsFromArray: @[@(ALAssetsGroupSavedPhotos),
                                                     @(ALAssetsGroupAlbum),
                                                     @(ALAssetsGroupPhotoStream)]];
        }
        else {
            
            
            if ([subtypes containsObject: @(QBImagePickerCollectionSubtypeLibrary)]) {
                
                [platformSubtypes addObject: @(ALAssetsGroupSavedPhotos)];
            }
            
            if ([subtypes containsObject: @(QBImagePickerCollectionSubtypeAlbum)]) {
                
                [platformSubtypes addObject: @(ALAssetsGroupAlbum)];
            }
            
            if ([subtypes containsObject: @(QBImagePickerCollectionSubtypeStream)]) {
                
                [platformSubtypes addObject: @(ALAssetsGroupPhotoStream)];
            }
        }
    }
    
    return platformSubtypes;
}

- (void)updateAssetCollections
{
    // Filter albums
    NSArray *subtypes = [self assetCollectionSubtypesForSubtypes: _imagePickerController.collectionSubtypes];
    
    NSMutableDictionary *smartAlbums = [NSMutableDictionary dictionaryWithCapacity:subtypes.count];
    NSMutableArray *userAlbums = [NSMutableArray array];
    
    for (PHFetchResult *fetchResult in self.fetchResults) {
        [fetchResult enumerateObjectsUsingBlock:^(PHAssetCollection *assetCollection, NSUInteger index, BOOL *stop) {
            PHAssetCollectionSubtype subtype = assetCollection.assetCollectionSubtype;
            
            if (subtype == PHAssetCollectionSubtypeAlbumRegular) {
                [userAlbums addObject:assetCollection];
            } else if ([subtypes containsObject:@(subtype)]) {
                if (!smartAlbums[@(subtype)]) {
                    smartAlbums[@(subtype)] = [NSMutableArray array];
                }
                [smartAlbums[@(subtype)] addObject:assetCollection];
            }
        }];
    }
    
    NSMutableArray *assetCollections = [NSMutableArray array];

    // Fetch smart albums
    for (NSNumber *assetCollectionSubtype in subtypes) {
        NSArray *collections = smartAlbums[assetCollectionSubtype];
        
        if (collections) {
            [assetCollections addObjectsFromArray:collections];
        }
    }
    
    // Fetch user albums
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *assetCollection, NSUInteger index, BOOL *stop) {
        [assetCollections addObject:assetCollection];
    }];
    
    self.assetCollections = assetCollections;
}

- (void)updateAssetsGroupsWithCompletion:(void (^)(void))completion
{
    NSArray *subtypes = [self assetCollectionSubtypesForSubtypes: _imagePickerController.collectionSubtypes];

    [self fetchAssetsGroupsWithTypes: subtypes completion:^(NSArray *assetsGroups) {
        // Map assets group to dictionary
        NSMutableDictionary *mappedAssetsGroups = [NSMutableDictionary dictionaryWithCapacity:assetsGroups.count];
        for (ALAssetsGroup *assetsGroup in assetsGroups) {
            NSMutableArray *array = mappedAssetsGroups[[assetsGroup valueForProperty:ALAssetsGroupPropertyType]];
            if (!array) {
                array = [NSMutableArray array];
            }
            
            [array addObject:assetsGroup];
            
            mappedAssetsGroups[[assetsGroup valueForProperty:ALAssetsGroupPropertyType]] = array;
        }
        
        // Pick the groups to be shown
        NSMutableArray *sortedAssetsGroups = [NSMutableArray arrayWithCapacity: subtypes.count];
        
        for (NSValue *groupType in subtypes) {
            NSArray *array = mappedAssetsGroups[groupType];
            
            if (array) {
                [sortedAssetsGroups addObjectsFromArray:array];
            }
        }
        
        self.assetsGroups = sortedAssetsGroups;
        
        if (completion) {
            completion();
        }
    }];
}

- (void)fetchAssetsGroupsWithTypes:(NSArray *)types completion:(void (^)(NSArray *assetsGroups))completion
{
    __block NSMutableArray *assetsGroups = [NSMutableArray array];
    __block NSUInteger numberOfFinishedTypes = 0;
    
    ALAssetsLibrary *assetsLibrary = self.imagePickerController.assetsLibrary;
    ALAssetsFilter *assetsFilter;
    
    switch (self.imagePickerController.mediaType) {
        case QBImagePickerMediaTypeAny:
            assetsFilter = [ALAssetsFilter allAssets];
            break;
            
        case QBImagePickerMediaTypeImage:
            assetsFilter = [ALAssetsFilter allPhotos];
            break;
            
        case QBImagePickerMediaTypeVideo:
            assetsFilter = [ALAssetsFilter allVideos];
            break;
    }
    
    for (NSNumber *type in types) {
        [assetsLibrary enumerateGroupsWithTypes:[type unsignedIntegerValue]
                                     usingBlock:^(ALAssetsGroup *assetsGroup, BOOL *stop) {
                                         if (assetsGroup) {
                                             // Apply assets filter
                                             [assetsGroup setAssetsFilter:assetsFilter];
                                             
                                             // Add assets group
                                             [assetsGroups addObject:assetsGroup];
                                         } else {
                                             numberOfFinishedTypes++;
                                         }
                                         
                                         // Check if the loading finished
                                         if (numberOfFinishedTypes == types.count) {
                                             if (completion) {
                                                 completion(assetsGroups);
                                             }
                                         }
                                     } failureBlock:^(NSError *error) {
                                         NSLog(@"Error: %@", [error localizedDescription]);
                                     }];
    }
}

- (void)fetchAssetsFromSelectedAssetURLsWithCompletion:(void (^)(NSArray *assets))completion
{
    // Load assets from URLs
    // The asset will be ignored if it is not found
    ALAssetsLibrary *assetsLibrary = self.imagePickerController.assetsLibrary;
    NSMutableOrderedSet *selectedAssets = self.imagePickerController.selectedAssets;
    
    __block NSMutableArray *assets = [NSMutableArray array];
    
    void (^checkNumberOfAssets)(void) = ^{
        if (assets.count == selectedAssets.count) {
            if (completion) {
                completion([assets copy]);
            }
        }
    };
    
    for (ALAsset* asset in selectedAssets) {
        
        NSURL *assetURL = [asset valueForProperty: ALAssetPropertyAssetURL];
    
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


- (UIImage *)placeholderImageWithSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *backgroundColor = [UIColor colorWithRed:(239.0 / 255.0) green:(239.0 / 255.0) blue:(244.0 / 255.0) alpha:1.0];
    UIColor *iconColor = [UIColor colorWithRed:(179.0 / 255.0) green:(179.0 / 255.0) blue:(182.0 / 255.0) alpha:1.0];
    
    // Background
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    // Icon (back)
    CGRect backIconRect = CGRectMake(size.width * (16.0 / 68.0),
                                     size.height * (20.0 / 68.0),
                                     size.width * (32.0 / 68.0),
                                     size.height * (24.0 / 68.0));
    
    CGContextSetFillColorWithColor(context, [iconColor CGColor]);
    CGContextFillRect(context, backIconRect);
    
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, CGRectInset(backIconRect, 1.0, 1.0));
    
    // Icon (front)
    CGRect frontIconRect = CGRectMake(size.width * (20.0 / 68.0),
                                      size.height * (24.0 / 68.0),
                                      size.width * (32.0 / 68.0),
                                      size.height * (24.0 / 68.0));
    
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, CGRectInset(frontIconRect, -1.0, -1.0));
    
    CGContextSetFillColorWithColor(context, [iconColor CGColor]);
    CGContextFillRect(context, frontIconRect);
    
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, CGRectInset(frontIconRect, 1.0, 1.0));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


#pragma mark - Checking for Selection Limit

- (BOOL)isMinimumSelectionLimitFulfilled
{
    return (self.imagePickerController.minimumNumberOfSelection <= self.imagePickerController.selectedAssets.count);
}

- (BOOL)isMaximumSelectionLimitReached
{
    NSUInteger minimumNumberOfSelection = MAX(1, self.imagePickerController.minimumNumberOfSelection);
    
    if (minimumNumberOfSelection <= self.imagePickerController.maximumNumberOfSelection) {
        return (self.imagePickerController.maximumNumberOfSelection <= self.imagePickerController.selectedAssets.count);
    }
    
    return NO;
}

- (void)updateControlState
{
    self.doneButton.enabled = [self isMinimumSelectionLimitFulfilled];
}


#pragma mark - UITableViewDataSource

- (NSUInteger) rowCount {

    if ([QBImagePickerController usingPhotosLibrary]) {
        
        return self.assetCollections.count;
    }
    else {

        return self.assetsGroups.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self rowCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QBAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumCell" forIndexPath:indexPath];
    cell.tag = indexPath.row;
    cell.borderWidth = 1.0 / [[UIScreen mainScreen] scale];
    
    
    // Thumbnail
    NSUInteger numberOfAssets = 0;
    NSString* title = @"";

    cell.imageView2.hidden = YES;
    cell.imageView3.hidden = YES;
    
    if ([QBImagePickerController usingPhotosLibrary]) {
    
        // Thumbnail
        PHAssetCollection *assetCollection = self.assetCollections[indexPath.row];
        PHFetchOptions *options = [PHFetchOptions new];
        
        switch (self.imagePickerController.mediaType) {
            case QBImagePickerMediaTypeImage:
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
                break;
                
            case QBImagePickerMediaTypeVideo:
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
                break;
                
            default:
                break;
        }
        
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
        
        numberOfAssets = fetchResult.count;
        title = assetCollection.localizedTitle;
        
        PHImageManager *imageManager = [PHImageManager defaultManager];
        
        NSArray* imageViews = @[cell.imageView1, cell.imageView2, cell.imageView3];
        
        NSUInteger count =  MIN(imageViews.count,numberOfAssets);

        if (count >= 1) {

            for (int i = 0; i < count; i++) {
                
                UIImageView* imageView = imageViews[i];

                [imageManager requestImageForAsset:fetchResult[fetchResult.count - (i + 1)]
                                        targetSize:CGSizeScale(imageView.frame.size, [[UIScreen mainScreen] scale])
                                       contentMode:PHImageContentModeAspectFill
                                           options:nil
                                     resultHandler:^(UIImage *result, NSDictionary *info) {
                                         
                                         if (cell.tag == indexPath.row) {
                                             
                                             imageView.hidden = NO;
                                             imageView.image = result;
                                         }
                                     }];
            }
        }
    }
    else {
    
        ALAssetsGroup *assetsGroup = self.assetsGroups[indexPath.row];
        
        numberOfAssets = [assetsGroup numberOfAssets];
        title = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
        
        if (numberOfAssets > 0) {
            NSUInteger count =  MIN(3,numberOfAssets);
            NSRange range = NSMakeRange(numberOfAssets - count, count);
            NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:range];
            
            [assetsGroup enumerateAssetsAtIndexes:indexes options:0 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (!result || cell.tag != indexPath.row) return;
                
                UIImage *thumbnail = [UIImage imageWithCGImage:[result thumbnail]];
                
                if (index == NSMaxRange(range) - 1) {
                    cell.imageView1.hidden = NO;
                    cell.imageView1.image = thumbnail;
                } else if (index == NSMaxRange(range) - 2) {
                    cell.imageView2.hidden = NO;
                    cell.imageView2.image = thumbnail;
                } else {
                    cell.imageView3.hidden = NO;
                    cell.imageView3.image = thumbnail;
                }
            }];
        }
    }
    
    if (numberOfAssets == 0) {
        
        cell.imageView3.hidden = NO;
        cell.imageView2.hidden = NO;
        
        // Set placeholder image
        UIImage *placeholderImage = [self placeholderImageWithSize:cell.imageView1.frame.size];
        cell.imageView1.image = placeholderImage;
        cell.imageView2.image = placeholderImage;
        cell.imageView3.image = placeholderImage;
    }
    
    // Album title
    cell.titleLabel.text = title;
    
    // Number of photos
    cell.countLabel.text = [NSString stringWithFormat:@"%lu", (long)numberOfAssets];
    
    return cell;
}


#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // Update fetch results
        NSMutableArray *fetchResults = [self.fetchResults mutableCopy];
        
        [self.fetchResults enumerateObjectsUsingBlock:^(PHFetchResult *fetchResult, NSUInteger index, BOOL *stop) {
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:fetchResult];
            
            if (changeDetails) {
                [fetchResults replaceObjectAtIndex:index withObject:changeDetails.fetchResultAfterChanges];
            }
        }];
        
        if (![self.fetchResults isEqualToArray:fetchResults]) {
            self.fetchResults = fetchResults;
            
            // Reload albums
            [self updateAssetCollections];
            [self.tableView reloadData];
        }
    });
}

@end
