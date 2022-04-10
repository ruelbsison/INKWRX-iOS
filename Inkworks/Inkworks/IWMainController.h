//
//  IWMainController.h
//  Inkworks
//
//  Created by Jamie Duggan on 13/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//



#define HISTORY_BUTTON_TAG 0
#define SENT_BUTTON_TAG 1
#define SENDING_BUTTON_TAG 2
#define PARKED_BUTTON_TAG 3

#import <UIKit/UIKit.h>
#import "IWContentController.h"
#import "IWHomeController.h"
#import "IWHistoryController.h"
#import "IWFormsListController.h"
#import "IWFormViewController.h"
#import "IWConfirmationViewController.h"
#import "IWAttachViewController.h"
#import "IWFormProcessor.h"
#import "IWAttachImageViewController.h"
@class IWGalleryViewController;


@interface IWMainController : UIViewController <UIAlertViewDelegate, UIPopoverControllerDelegate>{
#pragma mark Button Groups Instance
    __weak IBOutlet UIView *formButtons;
    __weak IBOutlet UIView *formViewButtons;
    __weak IBOutlet UIView *formListButtons;
    __weak IBOutlet UIView *historyButtons;
    
    __weak IBOutlet UIView *toolbar;
    
#pragma mark Navigation Buttons Instance
    __weak IBOutlet UIButton *inkworksButton;
    __weak IBOutlet UIButton *backButton;
    __weak IBOutlet UIButton *logoutButton;
    __weak IBOutlet UIButton *homeButton;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *titleHistoryLabel;
    __weak IBOutlet UIImageView *titleImage;
    NSString *windowTitle;
    
#pragma mark History Buttons Instance
    __weak IBOutlet UIButton *historyButton;
    __weak IBOutlet UIButton *historySentButton;
    __weak IBOutlet UIButton *historySendingButton;
    __weak IBOutlet UIButton *historyParkedButton;
    __weak IBOutlet UIButton *historyAutosavedButton;
    
#pragma mark Forms Buttons Instance
    __weak IBOutlet UIButton *formsButton;
    
    __weak IBOutlet UIButton *attachButton;
    __weak IBOutlet UIButton *clearButton;
    __weak IBOutlet UIButton *parkButton;
    __weak IBOutlet UIButton *sendButton;
    __weak IBOutlet UIButton *prepopButton;
    __weak IBOutlet UIButton *addFolderButton;
    __weak IBOutlet UIButton *removeFolderButton;
    __weak IBOutlet UIButton *prepopButton2;
    __weak IBOutlet UIButton *refreshButton;
    __weak IBOutlet UIButton *autoSaveButton;
    
#pragma mark Subview Instance
    __weak IBOutlet UIView *contentView;
    
    IWContentController *currentContent;
    NSString *currentView;

#pragma mark Popover controls
    UIPopoverController *controller;
    IWConfirmationViewController *vc;
    IWAttachViewController *attachVC;
    UIPopoverController *attachPopController;
    IWGalleryViewController *attachImageVC;
    UIPopoverController *attachImagePopController;
    UIActivityIndicatorView *spinner;
}



#pragma mark Button Groups
@property (weak, nonatomic) IBOutlet UIView *formButtons;
@property (weak, nonatomic) IBOutlet UIView *formViewButtons;
@property (weak, nonatomic) IBOutlet UIView *formListButtons;
@property (weak, nonatomic) IBOutlet UIView *historyButtons;

@property (weak, nonatomic) IBOutlet UIView *toolbar;

#pragma mark Navigation buttons
@property (weak, nonatomic) IBOutlet UIButton *inkworksButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleHistoryLabel;
@property (weak, nonatomic) IBOutlet UIImageView *titleImage;
@property (strong, nonatomic) NSString *windowTitle;

#pragma mark History Buttons
@property (weak, nonatomic) IBOutlet UIButton *historyButton;
@property (weak, nonatomic) IBOutlet UIButton *historySentButton;
@property (weak, nonatomic) IBOutlet UIButton *historySendingButton;
@property (weak, nonatomic) IBOutlet UIButton *historyParkedButton;
@property (weak, nonatomic) IBOutlet UIButton *historyAutosavedButton;

#pragma mark Forms Buttons
@property (weak, nonatomic) IBOutlet UIButton *formsButton;

@property (weak, nonatomic) IBOutlet UIButton *attachButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UIButton *parkButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (weak) IBOutlet UIButton *prepopButton;
@property (weak) IBOutlet UIButton *addFolderButton;
@property (weak) IBOutlet UIButton *removeFolderButton;
@property (weak) IBOutlet UIButton *prepopButton2;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak) IBOutlet UIButton *autoSaveButton;

#pragma mark Subview
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property IWContentController *currentContent;
@property NSString *currentView;

#pragma mark Popover controls

@property UIPopoverController *controller;
@property IWConfirmationViewController *vc;
@property IWAttachViewController *attachVC;
@property UIPopoverController *attachPopController;

@property IWGalleryViewController *attachImageVC;
@property UIPopoverController *attachImagePopController;
@property UIActivityIndicatorView *spinner;

#pragma mark IBActions
- (IBAction)historyButtonPressed:(id)sender;
- (IBAction)homeButtonPressed;
- (IBAction)backButtonPressed;

- (IBAction)formButtonPressed;
- (IBAction)attachButtonPressed;
- (IBAction)sendButtonPressed;
- (IBAction)parkButtonPressed;
- (IBAction)clearButtonPressed;

- (IBAction)addFolderPressed;
- (IBAction)removeFolderPressed;

- (IBAction)refreshButtonPressed;

#pragma mark Instance Methods
- (void) applyWindowTitle: (NSString *)title;
- (void) resetButtons;
- (IWFormProcessor *) formProcessor;
- (void) showAutoSaveButton:(BOOL)show;

- (void) setConnectionIndicatorOn:(BOOL) connOn;
- (void) goBack;
- (void) setPrepopButtonActive: (BOOL) active;

@end
