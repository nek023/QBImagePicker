# QBImagePickerController
QBImagePickerController is a clone of UIImagePickerController with multiple selection feature.


## ScreenShot
![ss01.png](http://adotout.sakura.ne.jp/github/QBImagePickerController/ss01.png)
![ss02.png](http://adotout.sakura.ne.jp/github/QBImagePickerController/ss02.png)


## Installation
	#import <AssetsLibrary/AssetsLibrary.h>
	#import "QBImagePickerController.h"
in your ViewController.


## Usage
**QBImagePickerController is not a subclass of UINavigationController.**  
If you want to show the picker as a modal view, you have to set the picker to `topViewController` property of an instance of UINavigationController and use it.
If you want to push the picker to NavigtionController, you don't have to do anything.


## Example
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


## License
 Copyright (c) 2013 Katsuma Tanaka
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
