//
//  ViewController.h
//  QBImagePickerController
//
//  Created by Katsuma Tanaka on 2013/01/23.
//  Copyright (c) 2013年 Katsuma Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>

// Controllers
#import "QBImagePickerController.h"

@interface ViewController : UIViewController <QBImagePickerControllerDelegate>

- (IBAction)pickSinglePhoto:(id)sender;
- (IBAction)pickMultiplePhotos:(id)sender;
- (IBAction)pickWithLimitation:(id)sender;

@end
