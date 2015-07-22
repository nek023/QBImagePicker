//
//  ALAssetsLibrary+Singleton.h
//  Haituncun
//
//  Created by Donly Chan on 15/7/22.
//  Copyright (c) 2015年 Azoya. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetsLibrary (Singleton)

+ (instancetype)defaultAssetsLibrary;
+ (void)clean;

@end
