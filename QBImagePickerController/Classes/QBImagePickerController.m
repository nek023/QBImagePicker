/*
 Copyright (c) 2013 Katsuma Tanaka
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "QBImagePickerController.h"

// Views
#import "QBImagePickerGroupCell.h"

// Controllers
#import "QBAssetCollectionViewController.h"

@interface QBImagePickerController ()

@property (nonatomic, retain) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, retain) NSMutableArray *assetsGroups;

@property (nonatomic, retain) UITableView *tableView;

@property (nonatomic, assign) UIBarStyle previousBarStyle;
@property (nonatomic, assign) BOOL previousBarTranslucent;
@property (nonatomic, assign) UIStatusBarStyle previousStatusBarStyle;

- (void)cancel;
- (NSDictionary *)mediaInfoFromAsset:(ALAsset *)asset;

@end

@implementation QBImagePickerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        /* Check sources */
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        
        /* Initialization */
        self.title = @"Photos";
        self.filterType = QBImagePickerFilterTypeAllPhotos;
        self.showsCancelButton = YES;
        self.fullScreenLayoutEnabled = YES;
        
        self.allowsMultipleSelection = NO;
        self.limitsMinimumNumberOfSelection = NO;
        self.limitsMaximumNumberOfSelection = NO;
        self.minimumNumberOfSelection = 0;
        self.maximumNumberOfSelection = 0;
        
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        self.assetsLibrary = assetsLibrary;
        [assetsLibrary release];
        
        self.assetsGroups = [NSMutableArray array];
        
        // Table View
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view addSubview:tableView];
        self.tableView = tableView;
        [tableView release];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    void (^assetsGroupsEnumerationBlock)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *assetsGroup, BOOL *stop) {
        if(assetsGroup) {
            switch(self.filterType) {
                case QBImagePickerFilterTypeAllAssets:
                    [assetsGroup setAssetsFilter:[ALAssetsFilter allAssets]];
                    break;
                case QBImagePickerFilterTypeAllPhotos:
                    [assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
                    break;
                case QBImagePickerFilterTypeAllVideos:
                    [assetsGroup setAssetsFilter:[ALAssetsFilter allVideos]];
                    break;
            }
            
            if(assetsGroup.numberOfAssets > 0) {
                [self.assetsGroups addObject:assetsGroup];
                [self.tableView reloadData];
            }
        }
    };
    
    void (^assetsGroupsFailureBlock)(NSError *) = ^(NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    };
    
    // Enumerate Camera Roll
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
    
    // Photo Stream
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
    
    // Album
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
    
    // Event
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupEvent usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
    
    // Faces
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupFaces usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Full screen layout
    if(self.fullScreenLayoutEnabled) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        if(indexPath == nil) {
            self.previousBarStyle = self.navigationController.navigationBar.barStyle;
            self.previousBarTranslucent = self.navigationController.navigationBar.translucent;
            self.previousStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
            
            self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
            self.navigationController.navigationBar.translucent = YES;
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
            
            CGFloat top = 0;
            if(![[UIApplication sharedApplication] isStatusBarHidden]) top = top + 20;
            if(!self.navigationController.navigationBarHidden) top = top + 44;
            self.tableView.contentInset = UIEdgeInsetsMake(top, 0, 0, 0);
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(top, 0, 0, 0);
            
            [self setWantsFullScreenLayout:YES];
        }
    }
    
    // Cancel table view selection
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Flash scroll indicators
    [self.tableView flashScrollIndicators];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Restore bar styles
    self.navigationController.navigationBar.barStyle = self.previousBarStyle;
    self.navigationController.navigationBar.translucent = self.previousBarTranslucent;
    [[UIApplication sharedApplication] setStatusBarStyle:self.previousStatusBarStyle animated:YES];
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton
{
    _showsCancelButton = showsCancelButton;
    
    if(self.showsCancelButton) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
        [self.navigationItem setRightBarButtonItem:cancelButton animated:NO];
        [cancelButton release];
    } else {
        [self.navigationItem setRightBarButtonItem:nil animated:NO];
    }
}

- (void)dealloc
{
    [_assetsLibrary release];
    [_assetsGroups release];
    
    [_tableView release];
    
    [super dealloc];
}


#pragma mark - Instance Methods

- (void)cancel
{
    if([self.delegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
        [self.delegate imagePickerControllerDidCancel:self];
    }
}

- (NSDictionary *)mediaInfoFromAsset:(ALAsset *)asset
{
    NSMutableDictionary *mediaInfo = [NSMutableDictionary dictionary];
    [mediaInfo setObject:[asset valueForProperty:ALAssetPropertyType] forKey:@"UIImagePickerControllerMediaType"];
    [mediaInfo setObject:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]] forKey:@"UIImagePickerControllerOriginalImage"];
    [mediaInfo setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:@"UIImagePickerControllerReferenceURL"];
    
    return mediaInfo;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.assetsGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    QBImagePickerGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[[QBImagePickerGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    ALAssetsGroup *assetsGroup = [self.assetsGroups objectAtIndex:indexPath.row];
    
    cell.imageView.image = [UIImage imageWithCGImage:assetsGroup.posterImage];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@", [assetsGroup valueForProperty:ALAssetsGroupPropertyName]];
    cell.countLabel.text = [NSString stringWithFormat:@"(%d)", assetsGroup.numberOfAssets];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALAssetsGroup *assetsGroup = [self.assetsGroups objectAtIndex:indexPath.row];
    
    BOOL showsHeaderButton = ([self.delegate respondsToSelector:@selector(descriptionForSelectingAllAssets:)] && [self.delegate respondsToSelector:@selector(descriptionForDeselectingAllAssets:)]);
    
    BOOL showsFooterDescription = NO;
    
    switch(self.filterType) {
        case QBImagePickerFilterTypeAllAssets:
            showsFooterDescription = ([self.delegate respondsToSelector:@selector(imagePickerController:descriptionForNumberOfPhotos:numberOfVideos:)]);
            break;
        case QBImagePickerFilterTypeAllPhotos:
            showsFooterDescription = ([self.delegate respondsToSelector:@selector(imagePickerController:descriptionForNumberOfPhotos:)]);
            break;
        case QBImagePickerFilterTypeAllVideos:
            showsFooterDescription = ([self.delegate respondsToSelector:@selector(imagePickerController:descriptionForNumberOfVideos:)]);
            break;
    }
    
    // Show assets collection view
    QBAssetCollectionViewController *assetCollectionViewController = [[QBAssetCollectionViewController alloc] init];
    assetCollectionViewController.title = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    assetCollectionViewController.delegate = self;
    assetCollectionViewController.assetsGroup = assetsGroup;
    assetCollectionViewController.filterType = self.filterType;
    assetCollectionViewController.showsCancelButton = self.showsCancelButton;
    assetCollectionViewController.fullScreenLayoutEnabled = self.fullScreenLayoutEnabled;
    assetCollectionViewController.showsHeaderButton = showsHeaderButton;
    assetCollectionViewController.showsFooterDescription = showsFooterDescription;
    
    assetCollectionViewController.allowsMultipleSelection = self.allowsMultipleSelection;
    assetCollectionViewController.limitsMinimumNumberOfSelection = self.limitsMinimumNumberOfSelection;
    assetCollectionViewController.limitsMaximumNumberOfSelection = self.limitsMaximumNumberOfSelection;
    assetCollectionViewController.minimumNumberOfSelection = self.minimumNumberOfSelection;
    assetCollectionViewController.maximumNumberOfSelection = self.maximumNumberOfSelection;
    
    [self.navigationController pushViewController:assetCollectionViewController animated:YES];
    
    [assetCollectionViewController release];
}


#pragma mark - QBAssetCollectionViewControllerDelegate

- (void)assetCollectionViewController:(QBAssetCollectionViewController *)assetCollectionViewController didFinishPickingAsset:(ALAsset *)asset
{
    if([self.delegate respondsToSelector:@selector(imagePickerControllerWillFinishPickingMedia:)]) {
        [self.delegate imagePickerControllerWillFinishPickingMedia:self];
    }
    
    if([self.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:)]) {
        [self.delegate imagePickerController:self didFinishPickingMediaWithInfo:[self mediaInfoFromAsset:asset]];
    }
}

- (void)assetCollectionViewController:(QBAssetCollectionViewController *)assetCollectionViewController didFinishPickingAssets:(NSArray *)assets
{
    if([self.delegate respondsToSelector:@selector(imagePickerControllerWillFinishPickingMedia:)]) {
        [self.delegate imagePickerControllerWillFinishPickingMedia:self];
    }
    
    if([self.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:)]) {
        NSMutableArray *info = [NSMutableArray array];
        
        for(ALAsset *asset in assets) {
            [info addObject:[self mediaInfoFromAsset:asset]];
        }
        
        [self.delegate imagePickerController:self didFinishPickingMediaWithInfo:info];
    }
}

- (void)assetCollectionViewControllerDidCancel:(QBAssetCollectionViewController *)assetCollectionViewController
{
    if([self.delegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
        [self.delegate imagePickerControllerDidCancel:self];
    }
}

- (NSString *)descriptionForSelectingAllAssets:(QBAssetCollectionViewController *)assetCollectionViewController
{
    NSString *description = nil;
    
    if([self.delegate respondsToSelector:@selector(descriptionForSelectingAllAssets:)]) {
        description = [self.delegate descriptionForSelectingAllAssets:self];
    }
    
    return description;
}

- (NSString *)descriptionForDeselectingAllAssets:(QBAssetCollectionViewController *)assetCollectionViewController
{
    NSString *description = nil;
    
    if([self.delegate respondsToSelector:@selector(descriptionForDeselectingAllAssets:)]) {
        description = [self.delegate descriptionForDeselectingAllAssets:self];
    }
    
    return description;
}

- (NSString *)assetCollectionViewController:(QBAssetCollectionViewController *)assetCollectionViewController descriptionForNumberOfPhotos:(NSUInteger)numberOfPhotos
{
    NSString *description = nil;
    
    if([self.delegate respondsToSelector:@selector(imagePickerController:descriptionForNumberOfPhotos:)]) {
        description = [self.delegate imagePickerController:self descriptionForNumberOfPhotos:numberOfPhotos];
    }
    
    return description;
}

- (NSString *)assetCollectionViewController:(QBAssetCollectionViewController *)assetCollectionViewController descriptionForNumberOfVideos:(NSUInteger)numberOfVideos
{
    NSString *description = nil;
    
    if([self.delegate respondsToSelector:@selector(imagePickerController:descriptionForNumberOfVideos:)]) {
        description = [self.delegate imagePickerController:self descriptionForNumberOfVideos:numberOfVideos];
    }
    
    return description;
}

- (NSString *)assetCollectionViewController:(QBAssetCollectionViewController *)assetCollectionViewController descriptionForNumberOfPhotos:(NSUInteger)numberOfPhotos numberOfVideos:(NSUInteger)numberOfVideos
{
    NSString *description = nil;
    
    if([self.delegate respondsToSelector:@selector(imagePickerController:descriptionForNumberOfPhotos:numberOfVideos:)]) {
        description = [self.delegate imagePickerController:self descriptionForNumberOfPhotos:numberOfPhotos numberOfVideos:numberOfVideos];
    }
    
    return description;
}

@end
