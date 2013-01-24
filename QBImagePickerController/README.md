# QBImagePickerController
QBImagePickerController is a clone of UIImagePickerController with multiple selection feature.

## Installation
	#import <AssetsLibrary/AssetsLibrary.h>
	#import "QBImagePickerController.h"
in your ViewController.

## Usage
__QBImagePickerController is not a subclass of UINavigationController.__
If you want to show the picker as a modal view, you have to set the picker to `topViewController` property of an instance of UINavigationController and use it.
If you want to push the picker to NavigtionController, you don't have to do anything.

### Example
	QBImagePickerController *imagePickerController = [[[QBImagePickerController alloc] init] autorelease];
	imagePickerController.delegate = self;
	imagePickerController.filterType = QBImagePickerFilterTypeAllPhotos;
	imagePickerController.showsCancelButton = YES;
	imagePickerController.fullScreenLayoutEnabled = YES;
	imagePickerController.allowsMultipleSelection = YES;

	imagePickerController.limitsMaximumNumberOfSelection = YES;
	imagePickerController.maximumNumberOfSelection = 6;

	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:imagePickerController] autorelease];
	[self presentViewController:navigationController animated:YES completion:NULL];

