//
//  ViewController.m
//  QBImagePickerDemo
//
//  Created by Katsuma Tanaka on 2015/04/05.
//  Copyright (c) 2015年 Katsuma Tanaka. All rights reserved.
//

#import "ViewController.h"
#import <QBImagePicker/QBImagePicker.h>

@interface ViewController () <QBImagePickerControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![QBImagePickerController isAccessible]) {
        NSLog(@"Error: Source is not accessible.");
    }
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    QBImagePickerController *imagePickerController = [QBImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = (indexPath.section == 1);
    
    if (indexPath.section == 1) {
        switch (indexPath.row) {
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
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        [self.navigationController pushViewController:imagePickerController animated:YES];
    } else {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
        [self presentViewController:navigationController animated:YES completion:NULL];
    }
}

- (void)dismissImagePickerController
{
    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    } else {
        [self.navigationController popToViewController:self animated:YES];
    }
}


#pragma mark - QBImagePickerControllerDelegate

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset
{
    NSLog(@"*** qb_imagePickerController:didSelectAsset:");
    NSLog(@"%@", asset);
    
    [self dismissImagePickerController];
}

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets
{
    NSLog(@"*** qb_imagePickerController:didSelectAssets:");
    NSLog(@"%@", assets);
    
    [self dismissImagePickerController];
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    NSLog(@"*** qb_imagePickerControllerDidCancel:");
    
    [self dismissImagePickerController];
}

@end
