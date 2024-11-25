//
//  NSIndexSet+ContainsAny.m
//  QBImagePicker
//
//  Created by Glenn Posadas on 9/25/24.
//  Copyright © 2024 Katsuma Tanaka. All rights reserved.
//

#import "NSIndexSet+ContainsAny.h"

@implementation NSIndexSet (ContainsAny)

- (BOOL)containsAnyIndexOf:(NSIndexSet *)otherSet {
    __block BOOL result = NO;
    [otherSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self containsIndex:idx]) {
            result = YES;
            *stop = YES;
        }
    }];
    
    return result;
}

@end
