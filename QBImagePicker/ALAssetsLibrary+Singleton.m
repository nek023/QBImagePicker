//
//  ALAssetsLibrary+Singleton.m
//  Haituncun
//
//  Created by Donly Chan on 15/7/22.
//  Copyright (c) 2015年 Azoya. All rights reserved.
//

#import "ALAssetsLibrary+Singleton.h"

static ALAssetsLibrary *library = nil;

@implementation ALAssetsLibrary (Singleton)

+ (instancetype)defaultAssetsLibrary {
    static dispatch_once_t libPred;
    dispatch_once(&libPred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    
    return library;
}

+ (void)clean {
    library = nil;
}

@end
