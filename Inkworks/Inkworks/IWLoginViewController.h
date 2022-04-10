//
//  IWLoginViewController.h
//  Inkworks
//
//  Created by Jamie Duggan on 02/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IWDestinyConstants.h"
#import "IWDestFormService.h"

@interface IWLoginViewController : UIViewController < UITextFieldDelegate, IWDestFormServiceDelegate>{
    __weak IBOutlet UILabel *versionLabel;
    __weak IBOutlet UITextField *usernameField;
    __weak IBOutlet UITextField *passwordField;
    __weak IBOutlet UIButton *rememberPasswordButton;
    __weak IBOutlet UIImageView *loginButton;
    __weak IBOutlet UILabel *deviceIdLabel;
    BOOL loginWorking;
//    FormDataWSProxy *service;
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UIActivityIndicatorView *activity;
    
}

@property BOOL loginWorking;
@property (weak) IBOutlet UILabel *versionLabel;
@property (weak) IBOutlet UITextField *usernameField;
@property (weak) IBOutlet UITextField *passwordField;
@property (weak) IBOutlet UIButton *rememberPasswordButton;
@property (weak) IBOutlet UIImageView *loginButton;
@property (weak) IBOutlet UILabel *deviceIdLabel;
//@property (nonatomic, retain) FormDataWSProxy *service;
@property (weak) IBOutlet UIScrollView *scrollView;
@property (weak) IBOutlet UIActivityIndicatorView *activity;

- (IBAction)privacyButtonPressed;
- (void)loginButtonPressed;
- (IBAction)rememberPasswordButtonPressed;

@end
