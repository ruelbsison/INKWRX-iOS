//
//  IWFormViewController.m
//  Inkworks
//
//  Created by Jamie Duggan on 13/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWFormViewController.h"
#import "IWIsoSubField.h"
#import "MBProgressHUD.h"
#import "IWPageServer.h"
#import "IWDataChangeHandler.h"
#import "Inkworks-Swift.h"
#import "IWDropDown.h"
#import "IWMainController.h"
#import "IWPageDescriptor.h"

@interface IWFormViewController ()

@end

@implementation IWFormViewController

@synthesize scrollView, canvas, pageIndicator, ofIndicator, forwardButton, backButton, renderer, processor, startDate, pageTable, pagePopoverController, autoSaveTimer, autoSaveInterval;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) init{
    self = [super init];
    
    if (self) {
        self.windowTitle = [NSString stringWithFormat:@"FORM [%@]", [IWInkworksService getInstance].currentViewedForm.FormName];
        self.viewName = FORM_VIEW_CONTENT_NAME;
    }
    
    return self;
}

- (void)autoSaveTimerTicked {
    if (self.processor != nil) {
        IWPageDescriptor *currentPage = nil;
        for (IWPageDescriptor *p in renderer.pageServer.servedPages) {
            NSLog(@"%d",[renderer.pageServer getModdedPageNumber:p.pageNumber - 1]);
            
            if ([renderer.pageServer getModdedPageNumber:p.pageNumber - 1] == renderer.pageToRender) {
                currentPage = p;
                break;
            }
        }
        
        IWMainController *main = (IWMainController *)[IWInkworksService getInstance].mainInstance;
        dispatch_async(dispatch_get_main_queue(), ^{
            [main.autoSaveButton setHidden:NO];
        });
        //[main performSelectorOnMainThread:@selector(showAutoSaveButton:) withObject:@(YES) waitUntilDone:YES];
        [processor saveFormForSending:NO onPageNumber:[NSNumber numberWithInt:currentPage.pageNumber - 1] dictionary:[renderer allViews] radios:[renderer radioGroupManagers] renderer:renderer autoSave:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [main.autoSaveButton setHidden:YES];
            //[main performSelectorOnMainThread:@selector(showAutoSaveButton:) withObject:nil waitUntilDone:YES];
        });
        
        self.autoSaveTimer = [NSTimer scheduledTimerWithTimeInterval:self.autoSaveInterval target:self selector:@selector(autoSaveTimerTicked) userInfo:nil repeats:NO];
    }
}

- (IBAction) pageIndicatorPressed: (id) sender {
    int sizeMult = renderer.pageServer.servedPages.count > 10 ? 10 : renderer.pageServer.servedPages.count;
    
    UIView *popOverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 50 * sizeMult)];
    
    CGRect tableFrame = CGRectMake(popOverView.frame.origin.x, popOverView.frame.origin.y, popOverView.frame.size.width, popOverView.frame.size.height - 10);
    
    pageTable = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    pageTable.separatorInset = UIEdgeInsetsZero;
    
    [pageTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    [pageTable setDelegate:self];
    [pageTable setDataSource:self];
    
    
    pageTable.separatorColor = [UIColor whiteColor];
    
    [popOverView addSubview:pageTable];
    
    UIViewController *popoverViewController = [[UIViewController alloc] init];
    popoverViewController.view = popOverView;
    
    pagePopoverController = [[UIPopoverController alloc] initWithContentViewController:popoverViewController];
    
    //28628E
    pagePopoverController.delegate = self;
    pagePopoverController.backgroundColor = [UIColor colorWithRed:40 green:98 blue:142 alpha:1];
    
    CGRect contentSize = popOverView.frame;
    pagePopoverController.popoverContentSize = contentSize.size;
        [pageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:renderer.pageToRender inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    [pagePopoverController presentPopoverFromBarButtonItem:pageIndicator permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return canvas;
}
-(void)loadCanvas {
    while (!self.renderer.isFormDescriptorReady) {
        //Loop while not ready
    }
    [self performSelectorOnMainThread:@selector(loadCanvasDetails) withObject:nil waitUntilDone:YES];
    
    [self.renderer performSelectorOnMainThread:@selector(recalculateFields) withObject:nil waitUntilDone:YES];
}
-(void)loadCanvasDetails {
    [self.renderer renderCanvas];
    
    [[IWInkworksService getInstance] startStandardUpdates];
    [IWInkworksService getInstance].formViewController = self;
    self.canvas = self.renderer.formCanvas;
    self.canvas.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.canvas.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
    self.canvas.layer.shadowRadius = 10.0f;
    self.canvas.layer.masksToBounds = NO;
    self.canvas.layer.shadowOpacity = 0.5f;
    [self.scrollView addSubview:self.canvas];
    [self.scrollView setContentSize:self.canvas.frame.size];
    CGRect zoomRect = CGRectMake(-20.0, 0.0, canvas.bounds.size.width + 40.0, 10.0);
    
    [self.scrollView zoomToRect:zoomRect animated:NO];
    
    if ([IWInkworksService getInstance].currentViewedTransaction == nil){
        startDate = [NSDate date];
    } else {
        startDate = [IWInkworksService getInstance].currentViewedTransaction.AddedDate;
    }
    if ([[IWInkworksService getInstance].currentViewedTransaction.Status isEqualToString:@"Sent"]) {
        startDate = [NSDate date];
    }
    processor = [[IWFormProcessor alloc] initWithDescriptor:renderer.formDescriptor listItem:[IWInkworksService getInstance].currentViewedForm canvas:canvas transaction:[IWInkworksService getInstance].currentViewedTransaction startDate: startDate];
    if ([IWInkworksService getInstance].currentAutoSavedTransaction != nil) {
        processor.autoSavedTransaction = [IWInkworksService getInstance].currentAutoSavedTransaction;
        [IWInkworksService getInstance].currentAutoSavedTransaction = nil;
    }
    
    [IWInkworksService getInstance].currentProcessor = processor;
    if ([IWInkworksService getInstance].currentViewedTransaction != nil){
        if (processor.autoSavedTransaction != nil) {
            [processor loadPageDataFromParked:processor.autoSavedTransaction.PenDataXml strokes:processor.autoSavedTransaction.StrokesXml];
        } else {
            [processor loadPageDataFromParked:[IWInkworksService getInstance].currentViewedTransaction.PenDataXml strokes:[IWInkworksService getInstance].currentViewedTransaction.StrokesXml];
        }
        //if (![[IWInkworksService getInstance].currentViewedTransaction.status isEqualToString:@"Sent"]) {
            [processor loadParkedImages];
        //}
    } else if (processor.autoSavedTransaction != nil) {
        [processor loadPageDataFromParked:processor.autoSavedTransaction.PenDataXml strokes:processor.autoSavedTransaction.StrokesXml];
        [processor loadParkedImages];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [renderer recalculateFields];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [renderer recalculateFields];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [renderer recalculateFields];
    });
    
    if ([[IWInkworksService getInstance].currentViewedTransaction.Status isEqualToString:@"Sent"]) {
        [IWInkworksService getInstance].currentViewedTransaction.Status = @"Parked";
        startDate = [NSDate date];
        processor.startDate = startDate;
        [IWInkworksService getInstance].currentViewedTransaction.AddedDate = startDate;
        [IWInkworksService getInstance].currentViewedTransaction.ColumnIndex = NSNotFound;
    }
    processor.currentPageToSave = 0;
    for (NSNumber *pageInfoKey in processor.pageStrings.keyEnumerator) {
        NSDictionary *pageInfo = processor.pageStrings[pageInfoKey];
        [renderer loadForm:pageInfo];
    }
    if ([processor.pageStrings objectForKey:[NSNumber numberWithInt:0]] != nil){
        NSDictionary *pageInfo = [processor.pageStrings objectForKey:[NSNumber numberWithInt:0]];
        [renderer loadForm:pageInfo];
    }
//    if ([processor.pageStrings objectForKey:[NSNumber numberWithInt:0]] != nil){
//        NSDictionary *pageInfo = [processor.pageStrings objectForKey:[NSNumber numberWithInt:0]];
//        [renderer loadForm:pageInfo];
//        
//    }

    [renderer loadPrepopData];
    for (NSDictionary *dict in processor.pageStrings.objectEnumerator) {
        [renderer loadMandatoryFields:dict];
    }
    
    if ([renderer.pageServer canGoForwardFrom:renderer.pageToRender] == -1) {
        backButton.enabled = NO;
        forwardButton.enabled = NO;
    } else {
        backButton.enabled = NO;
    }
    
    [pageIndicator setTitle:[NSString stringWithFormat:@"Page %i \u25BC", renderer.pageToRender + 1]];
    [ofIndicator setTitle:[NSString stringWithFormat:@"of %i", renderer.pageServer.servedPages.count]];
    [self setPopoverSize];
    
    [IWDataChangeHandler getInstance].dataChanged = NO;
    
    //CGFloat newContentOffsetX = (scrollView.contentSize.width/2) - (scrollView.bounds.size.width/2);
    //[scrollView setContentInset:UIEdgeInsetsMake(0, newContentOffsetX, 0, newContentOffsetX)];
    
    
}

- (void) setPopoverSize {
    
    int sizeMult = renderer.pageServer.servedPages.count > 10 ? 10 : renderer.pageServer.servedPages.count;
    
    UIView *popOverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 50 * sizeMult)];
    
    CGRect tableFrame = CGRectMake(popOverView.frame.origin.x, popOverView.frame.origin.y, popOverView.frame.size.width, popOverView.frame.size.height - 10);
    [pageTable setFrame:tableFrame];
    [pageTable setNeedsDisplay];
    [pageTable setNeedsLayout];
    [pagePopoverController.contentViewController.view layoutSubviews];
    
    CGRect contentSize = popOverView.frame;
    pagePopoverController.popoverContentSize = contentSize.size;
    [self.pageTable reloadData];
            [pageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:renderer.pageToRender inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.autoSaveInterval = 120;
    // Do any additional setup after loading the view.
    [self registerForKeyboardNotifications];
    self.renderer = [[IWFormRenderer alloc] initWithItem:[IWInkworksService getInstance].currentViewedForm andTransaction:[IWInkworksService getInstance].currentViewedTransaction];
    [IWInkworksService getInstance].currentRenderer = self.renderer;
    renderer.mainDelegate = [IWInkworksService getInstance] ;
    self.scrollView.frame = self.scrollView.superview.frame;
    self.renderer.pageToRender = [self.renderer.pageServer getModdedPageNumber:[self.renderer.pageServer getFirstPageNumber]];
    [self.renderer renderForm];
    [self performSelectorInBackground:@selector(loadCanvas) withObject:nil];
    
    //NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("orientationChanged"), name: UIDeviceOrientationDidChangeNotification, object: nil);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationSwitch) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    UIView *popOverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 50 * renderer.pageServer.servedPages.count)];
    
    CGRect tableFrame = CGRectMake(popOverView.frame.origin.x, popOverView.frame.origin.y, popOverView.frame.size.width, popOverView.frame.size.height - 10);
    
    pageTable = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    pageTable.separatorInset = UIEdgeInsetsZero;
    
    [pageTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    [pageTable setDelegate:self];
    [pageTable setDataSource:self];
    
    
    pageTable.separatorColor = [UIColor whiteColor];
    
    [popOverView addSubview:pageTable];
    
    UIViewController *popoverViewController = [[UIViewController alloc] init];
    popoverViewController.view = popOverView;
    
    pagePopoverController = [[UIPopoverController alloc] initWithContentViewController:popoverViewController];
    
    //28628E
    pagePopoverController.delegate = self;
    pagePopoverController.backgroundColor = [UIColor colorWithRed:40 green:98 blue:142 alpha:1];
    pagePopoverController.popoverContentSize = popOverView.frame.size;
    if (self.autoSaveTimer != nil) {
        [self.autoSaveTimer invalidate];
    }
    self.autoSaveTimer = [NSTimer scheduledTimerWithTimeInterval:self.autoSaveInterval target:self selector:@selector(autoSaveTimerTicked) userInfo:nil repeats:NO];
}



- (void)orientationSwitch {
    if ([pagePopoverController isPopoverVisible]) {
        [pagePopoverController dismissPopoverAnimated:NO];
        UIView *popOverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 50 * renderer.pageServer.servedPages.count)];
        
        CGRect tableFrame = CGRectMake(popOverView.frame.origin.x, popOverView.frame.origin.y, popOverView.frame.size.width, popOverView.frame.size.height - 10);
        
        pageTable = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
        pageTable.separatorInset = UIEdgeInsetsZero;
        
        [pageTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        
        [pageTable setDelegate:self];
        [pageTable setDataSource:self];
        
        
        pageTable.separatorColor = [UIColor whiteColor];
        
        [popOverView addSubview:pageTable];
        
        UIViewController *popoverViewController = [[UIViewController alloc] init];
        popoverViewController.view = popOverView;
        
        pagePopoverController = [[UIPopoverController alloc] initWithContentViewController:popoverViewController];
        
        //28628E
        pagePopoverController.delegate = self;
        pagePopoverController.backgroundColor = [UIColor colorWithRed:40 green:98 blue:142 alpha:1];
        pagePopoverController.popoverContentSize = popOverView.frame.size;
        
        
        [pagePopoverController presentPopoverFromBarButtonItem:pageIndicator permittedArrowDirections:UIPopoverArrowDirectionDown animated:NO];
    }
    
    BOOL landscape = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
    CGRect newFrame = CGRectMake(0, 0, landscape? 1024 : 768, landscape? 668: 924);
    scrollView.pagingEnabled = NO;
    scrollView.frame = newFrame;
    scrollView.bounds = newFrame;
    
    scrollView.contentSize = canvas.bounds.size;
    CGRect zoomRect = CGRectMake(-20.0, 0.0, canvas.bounds.size.width + 40, 10.0);
    

    [self.scrollView zoomToRect:zoomRect animated:NO];
    self.scrollView.zoomScale += 0.0001;
    [self.scrollView layoutSubviews];
    [self.scrollView setNeedsLayout];
    
    
    //[self.scrollView setContentOffset: CGPointMake(-20.0 * self.scrollView.zoomScale,0.0)];
    
    
    [((IWMainController *)[IWInkworksService getInstance].mainInstance) resetButtons];
}

- (void)viewDidDisappear:(BOOL)animated {
    [IWInkworksService getInstance].formViewController = nil;
    [IWInkworksService getInstance].scrollView = nil;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [IWInkworksService getInstance].formViewController = self;
    [IWInkworksService getInstance].scrollView = scrollView;
    [scrollView setNeedsLayout];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)backButtonPressed:(id)sender {
    IWPageDescriptor *page = nil;
    for (IWPageDescriptor *pg in renderer.pageServer.servedPages) {
        if ([renderer.pageServer getModdedPageNumber:pg.pageNumber - 1] == renderer.pageToRender) {
            page = pg;
            break;
        }
    }
    if ([renderer.pageServer canGoBackFrom:page.pageNumber - 1] == -1) return;
    BOOL dataChanged = [IWDataChangeHandler getInstance].dataChanged;
    [self.processor savePage:[NSNumber numberWithInt:page.pageNumber - 1] forSending:NO fields:self.renderer.allViews radios:renderer.radioGroupManagers  renderer:renderer];
    
    renderer.pageToRender--;
            [pageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:renderer.pageToRender inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    for (IWPageDescriptor *pg in renderer.pageServer.servedPages) {
        if ([renderer.pageServer getModdedPageNumber:pg.pageNumber - 1] == renderer.pageToRender) {
            page = pg;
            break;
        }
    }
    
    for (UIView *v in scrollView.subviews){
        [v removeFromSuperview];
    }
    [renderer renderCanvas];
    [[IWInkworksService getInstance] startStandardUpdates];
    canvas = renderer.formCanvas;
    self.canvas.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.canvas.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
    self.canvas.layer.shadowRadius = 10.0f;
    self.canvas.layer.masksToBounds = NO;
    self.canvas.layer.shadowOpacity = 0.5f;
    [scrollView addSubview:canvas];
    scrollView.contentSize = canvas.frame.size;
    
    
    CGRect zoomRect = CGRectMake(-20.0, 0.0, canvas.bounds.size.width + 40.0, 10.0);
    [self.scrollView zoomToRect:zoomRect animated:NO];
    [scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];

    [pageIndicator setTitle:[NSString stringWithFormat:@"Page %i \u25BC", renderer.pageToRender + 1]];
    [ofIndicator setTitle:[NSString stringWithFormat:@"of %i", renderer.pageServer.servedPages.count]];
    [self setPopoverSize];
    if ([processor.pageStrings objectForKey:[NSNumber numberWithInt:page.pageNumber - 1]] != nil){
        NSDictionary *pageInfo = [processor.pageStrings objectForKey:[NSNumber numberWithInt:page.pageNumber - 1]];
        [renderer loadForm:pageInfo];
        
    }
    [renderer loadPrepopData];
    [IWDataChangeHandler getInstance].dataChanged = dataChanged;
    if ([renderer.pageServer canGoBackFrom:page.pageNumber - 1] == -1) backButton.enabled = NO;
        else backButton.enabled = YES;
    if ([renderer.pageServer canGoForwardFrom:page.pageNumber - 1] == -1) forwardButton.enabled = NO;
        else forwardButton.enabled = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [renderer recalculateFields];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [renderer recalculateFields];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [renderer recalculateFields];
    });
}

- (IBAction)forwardButtonPressed:(id)sender {
    IWPageDescriptor *page = nil;
    for (IWPageDescriptor *pg in renderer.pageServer.servedPages) {
        if ([renderer.pageServer getModdedPageNumber:pg.pageNumber - 1] == renderer.pageToRender) {
            page = pg;
            break;
        }
    }
    if ([renderer.pageServer canGoForwardFrom:page.pageNumber - 1] == -1) return;
    BOOL dataChanged = [IWDataChangeHandler getInstance].dataChanged;
    [self.processor savePage:[NSNumber numberWithInt:page.pageNumber - 1] forSending:NO fields:self.renderer.allViews radios:self.renderer.radioGroupManagers renderer:renderer];
    
    renderer.pageToRender++;
            [pageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:renderer.pageToRender inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    for (IWPageDescriptor *pg in renderer.pageServer.servedPages) {
        if ([renderer.pageServer getModdedPageNumber:pg.pageNumber - 1] == renderer.pageToRender) {
            page = pg;
            break;
        }
    }
    for (UIView *v in scrollView.subviews){
        [v removeFromSuperview];
    }
    [renderer renderCanvas];
    [[IWInkworksService getInstance] startStandardUpdates];
    canvas = renderer.formCanvas;
    self.canvas.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.canvas.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
    self.canvas.layer.shadowRadius = 10.0f;
    self.canvas.layer.masksToBounds = NO;
    self.canvas.layer.shadowOpacity = 0.5f;
    [scrollView addSubview:canvas];
    scrollView.contentSize = canvas.frame.size;
    
    CGRect zoomRect = CGRectMake(-20.0, 0.0, canvas.bounds.size.width + 40.0, 10.0);
    [self.scrollView zoomToRect:zoomRect animated:NO];
    [scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    
    [pageIndicator setTitle:[NSString stringWithFormat:@"Page %i \u25BC", renderer.pageToRender + 1]];
    [ofIndicator setTitle:[NSString stringWithFormat:@"of %i", renderer.pageServer.servedPages.count]];
    [self setPopoverSize];
    if ([processor.pageStrings objectForKey:[NSNumber numberWithInt:page.pageNumber - 1]] != nil){
        NSDictionary *pageInfo = [processor.pageStrings objectForKey:[NSNumber numberWithInt:page.pageNumber - 1]];
        [renderer loadForm:pageInfo];
    }
    [renderer loadPrepopData];
    [IWDataChangeHandler getInstance].dataChanged = dataChanged;
    
    if ([renderer.pageServer canGoBackFrom:page.pageNumber - 1] == -1) backButton.enabled = NO;
    else backButton.enabled = YES;
    if ([renderer.pageServer canGoForwardFrom:page.pageNumber - 1] == -1) forwardButton.enabled = NO;
    else forwardButton.enabled = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [renderer recalculateFields];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [renderer recalculateFields];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [renderer recalculateFields];
    });
}

- (void)parkForm {
    
    IWPageDescriptor *currentPage = nil;
    for (IWPageDescriptor *p in renderer.pageServer.servedPages) {
        NSLog(@"%d",[renderer.pageServer getModdedPageNumber:p.pageNumber - 1]);
        
        if ([renderer.pageServer getModdedPageNumber:p.pageNumber - 1] == renderer.pageToRender) {
            currentPage = p;
            break;
        }
    }
    
    [processor saveFormForSending:NO onPageNumber:[NSNumber numberWithInt:currentPage.pageNumber - 1] dictionary:[renderer allViews] radios:[renderer radioGroupManagers] renderer:renderer];
    [IWDataChangeHandler getInstance].openedFromAutosave = NO;
    if (processor.autoSavedTransaction != nil) {
        [self.autoSaveTimer invalidate];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self autoSaveTimerTicked];
        });
    }
    
    [IWInkworksService getInstance].currentViewedTransaction = processor.originalTransaction;
    if (processor.originalTransaction.PrepopId != -1) {
        IWSwiftDbHelper *swift = [IWInkworksService dbHelper];
        IWPrepopForm *ppf = [swift getPrepopForm:processor.originalTransaction.PrepopId];
        if (ppf) {
            ppf.PrepopStatus = 1;
            [swift addOrUpdatePrepopForm:ppf];
        }
    }
    [IWDataChangeHandler getInstance].dataChanged = NO;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[IWInkworksService getInstance].mainInstance.view animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"Form parked";
    hud.margin = 10.f;
    hud.yOffset = -150.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:2];
}

- (void)sendForm {
    
    processor.renderer = renderer;
    
    IWPageDescriptor *currentPage = nil;
    for (IWPageDescriptor *p in renderer.pageServer.servedPages) {
        NSLog(@"%d",[renderer.pageServer getModdedPageNumber:p.pageNumber - 1]);
        
        if ([renderer.pageServer getModdedPageNumber:p.pageNumber - 1] == renderer.pageToRender) {
            currentPage = p;
            break;
        }
    }
    BOOL saved = [processor saveFormForSending:YES onPageNumber:[NSNumber numberWithInt:currentPage.pageNumber - 1] dictionary:[renderer allViews] radios:[renderer radioGroupManagers] renderer:renderer];
    
    if (!saved) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mandatory Fields" message:@"Form not sent - please complete mandatory fields highlighted in red" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        
        return;
    }
    [self.autoSaveTimer invalidate];
    if (processor.originalTransaction.PrepopId != -1) {
        IWSwiftDbHelper *swift = [IWInkworksService dbHelper];
        IWPrepopForm *ppf = [swift getPrepopForm:processor.originalTransaction.PrepopId];
        if (ppf) {
            ppf.PrepopStatus = 2;
            [swift addOrUpdatePrepopForm:ppf];
        }
    }
    
    
    
    [IWDataChangeHandler getInstance].dataChanged = NO;
    [IWDataChangeHandler getInstance].openedFromAutosave = NO;
    [((IWMainController *)[IWInkworksService getInstance].mainInstance) goBack];
    //removed to go back instead of refreshing form...
//
//    [IWInkworksService getInstance].currentViewedTransaction = nil;
//    renderer.pageToRender = 0;
//    for (UIView *v in scrollView.subviews){
//        [v removeFromSuperview];
//    }
//    [renderer renderCanvas];
//    canvas = renderer.formCanvas;
//    self.canvas.layer.shadowColor = [[UIColor blackColor] CGColor];
//    self.canvas.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
//    self.canvas.layer.shadowRadius = 10.0f;
//    self.canvas.layer.masksToBounds = NO;
//    self.canvas.layer.shadowOpacity = 0.5f;
//    [scrollView addSubview:canvas];
//    scrollView.contentSize = canvas.frame.size;
//    [pageIndicator setTitle:[NSString stringWithFormat:@"Page %i of %i", renderer.pageToRender + 1, renderer.pageCount]];
//    
//    processor = [[IWFormProcessor alloc] initWithDescriptor:processor.formDescriptor listItem:processor.listItem canvas:canvas transaction:nil startDate:[NSDate date]];
//    [IWInkworksService getInstance].currentProcessor = processor;
//    if (renderer.pageToRender == 0) backButton.enabled = NO;
//    else backButton.enabled = YES;
//    if (renderer.pageToRender + 1 == renderer.pageCount) forwardButton.enabled = NO;
//    else forwardButton.enabled = YES;
//    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[IWInkworksService getInstance].mainInstance.view animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"Form saved for sending";
    hud.margin = 10.f;
    hud.yOffset = -150.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:2];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqualToString:@"Delete Form"]){
        if (buttonIndex == 0) {
            [[IWInkworksService dbHelper] removeTransaction:[IWInkworksService getInstance].currentViewedTransaction clearPrepop:NO];
            if ([IWInkworksService getInstance].currentViewedTransaction.PrepopId != -1) {
                IWSwiftDbHelper *swift = [IWInkworksService dbHelper];
                IWPrepopForm *ppf = [swift getPrepopForm:processor.originalTransaction.PrepopId];
                if (ppf) {
                    ppf.PrepopStatus = 0;
                    [swift addOrUpdatePrepopForm:ppf];
                }
            }
            [[IWInkworksService getInstance].mainInstance performSegueWithIdentifier:@"ParkedHistorySegue" sender:self];
            [IWDataChangeHandler getInstance].openedFromAutosave = NO;
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
            if (processor.autoSavedTransaction != nil) {
                IWTransaction *ast = (IWTransaction *)processor.autoSavedTransaction;
                if (ast.ColumnIndex != NSNotFound && ast.ColumnIndex != -1) {
                    [[IWInkworksService dbHelper] removeTransaction:ast clearPrepop:NO];
                }
            }
            [self.autoSaveTimer invalidate];
            self.autoSaveTimer = [NSTimer scheduledTimerWithTimeInterval:self.autoSaveInterval target:self selector:@selector(autoSaveTimerTicked) userInfo:nil repeats:NO];
            processor.autoSavedTransaction = nil;
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[IWInkworksService getInstance].mainInstance.view animated:YES];
            
            // Configure for text only and offset down
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"Parked form deleted";
            hud.margin = 10.f;
            hud.yOffset = 150.f;
            hud.removeFromSuperViewOnHide = YES;
            
            [hud hide:YES afterDelay:3];
        }
    } else if ([alertView.title isEqualToString:@"Clear Form"]) {
        if (buttonIndex == 0) {
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
            [IWInkworksService getInstance].currentViewedTransaction = nil;
            if (processor.autoSavedTransaction != nil) {
                IWTransaction *ast = (IWTransaction *)processor.autoSavedTransaction;
                if (ast.ColumnIndex != NSNotFound && ast.ColumnIndex != -1) {
                    [[IWInkworksService dbHelper] removeTransaction:ast clearPrepop:NO];
                }
            }
            [self.autoSaveTimer invalidate];
            self.autoSaveTimer = [NSTimer scheduledTimerWithTimeInterval:self.autoSaveInterval target:self selector:@selector(autoSaveTimerTicked) userInfo:nil repeats:NO];
            processor.autoSavedTransaction = nil;
            self.renderer = [[IWFormRenderer alloc] initWithItem:[IWInkworksService getInstance].currentViewedForm andTransaction:nil];
            [IWInkworksService getInstance].currentRenderer = self.renderer;
            renderer.mainDelegate = [IWInkworksService getInstance] ;
            renderer.pageToRender = [self.renderer.pageServer getFirstPageNumber];
            for (UIView *v in scrollView.subviews){
                [v removeFromSuperview];
            }
            [renderer renderForm];
            //[renderer renderCanvas];
            [self performSelectorInBackground:@selector(loadCanvas) withObject:nil];
            [IWDataChangeHandler getInstance].openedFromAutosave = NO;
            /*
            canvas = renderer.formCanvas;
            self.canvas.layer.shadowColor = [[UIColor blackColor] CGColor];
            self.canvas.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
            self.canvas.layer.shadowRadius = 10.0f;
            self.canvas.layer.masksToBounds = NO;
            self.canvas.layer.shadowOpacity = 0.5f;
            [scrollView addSubview:canvas];
            scrollView.contentSize = canvas.frame.size;
            CGRect zoomRect = CGRectMake(-20.0, 0.0, canvas.bounds.size.width + 40.0, 10.0);
            
            [self.scrollView zoomToRect:zoomRect animated:NO];
            
            [pageIndicator setTitle:[NSString stringWithFormat:@"Page %i \u25BC", [renderer.pageServer getModdedPageNumber:renderer.pageToRender] + 1]];
            [ofIndicator setTitle:[NSString stringWithFormat:@"of %i", renderer.pageServer.servedPages.count]];
            [self setPopoverSize];
            processor = [[IWFormProcessor alloc] initWithDescriptor:processor.formDescriptor listItem:processor.listItem canvas:canvas transaction:nil startDate:[NSDate date]];
            [renderer loadPrepopData];
            if (renderer.pageToRender == 0) backButton.enabled = NO;
            else backButton.enabled = YES;
            if (renderer.pageToRender + 1 == renderer.pageCount) forwardButton.enabled = NO;
            else forwardButton.enabled = YES;
            */
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[IWInkworksService getInstance].mainInstance.view animated:YES];
            
            // Configure for text only and offset down
            hud.exclusiveTouch = NO;
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"Form cleared";
            hud.margin = 10.f;
            hud.yOffset = -150.f;
            hud.removeFromSuperViewOnHide = YES;
            
            [hud hide:YES afterDelay:2];

        }
    }
}

- (void)clearForm {
    if ([IWInkworksService getInstance].currentViewedTransaction != nil){
        UIAlertView *alert = [[UIAlertView alloc] init];
        [alert setTitle:@"Delete Form"];
        [alert setMessage:@"This will delete the parked form permanently without sending. Are you sure?"];
        [alert addButtonWithTitle:@"Ok"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setCancelButtonIndex:1];
        [alert setDelegate:self];
        [alert show];
        
    } else {
        
        if ([IWDataChangeHandler getInstance].dataChanged || [IWDataChangeHandler getInstance].openedFromAutosave) {
            UIAlertView *alert = [[UIAlertView alloc] init];
            [alert setTitle:@"Clear Form"];
            [alert setMessage:@"This will clear the form, losing all the unsaved changes. Are you sure?"];
            [alert addButtonWithTitle:@"Ok"];
            [alert addButtonWithTitle:@"Cancel"];
            [alert setCancelButtonIndex:1];
            [alert setDelegate:self];
            [alert show];
        } else {
            [IWInkworksService getInstance].currentViewedTransaction = nil;
            if (processor.autoSavedTransaction != nil) {
                IWTransaction *ast = (IWTransaction *)processor.autoSavedTransaction;
                if (ast.ColumnIndex != NSNotFound && ast.ColumnIndex != -1) {
                    [[IWInkworksService dbHelper] removeTransaction:ast clearPrepop:NO];
                }
            }
            [self.autoSaveTimer invalidate];
            self.autoSaveTimer = [NSTimer scheduledTimerWithTimeInterval:self.autoSaveInterval target:self selector:@selector(autoSaveTimerTicked) userInfo:nil repeats:NO];
            processor.autoSavedTransaction = nil;
            self.renderer = [[IWFormRenderer alloc] initWithItem:[IWInkworksService getInstance].currentViewedForm andTransaction:nil];
            [IWInkworksService getInstance].currentRenderer = self.renderer;
            renderer.mainDelegate = [IWInkworksService getInstance] ;
            renderer.pageToRender = [self.renderer.pageServer getFirstPageNumber];
            for (UIView *v in scrollView.subviews){
                [v removeFromSuperview];
            }
            [renderer renderForm];
            [self performSelectorInBackground:@selector(loadCanvas) withObject:nil];
//            [[IWInkworksService getInstance] startStandardUpdates];
//            canvas = renderer.formCanvas;
//            self.canvas.layer.shadowColor = [[UIColor blackColor] CGColor];
//            self.canvas.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
//            self.canvas.layer.shadowRadius = 10.0f;
//            self.canvas.layer.masksToBounds = NO;
//            self.canvas.layer.shadowOpacity = 0.5f;
//            [scrollView addSubview:canvas];
//            scrollView.contentSize = canvas.frame.size;
//            if (processor.autoSavedTransaction != nil) {
//                IWTransaction *ast = (IWTransaction *)processor.autoSavedTransaction;
//                if (ast.columnIndex != NSNotFound) {
//                    IWInkworksDatabaseHelper *helper = [IWInkworksDatabaseHelper helper];
//                    [helper removeTransaction:ast clearPrepop:NO];
//                }
//            }
//            [self.autoSaveTimer invalidate];
//            self.autoSaveTimer = [NSTimer scheduledTimerWithTimeInterval:self.autoSaveInterval target:self selector:@selector(autoSaveTimerTicked) userInfo:nil repeats:NO];
//            processor.autoSavedTransaction = nil;
//            [pageIndicator setTitle:[NSString stringWithFormat:@"Page %i \u25BC", [renderer.pageServer getModdedPageNumber:renderer.pageToRender] + 1]];
//            [ofIndicator setTitle:[NSString stringWithFormat:@"of %i", renderer.pageServer.servedPages.count]];
//            [self setPopoverSize];
//            processor = [[IWFormProcessor alloc] initWithDescriptor:processor.formDescriptor listItem:processor.listItem canvas:canvas transaction:nil startDate:[NSDate date]];
//            [renderer loadPrepopData];
//            [IWInkworksService getInstance].currentProcessor = processor;
//            if (renderer.pageToRender == 0) backButton.enabled = NO;
//            else backButton.enabled = YES;
//            if (renderer.pageToRender + 1 == renderer.pageCount) forwardButton.enabled = NO;
//            else forwardButton.enabled = YES;
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[IWInkworksService getInstance].mainInstance.view animated:YES];
            
            // Configure for text only and offset down
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"Form cleared";
            hud.margin = 10.f;
            hud.yOffset = -150.f;
            hud.removeFromSuperViewOnHide = YES;
            
            [hud hide:YES afterDelay:2];
        }
        
        
    }
    
    
}


#pragma mark Handle Keyboard

UIView *actField;
// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    actField = [IWInkworksService getInstance].activeView;
    if (actField == nil) return;
    [IWInkworksService getInstance].keyboardShown = YES;
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //if (isLandscape){
    //  float width = kbSize.height;
    // kbSize.height = kbSize.width;
    // kbSize.width = width;
    //}
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    
    if (scrollView == nil) return;
    
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = scrollView.frame;
    aRect.size.height -= kbSize.height;
    CGPoint origin = actField.frame.origin;
    origin.x += actField.superview.superview.superview.frame.origin.x;
    origin.x += actField.superview.frame.origin.x;
    origin.y += actField.superview.superview.superview.frame.origin.y;
    origin.y += actField.superview.frame.origin.y;

    if ([actField isKindOfClass:[IWIsoSubField class]]){
        origin.y += actField.superview.superview.frame.origin.y;
        
        origin.x += actField.superview.superview.frame.origin.x;
    }
    if ([actField.superview isKindOfClass:[IWDropDown class]]) {
        origin.y += actField.superview.superview.frame.origin.y;
    }
    origin.x *= scrollView.zoomScale;
    origin.y *= scrollView.zoomScale;
    CGRect newFrame = CGRectMake(origin.x, origin.y, 100 * scrollView.zoomScale/*actField.frame.size.width * scrollView.zoomScale*/,100 * scrollView.zoomScale/* actField.frame.size.height * scrollView.zoomScale*/);
    //NSLog(@"current field y = %f", origin.y);
    //origin.y -= scrollView.contentOffset.y;
    //NSLog(@"    with offset = %f", origin.y);
    

    if (!CGRectContainsPoint(aRect, origin) ) {
        [IWInkworksService getInstance].doReopenDropdwon = YES;
        CGPoint scrollPoint = CGPointMake((origin.x * scrollView.zoomScale) - 100, (origin.y * scrollView.zoomScale) - 100 );
        if (scrollPoint.x >= 0 && scrollPoint.y >= 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //[scrollView scrollRectToVisible:newFrame animated:YES];
            });
            
                //[scrollView setContentOffset:scrollPoint animated:NO];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if ([IWInkworksService getInstance].popController != nil) {
                    __weak UIView *popOverView = [IWInkworksService getInstance].popController.contentViewController.view;
                    CGRect tableFrame = CGRectMake(popOverView.frame.origin.x, popOverView.frame.origin.y, popOverView.frame.size.width, popOverView.frame.size.height - 10);
                    UITableView *table = (UITableView*)popOverView.subviews[0];
                    table.frame = tableFrame;
                }
            });
        }
    } else {
        [IWInkworksService getInstance].doReopenDropdwon = NO;
    }
    //});
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [IWInkworksService getInstance].keyboardShown = NO;
    [IWInkworksService getInstance].activeView = nil;
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([IWInkworksService getInstance].popController != nil) {
            __weak UIView *popOverView = [IWInkworksService getInstance].popController.contentViewController.view;
            CGRect tableFrame = CGRectMake(popOverView.frame.origin.x, popOverView.frame.origin.y, popOverView.frame.size.width, popOverView.frame.size.height - 10);
            UITableView *table = (UITableView*)popOverView.subviews[0];
            table.frame = tableFrame;
        }
    });
    
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

#pragma mark TableView stuff

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return renderer.pageServer.servedPages.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [pagePopoverController dismissPopoverAnimated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    IWPageDescriptor *page = nil;
    IWPageDescriptor *currentPage = nil;
    for (IWPageDescriptor *p in renderer.pageServer.servedPages) {
        NSLog(@"%d",[renderer.pageServer getModdedPageNumber:p.pageNumber - 1]);
        if ([renderer.pageServer getModdedPageNumber:p.pageNumber - 1] == indexPath.row) {
            page = p;
        }
        if ([renderer.pageServer getModdedPageNumber:p.pageNumber - 1] == renderer.pageToRender) {
            currentPage = p;
            
        }
    }
    
    if (page == nil) {
        page = renderer.pageServer.pages[@([renderer.pageServer getLastPageNumber])];
    }
    
    //renderer.pageServer.servedPages[indexPath.row];
    if ([renderer.pageServer getModdedPageNumber:page.pageNumber - 1]== renderer.pageToRender) {
        return;
    }
    
    BOOL dataChanged = [IWDataChangeHandler getInstance].dataChanged;
    [self.processor savePage:[NSNumber numberWithInt:currentPage.pageNumber - 1] forSending:NO fields:self.renderer.allViews radios:self.renderer.radioGroupManagers renderer:renderer];
    
    renderer.pageToRender = [renderer.pageServer getModdedPageNumber:page.pageNumber - 1];
//    if (renderer.pageToRender == 18446744073709551615) {
//        renderer.pageToRender = [renderer.pageServer getLastPageNumber] - 1;
//    }
    
    for (UIView *v in scrollView.subviews){
        [v removeFromSuperview];
    }
    [renderer renderCanvas];
    [[IWInkworksService getInstance] startStandardUpdates];
    canvas = renderer.formCanvas;
    self.canvas.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.canvas.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
    self.canvas.layer.shadowRadius = 10.0f;
    self.canvas.layer.masksToBounds = NO;
    self.canvas.layer.shadowOpacity = 0.5f;
    [scrollView addSubview:canvas];
    scrollView.contentSize = canvas.frame.size;
    
    CGRect zoomRect = CGRectMake(-20.0, 0.0, canvas.bounds.size.width + 40.0, 10.0);
    [self.scrollView zoomToRect:zoomRect animated:NO];
    [scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    
    [pageIndicator setTitle:[NSString stringWithFormat:@"Page %i \u25BC", renderer.pageToRender + 1]];
    [ofIndicator setTitle:[NSString stringWithFormat:@"of %i", renderer.pageServer.servedPages.count]];
    [self setPopoverSize];
    if ([processor.pageStrings objectForKey:[NSNumber numberWithInt:page.pageNumber - 1]] != nil){
        NSDictionary *pageInfo = [processor.pageStrings objectForKey:[NSNumber numberWithInt:page.pageNumber - 1]];
        [renderer loadForm:pageInfo];
    }
    [renderer loadPrepopData];
    [IWDataChangeHandler getInstance].dataChanged = dataChanged;


    if ([renderer.pageServer canGoBackFrom:page.pageNumber - 1] == -1) backButton.enabled = NO;
    else backButton.enabled = YES;
    if ([renderer.pageServer canGoForwardFrom:page.pageNumber - 1] == -1) forwardButton.enabled = NO;
    else forwardButton.enabled = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [renderer recalculateFields];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [renderer recalculateFields];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [renderer recalculateFields];
    });
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iw_ios7_launch_image_1024x768"]];
    [cell setSelectedBackgroundView:bgView];
    [cell.textLabel setText:[NSString stringWithFormat:@"%d", indexPath.row + 1]];
    IWPageDescriptor *page = nil;
    for (IWPageDescriptor *p in renderer.pageServer.servedPages) {
        if ([renderer.pageServer getModdedPageNumber:p.pageNumber - 1] == indexPath.row) {
            page = p;
        }
    }
    if (renderer.pageToRender == [renderer.pageServer getModdedPageNumber:page.pageNumber - 1]) {
        [cell.textLabel setTextColor:[UIColor grayColor]];
    } else {
        [cell.textLabel setTextColor:[UIColor blackColor]];
    }
    return cell;
}

@end


