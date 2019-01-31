//
//  LocalizationHelper.h
//  QBImagePicker
//
//  Created by Ganora Alberto on 31.01.19.
//  Copyright © 2019 Katsuma Tanaka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalizationHelper : NSObject

NSString *QBImagePickerLocalizedString(NSString *key, NSString *comment, NSBundle *framworkBundle);

@end
