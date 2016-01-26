//
//  QBImagePickerController.m
//  QBImagePicker
//
//  Created by Katsuma Tanaka on 2015/04/03.
//  Copyright (c) 2015 Katsuma Tanaka. All rights reserved.
//

#import "QBImagePickerController.h"
#import <Photos/Photos.h>

// ViewControllers
#import "QBAlbumsViewController.h"

@interface QBImagePickerController ()
@property (nonatomic, strong) PHFetchOptions *defaultFetchOptions;

@property (nonatomic, strong) UINavigationController *albumsNavigationController;

@property (nonatomic, strong) NSBundle *assetBundle;

@end

@implementation QBImagePickerController

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        // Set default values
        self.assetCollectionSubtypes = @[
                                         @(PHAssetCollectionSubtypeSmartAlbumUserLibrary),
                                         @(PHAssetCollectionSubtypeAlbumMyPhotoStream),
                                         @(PHAssetCollectionSubtypeSmartAlbumPanoramas),
                                         @(PHAssetCollectionSubtypeSmartAlbumVideos),
                                         @(PHAssetCollectionSubtypeSmartAlbumBursts)
                                         ];
        self.minimumNumberOfSelection = 1;
        self.numberOfColumnsInPortrait = 4;
        self.numberOfColumnsInLandscape = 7;
        self.excludeEmptyAlbums = YES;
        
        _selectedAssets = [NSMutableOrderedSet orderedSet];
        
        // Get asset bundle
        self.assetBundle = [NSBundle bundleForClass:[self class]];
        NSString *bundlePath = [self.assetBundle pathForResource:@"QBImagePicker" ofType:@"bundle"];
        if (bundlePath) {
            self.assetBundle = [NSBundle bundleWithPath:bundlePath];
        }
        
        [self setUpAlbumsViewController];
        
        // Set instance
        QBAlbumsViewController *albumsViewController = (QBAlbumsViewController *)self.albumsNavigationController.topViewController;
        albumsViewController.imagePickerController = self;
    }
    
    return self;
}

- (void)setUpAlbumsViewController
{
    // Add QBAlbumsViewController as a child
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"QBImagePicker" bundle:self.assetBundle];
    UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"QBAlbumsNavigationController"];
    
    [self addChildViewController:navigationController];
    
    navigationController.view.frame = self.view.bounds;
    [self.view addSubview:navigationController.view];
    
    [navigationController didMoveToParentViewController:self];
    
    self.albumsNavigationController = navigationController;
}

- (PHFetchOptions *)fetchOptions
{
    if (!_fetchOptions)
    {
        if (self.defaultFetchOptions)
        {
            return self.defaultFetchOptions;
        }
        PHFetchOptions *options = [PHFetchOptions new];
        NSPredicate *mediaTypePredicate;
        switch (self.mediaType) {
            case QBImagePickerMediaTypeImage:
                mediaTypePredicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
                break;
                
            case QBImagePickerMediaTypeVideo:
                mediaTypePredicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
                break;
                
            default:
                break;
        }
        
        NSPredicate *mediaSubTtypePredicate;
        if (self.assetMediaSubtypes)
        {
            mediaSubTtypePredicate = [NSPredicate predicateWithFormat:@"mediaSubtype in %@ ", self.assetMediaSubtypes];
        }
        NSMutableArray *predicates = [@[] mutableCopy];
        if (mediaTypePredicate)
        {
            [predicates addObject:mediaTypePredicate];
        }
        if (mediaSubTtypePredicate)
        {
            [predicates addObject:mediaSubTtypePredicate];
        }
        if (predicates.count > 0)
        {
            NSCompoundPredicate *preidcate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
            options.predicate = preidcate;
        }
        self.defaultFetchOptions = options;
        return options;
    }
    return _fetchOptions;
}

@end
