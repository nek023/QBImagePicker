//
// Created by Vlad Spreys on 12/8/15.
// Copyright (c) 2015 Katsuma Tanaka. All rights reserved.
//

#import "ALAssetsLibrary+Singleton.h"

@implementation ALAssetsLibrary (Singleton)
+ (instancetype)defaultAssetsLibrary {
    static ALAssetsLibrary *defaultAssetsLibrary;
    @synchronized(self) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            defaultAssetsLibrary = [[self alloc] init];
        });
    }
    return defaultAssetsLibrary;
}
@end