//
//  QBImagePickerAssetCellDelegate
//  QBImagePickerController
//
//  Created by questbeat on 2013/01/21.
//  Copyright (c) 2013年 Katsuma Tanaka. All rights reserved.
//

@class QBImagePickerAssetCell;

@protocol QBImagePickerAssetCellDelegate <NSObject>

@required
- (BOOL)assetCell:(QBImagePickerAssetCell *)assetCell canSelectAssetAtIndex:(NSUInteger)index;
- (void)assetCell:(QBImagePickerAssetCell *)assetCell didChangeAssetSelectionState:(BOOL)selected atIndex:(NSUInteger)index;

@end
