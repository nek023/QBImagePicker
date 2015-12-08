//
// Created by Vlad Spreys on 12/8/15.
// Copyright (c) 2015 Katsuma Tanaka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetsLibrary (Singleton)
+ (instancetype)defaultAssetsLibrary;
@end