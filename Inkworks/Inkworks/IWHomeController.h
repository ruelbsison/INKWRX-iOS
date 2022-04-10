//
//  IWHomeController.h
//  Inkworks
//
//  Created by Jamie Duggan on 13/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWContentController.h"

@interface IWHomeController : IWContentController {
    
}

@property (weak) IBOutlet UILabel *formsLabel;
@property (weak) IBOutlet UILabel *historyAllLabel;
@property (weak) IBOutlet UILabel *historySendingLabel;
@property (weak) IBOutlet UILabel *historyParkedLabel;
@property (weak) IBOutlet UILabel *historySentLabel;
@property (weak) IBOutlet UILabel *historyIndicatorLabel;
@property (weak) IBOutlet UILabel *prepopLabel;

@property (weak) IBOutlet UIView *formsButton;
@property (weak) IBOutlet UIView *historyAllButton;
@property (weak) IBOutlet UIView *historySendingButton;
@property (weak) IBOutlet UIView *historySentButton;
@property (weak) IBOutlet UIView *historyParkedButton;
@property (weak) IBOutlet UIView *prepopButton;

@property (weak) IBOutlet UIView *historyAutoSavedButton;
@property (weak) IBOutlet UILabel *historyAutoSavedLabel;

- (IBAction) formsClicked;
- (IBAction) historyAllClicked:(id)sender;
- (IBAction) historySendingClicked:(id)sender;
- (IBAction) historyParkedClicked:(id)sender;
- (IBAction) historySentClicked:(id)sender;
- (IBAction) prepopClicked:(id)sender;
- (IBAction) historyAutoSavedClicked:(id)sender;

- (void) refreshIndicators;
@property NSMutableDictionary *done;

@end
