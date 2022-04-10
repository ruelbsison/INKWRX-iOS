//
//  IWFormViewController.h
//  Inkworks
//
//  Created by Jamie Duggan on 13/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWContentController.h"
#import "IWFormRenderer.h"
#import "IWFormProcessor.h"

@interface IWFormViewController : IWContentController <UIScrollViewDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate> {
    __weak IBOutlet UIScrollView *scrollView;
    UIView *canvas;
    __weak IBOutlet UIBarButtonItem *pageIndicator;
    __weak IBOutlet UIBarButtonItem *ofIndicator;
    __weak IBOutlet UIBarButtonItem *backButton;
    __weak IBOutlet UIBarButtonItem *forwardButton;
    IWFormRenderer *renderer;
    IWFormProcessor *processor;
    UITableView *pageTable;
    UIPopoverController *pagePopoverController;
    NSDate *startDate;
    NSTimer *autoSaveTimer;
    float autoSaveInterval;
    
}

@property (weak) IBOutlet UIScrollView *scrollView;
@property UIView *canvas;
@property (weak) IBOutlet UIBarButtonItem *pageIndicator;
@property (weak) IBOutlet UIBarButtonItem *ofIndicator;
@property (retain, strong) UITableView *pageTable;
@property (retain, strong) UIPopoverController *pagePopoverController;
@property (weak) IBOutlet UIBarButtonItem *backButton;
@property (weak) IBOutlet UIBarButtonItem *forwardButton;
@property (retain, strong) NSTimer *autoSaveTimer;
@property (retain, strong) IWFormRenderer *renderer;
@property (retain, strong) IWFormProcessor *processor;
@property float autoSaveInterval;

@property NSDate *startDate;

- (void) autoSaveTimerTicked;
- (IBAction)backButtonPressed:(id)sender;
- (IBAction)forwardButtonPressed:(id)sender;
- (IBAction) pageIndicatorPressed:(id)sender;
- (void) parkForm;
- (void) clearForm;
- (void) sendForm;
- (void) setPopoverSize;
@end
