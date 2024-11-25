//
//  NSIndexSet+ContainsAny.h
//  QBImagePicker
//
//  Created by Glenn Posadas on 9/25/24.
//  Copyright © 2024 Katsuma Tanaka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexSet (ContainsAny)

- (BOOL)containsAnyIndexOf:(NSIndexSet *)otherSet;

@end
