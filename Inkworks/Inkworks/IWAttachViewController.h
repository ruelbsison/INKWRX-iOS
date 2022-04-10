//
//  IWAttachViewController.h
//  Inkworks
//
//  Created by Jamie Duggan on 09/06/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IWAttachViewController : UIViewController{
    
    __weak IBOutlet UIButton *takePhotoButton;
    __weak IBOutlet UIButton *attachImageButton;
}

@property (weak) IBOutlet UIButton *takePhotoButton;
@property (weak) IBOutlet UIButton *attachImageButton;

@end
