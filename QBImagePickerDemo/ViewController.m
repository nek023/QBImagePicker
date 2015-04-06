//
//  ViewController.m
//  QBImagePickerDemo
//
//  Created by Katsuma Tanaka on 2015/04/06.
//  Copyright (c) 2015 Katsuma Tanaka. All rights reserved.
//

#import "ViewController.h"
#import <QBImagePicker/QBImagePicker.h>

@interface ViewController () <QBImagePickerControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    QBImagePickerController *imagePickerController = [QBImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = (indexPath.section == 1);
    imagePickerController.showsNumberOfSelectedAssets = YES;
    
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                imagePickerController.maximumNumberOfSelection = 1;
                break;
                
            case 1:
                imagePickerController.minimumNumberOfSelection = 3;
                break;
                
            case 2:
                imagePickerController.maximumNumberOfSelection = 6;
                break;
                
            case 3:
                imagePickerController.minimumNumberOfSelection = 3;
                imagePickerController.maximumNumberOfSelection = 6;
                break;
                
            default:
                break;
        }
    }
    
    [self presentViewController:imagePickerController animated:YES completion:NULL];
}


#pragma mark - QBImagePickerControllerDelegate

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset
{
    NSLog(@"Selected asset:");
    NSLog(@"%@", asset);
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets
{
    NSLog(@"Selected assets:");
    NSLog(@"%@", assets);
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    NSLog(@"Canceled.");
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
