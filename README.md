# QBImagePickerController
A clone of UIImagePickerController with multiple selection support.


## Installation
QBImagePickerController is available in CocoaPods.

    pod 'QBImagePickerController'

If you want to install manually, download this repository and copy files in QBImagePickerController directory to your project, and link `AssetsLibrary.framework`.


## Example
### Check If Source is Accessible
    if (![QBImagePickerController isAccessible]) {
        NSLog(@"Error: Source is not accessible.");
    }

### Single Image Picker
	QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
	imagePickerController.delegate = self;

### Multiple Image Picker
	QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
	imagePickerController.delegate = self;
	imagePickerController.allowsMultipleSelection = YES;

### Multiple Image Picker with Limitation
	QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
	imagePickerController.delegate = self;
	imagePickerController.allowsMultipleSelection = YES;
	imagePickerController.minimumNumberOfSelection = 3;
	imagePickerController.maximumNumberOfSelection = 6;

### Specify the Albums to Show
	QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
	imagePickerController.delegate = self;
	imagePickerController.groupTypes = @[
	                                     @(ALAssetsGroupSavedPhotos),
	                                     @(ALAssetsGroupPhotoStream),
	                                     @(ALAssetsGroupAlbum)
	                                     ];

The order of albums will be the same as specified in `groupTypes` array.

### Show Image Picker
**QBImagePickerController is not a subclass of UINavigationController.**  
If you want to show the picker as a modal view, you have to set the picker to `topViewController` property of an instance of UINavigationController.  
If you want to push the picker to UINavigtionController, you don't have to do anything.

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    [self presentViewController:navigationController animated:YES completion:NULL];


## License
*QBImagePickerController* is released under the **MIT License**, see *LICENSE.txt*.
