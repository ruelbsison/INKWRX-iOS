//
//  IWConfirmationViewController.h
//  Inkworks
//
//  Created by Jamie Duggan on 23/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IWConfirmationViewController : UIViewController {
    __weak IBOutlet UIButton *doNotShowButton;
    __weak IBOutlet UILabel *detailsLabel;
    __weak IBOutlet UIBarButtonItem *okButton;
    __weak IBOutlet UIBarButtonItem *cancelButton;
    
    
}

@property (weak) IBOutlet UIButton *doNotShowButton;
@property (weak) IBOutlet UILabel *detailsLabel;
@property (weak) IBOutlet UIBarButtonItem *okButton;
@property (weak) IBOutlet UIBarButtonItem *cancelButton;


- (IBAction)doNotShowPressed;

@end
