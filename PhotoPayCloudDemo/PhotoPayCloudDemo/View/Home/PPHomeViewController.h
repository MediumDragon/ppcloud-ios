//
//  PPHomeViewController.h
//  PhotoPayCloudDemo
//
//  Created by Jurica Cerovec on 9/7/13.
//  Copyright (c) 2013 PhotoPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PhotoPayCloud/PhotoPayCloud.h>

/**
 When opening PhotoPay, user sees view controlled by this view controller
 */
@interface PPHomeViewController : UIViewController<PPHomeViewControllerProtocol>

/**
 Loads the default XIB file for this view controller
 */
+ (NSString*)defaultXibName;

/**
 List of all scanned bills
 */
@property (weak, nonatomic) IBOutlet UITableView *billsTable;

/**
 Button which starts the photo capture
 */
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;

/**
 Callback on camera button pressed
 */
- (IBAction)cameraButtonPressed:(id)sender;

@end
