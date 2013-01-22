//
//  QBImagePickerAssetViewDelegate
//  QBImagePickerController
//
//  Created by questbeat on 2013/01/21.
//  Copyright (c) 2013年 Katsuma Tanaka. All rights reserved.
//

@class QBImagePickerAssetView;

@protocol QBImagePickerAssetViewDelegate <NSObject>

@required
- (BOOL)assetViewCanBeSelected:(QBImagePickerAssetView *)assetView;
- (void)assetView:(QBImagePickerAssetView *)assetView didChangeSelectionState:(BOOL)selected;

@end
