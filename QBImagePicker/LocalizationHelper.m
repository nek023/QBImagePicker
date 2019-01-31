//
//  LocalizationHelper.m
//  QBImagePicker
//
//  Created by Ganora Alberto on 31.01.19.
//  Copyright © 2019 Katsuma Tanaka. All rights reserved.
//

#import "LocalizationHelper.h"

@implementation LocalizationHelper

static inline NSString *QBImagePickerLocalizedString( NSString *key, NSString *comment, NSBundle *framworkBundle)
{
    return (QBImagePickerFrameworkString(key, comment, framworkBundle));
}

NSString *_QBImagePickerFrameworkString(NSString *key, NSBundle *framworkBundle)
{
    return ([framworkBundle localizedStringForKey:key value:nil table:@"QBImagePicker"]);
}

NSString *QBImagePickerFrameworkString(NSString *key, NSString *comment, NSBundle *framworkBundle)
{
    NSString *localizedString = [[NSBundle mainBundle] localizedStringForKey:key value:nil table:@"QBImagePicker"];
    if(!localizedString || [localizedString isEqualToString:key])
    {
        localizedString = _QBImagePickerFrameworkString(key, framworkBundle);
    }
    return( localizedString ? localizedString : key);
}

@end
