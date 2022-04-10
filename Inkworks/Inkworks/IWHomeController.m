//
//  IWHomeController.m
//  Inkworks
//
//  Created by Jamie Duggan on 13/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWHomeController.h"
#import "IWMainController.h"
#import "IWJsonForm.h"
#import "IWZipFormDownloaderDelegate.h"
#import "IWFormSendingService.h"
#import "IWDestinyConstants.h"
#import "Inkworks-Swift.h"
#import "IWInkworksService.h"
#import "IWFileSystem.h"

@interface IWHomeController ()

@end

@implementation IWHomeController

@synthesize formsLabel, historyAllLabel, historyParkedLabel, historySendingLabel, historySentLabel, historyIndicatorLabel, historyAutoSavedLabel, historyAllButton, historyParkedButton, historySendingButton, historySentButton, formsButton, prepopButton, prepopLabel, historyAutoSavedButton, done;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.windowTitle = @"Home";
        self.viewName = HOME_CONTENT_NAME;
    }
    return self;
}

- (id) init{
    self = [super init];
    
    if (self) {
        self.windowTitle = @"Home";
        self.viewName = HOME_CONTENT_NAME;
    }
    
    return self;
}
-(void)getForms {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    //[self.service getEForms:[IWInkworksService getInstance].loggedInUser];
    
    [self performSelectorOnMainThread:@selector(refreshIndicators) withObject:nil waitUntilDone:YES];
    
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.service = [[FormDataWSProxy alloc] initWithUrl:URL AndDelegate:self];
    self.secureService = [[IWDestFormService alloc] initWithUrl:SecureServiceURL];
    [IWFormSendingService getInstance];
    [IWInkworksService getInstance].isRefreshing = YES;
    //[self performSelectorInBackground:@selector(getForms) withObject:nil];

    //[self.service getEForms:[IWInkworksService getInstance].loggedInUser];
    [self.secureService getEFormsSecure];
    AVCaptureMetadataOutput *metadata = [[AVCaptureMetadataOutput alloc] init];
    NSLog(@"Metadata Types:");
    for (NSString *type in metadata.availableMetadataObjectTypes) {
        NSLog(@"%@", type);
    }
    
    [self refreshIndicators];
    [((IWMainController *) [IWInkworksService getInstance].mainInstance).spinner stopAnimating];

    [IWInkworksService getInstance].currentPrepopItem = nil;
    [IWInkworksService getInstance].currentItemForPrepop = nil;
    [IWInkworksService getInstance].currentViewedTransaction = nil;
    [IWInkworksService getInstance].currentViewedForm = nil;
    
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


- (IBAction) formsClicked {
//    if ([IWInkworksService getInstance].isRefreshing){
//        UIAlertView *alert = [UIAlertView new];
//        [alert setTitle:@"Please wait"];
//        [alert setMessage:@"Your forms are being prepared"];
//        [alert addButtonWithTitle:@"OK"];
//        [alert show];
//        return;
//    }
    IWMainController * main = (IWMainController *)[IWInkworksService getInstance].mainInstance;
    [main performSegueWithIdentifier:@"FormsListSegue" sender:main];
}

- (IBAction) historyAutoSavedClicked:(id)sender {
    IWMainController *main = (IWMainController *)[IWInkworksService getInstance].mainInstance;
    [main performSegueWithIdentifier:@"AutoSavedHistorySegue" sender:sender];
}

- (IBAction) historyAllClicked:(id)sender{
    IWMainController * main = (IWMainController *)[IWInkworksService getInstance].mainInstance;
    [main performSegueWithIdentifier:@"AllHistorySegue" sender:sender];
}
- (IBAction) historySendingClicked:(id)sender{
    IWMainController * main = (IWMainController *)[IWInkworksService getInstance].mainInstance;
    [main performSegueWithIdentifier:@"SendingHistorySegue" sender:sender];
}
- (IBAction) historyParkedClicked:(id)sender{
    IWMainController * main = (IWMainController *)[IWInkworksService getInstance].mainInstance;
    [main performSegueWithIdentifier:@"ParkedHistorySegue" sender:sender];
}
- (IBAction) historySentClicked:(id)sender{
    IWMainController * main = (IWMainController *)[IWInkworksService getInstance].mainInstance;
    [main performSegueWithIdentifier:@"SentHistorySegue" sender:sender];
}

- (IBAction) prepopClicked:(id)sender {
    //PrepopSegue
    [IWInkworksService getInstance].currentItemForPrepop = nil;
    IWMainController * main = (IWMainController *)[IWInkworksService getInstance].mainInstance;
    [main performSegueWithIdentifier:@"PrepopSegue" sender:sender];
}

- (void) hideAutoSavedButton {
    [historyAutoSavedButton setHidden:YES];
}

- (void) showAutoSavedButton {
    [historyAutoSavedButton setHidden:NO];
}

- (void) refreshIndicators{
    NSDate *date = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSCalendarUnitDay fromDate:date];
    
    IWSwiftDbHelper *helper = [IWInkworksService dbHelper];
    NSString *user = [IWInkworksService getInstance].loggedInUser;
    
    NSArray *forms = [[IWInkworksService dbHelper] getFormsList:user];
    NSArray *allHist = [helper getAllHistory:user search:nil];
    NSArray *sentHist = [helper getSentHistory:user search:nil];
    NSArray *parkedHist = [helper getParkedHistory:user search:nil];
    NSArray *sendingHist = [helper getSendingHistory:user search:nil];
    NSArray *autoSavedHist = [helper getAutosavedHistory:user search:nil];
    @try {
        IWSwiftDbHelper *swift = [IWInkworksService dbHelper];
        NSArray *prepopForms = [swift getPrepopForms:[IWInkworksService getInstance].loggedInUser];
        [prepopLabel setText:[NSString stringWithFormat:@"%lu", (long unsigned)prepopForms.count]];

    } @catch (NSException *ex) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self refreshIndicators];
        });
    }
    
    [historyAutoSavedLabel performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"%lu", (unsigned long)[autoSavedHist count]] waitUntilDone:NO];
    if (autoSavedHist && [autoSavedHist count] > 0) {
        //[historyAutoSavedButton performSelectorOnMainThread:@selector(setHidden:) withObject:nil waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(showAutoSavedButton) withObject:nil waitUntilDone:YES];
    } else {
        //[historyAutoSavedButton performSelectorOnMainThread:@selector(setHidden:) withObject:@(YES) waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(hideAutoSavedButton) withObject:nil waitUntilDone:YES];
    }
    [historyAutoSavedButton performSelectorOnMainThread:@selector(setNeedsLayout) withObject:nil waitUntilDone:YES];
    [historyIndicatorLabel setText:[NSString stringWithFormat:@"%ld",(long)[components day]]];
    [formsLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)[forms count]]];
//    [historyAllLabel setText:[NSString stringWithFormat:@"%d", [allHist count]]];
//    [historySentLabel setText:[NSString stringWithFormat:@"%d", [sentHist count]]];
//    [historyParkedLabel setText:[NSString stringWithFormat:@"%d", [parkedHist count]]];
//    [historySendingLabel setText:[NSString stringWithFormat:@"%d", [sendingHist count]]];
    
    [historyAllLabel performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"%lu", (unsigned long)[allHist count]] waitUntilDone:false];
    [historySentLabel performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"%lu", (unsigned long)[sentHist count]] waitUntilDone:false];
    [historyParkedLabel performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"%lu", (unsigned long)[parkedHist count]] waitUntilDone:false];
    [historySendingLabel performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"%lu", (unsigned long)[sendingHist count]] waitUntilDone:false];
    
    
    [historyAllLabel setNeedsDisplay];
    [historySendingLabel setNeedsDisplay];
    [historyParkedLabel setNeedsDisplay];
    [historySendingLabel setNeedsDisplay];
}


#pragma mark Web Service delegates

BOOL updatingForms = NO;


- (void) proxydidFinishLoadingData:(id)data InMethod:(NSString *)method{
    [IWInkworksService getInstance].webserviceError = NO;
    if ([method isEqualToString:@"getEForms"]){
        dispatch_queue_t queue = dispatch_queue_create("com.destiny.inkworks.getforms", NULL);
        dispatch_async(queue, ^{
            NSString *response = (NSString *)data;
            NSData *newData = [response dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSArray *receivedObjects = [self jsonListFromJSON:newData error:&error];
            NSArray *original = [[IWInkworksService dbHelper] getFormsList:[IWInkworksService getInstance].loggedInUser];
            NSMutableArray *includedIds = [NSMutableArray array];
            NSMutableArray *requireForms = [NSMutableArray array];
            for (IWJsonForm *jf in receivedObjects){
                [includedIds addObject:jf.formId];
                IWInkworksListItem *existing = [[IWInkworksService dbHelper] getForm:[jf.formId longValue] user:[IWInkworksService getInstance].loggedInUser];
                if (existing == nil){
                    existing = [[IWInkworksListItem alloc] initWithIndex:-1 name:jf.name user:[IWInkworksService getInstance].loggedInUser id:[jf.formId longValue] amended:jf.amended parent:-1];
                    
                    
                    [[IWInkworksService dbHelper] addOrUpdateForm:existing];
                    [requireForms addObject:existing];
                    
                } else {
                    
                    if ([existing.Amended timeIntervalSinceDate:jf.amended] != 0){
                        existing.Amended = jf.amended;
                        
                        
                        [[IWInkworksService dbHelper] addOrUpdateForm:existing];
                        
                        [requireForms addObject:existing];
                    }
                }
            }
            //remove anything not in the list...
            for (IWInkworksListItem *li in original){
                BOOL included = NO;
                for (NSNumber *n in includedIds){
                    long l = [n longValue];
                    if (l == li.FormId){
                        included = YES;
                        break;
                    }
                }
                NSString *imagePath = [IWFileSystem getPreviewImagePathWithId:li.FormId];
                NSData *data = [IWFileSystem loadDataFromFile:imagePath];
                if (included && data.length == 0) {
                    if (![requireForms containsObject:li]) {
                        [requireForms addObject:li];
                    }
                    
                }
                if (!included){
                    IWSwiftDbHelper *swift = [IWInkworksService dbHelper];
                    NSArray *prepops = [swift getPrepopForms:li.FormId user:li.FormUser];
                    for (IWPrepopForm *ppform in prepops) {
                        [swift deleteForm:ppform];
                    }
                    [[IWInkworksService dbHelper] removeFormWithId:li.FormId user:li.FormUser];
                }
            }
            
            //Now update those that need updating
            if ([requireForms count] > 0){
                
                done = [NSMutableDictionary dictionary];
                for (IWInkworksListItem *ili in requireForms){
                    
                    IWZipFormDownloaderDelegate *del = [[IWZipFormDownloaderDelegate alloc] initWithFormId:ili.FormId];
                    [done setObject:del forKey:[NSString stringWithFormat:@"%lu", (long)ili.FormId]];
                    //[del performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:YES];
                }
                
            } else {
                [IWInkworksService getInstance].isRefreshing = NO;
                __weak IWMainController *main = (IWMainController *) [IWInkworksService getInstance].mainInstance;
                if (main) {
                    [main.spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
                }

            }
            
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self refreshIndicators];
                [(IWMainController *)[IWInkworksService getInstance].mainInstance resetButtons];
                
                IWDestFormService *svc = [[IWDestFormService alloc] initWithUrl:SecureServiceURL];
                
                [svc getPrepopFormsSecure];
                
            });
        });
        
    }
}

- (void) proxyRecievedError:(NSException *)ex InMethod:(NSString *)method{
    [IWInkworksService getInstance].webserviceError = YES;
    [self performSelectorOnMainThread:@selector(refreshIndicators) withObject:nil waitUntilDone:YES];
    [IWInkworksService getInstance].isRefreshing = NO;
    __weak IWMainController *main = (IWMainController *) [IWInkworksService getInstance].mainInstance;
    if (main) {
        [main.spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
    }
}


- (NSArray *) jsonListFromJSON: (NSData *) data error: (NSError **) error{
    NSError *localError = nil;
    NSObject *parsedObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    NSDictionary *parsed;
    if ([parsedObj isKindOfClass:[NSDictionary class]]){
        parsed = (NSDictionary *)parsedObj;
    } else {
        parsed = [NSDictionary dictionaryWithObject:parsedObj forKey:@"results"];
    }
    if (localError != nil){
        *error = localError;
        return nil;
    }
    
    NSMutableArray *forms = [[NSMutableArray alloc]init];
    
    NSArray *results;
    
    NSObject *res = [parsed valueForKey:@"results"];
    if ([res isKindOfClass:[NSArray class]]){
        results = (NSArray *)res;
    } else if ([res isKindOfClass:[NSDictionary class]]) {
        results = [NSArray arrayWithObjects:res, nil];
    }
    
    for (NSDictionary *formDict in results){
        @try {
            NSString *formname = [formDict valueForKey:@"name"];
            NSNumber *formId = [formDict valueForKey:@"id"];
            NSString *amendedDateString = [formDict valueForKey:@"amendedDate"];
            double dateLong = [[[amendedDateString stringByReplacingOccurrencesOfString:@"/Date(" withString:@""] stringByReplacingOccurrencesOfString:@")/" withString:@""] doubleValue] / 1000;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:dateLong];
            IWJsonForm *form = [[IWJsonForm alloc] initWithName:formname andFormId:formId andAmended:date];
            [forms addObject:form];
        } @catch (NSException *ex) {
            continue;
        }
    }
    
    
    return forms;
}

- (BOOL)isIpadPro
{
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGFloat width = mainScreen.nativeBounds.size.width / mainScreen.nativeScale;
    CGFloat height = mainScreen.nativeBounds.size.height / mainScreen.nativeScale;
    BOOL isIpad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    BOOL hasIPadProWidth = fabs(width - 1024.f) < DBL_EPSILON;
    BOOL hasIPadProHeight = fabs(height - 1366.f) < DBL_EPSILON;
    return isIpad && hasIPadProHeight && hasIPadProWidth;
}

- (void)viewDidLayoutSubviews {
    
    //if (![IWInkworksService getInstance].shouldLayoutHome) return;
    [super viewDidLayoutSubviews];
    CGRect formsRect = formsButton.frame;
    CGRect historyAllRect = historyAllButton.frame;
    CGRect historySendingRect = historySendingButton.frame;
    CGRect historySentRect = historySentButton.frame;
    CGRect historyParkedRect = historyParkedButton.frame;
    CGRect prepopRect = prepopButton.frame;
    CGRect historyAutoSavedRect = historyAutoSavedButton.frame;
    UIInterfaceOrientation ori = [UIApplication sharedApplication].statusBarOrientation;
    
    
    if (UIInterfaceOrientationIsPortrait(ori)){
        //portrait

        
        int proOffsetX = [self isIpadPro] ? 150 : 0;
        int proOffsetY = [self isIpadPro] ? 200 : 0;
        
        formsRect.origin.x = 70 + proOffsetX;
        prepopRect.origin.x = formsRect.origin.x;
        
        historyAllRect.origin.x = formsRect.origin.x + formsRect.size.width + 148;
        historyParkedRect.origin.x = historyAllRect.origin.x + historyAllRect.size.width - historyParkedRect.size.width;
        historySendingRect.origin.x = historyParkedRect.origin.x - 20 - historySendingRect.size.width;
        historySentRect.origin.x = historySendingRect.origin.x - historySentRect.size.width - 20;
        historyAutoSavedRect.origin.x = historySentRect.origin.x - historyAutoSavedRect.size.width - 20;
        
        
        formsRect.origin.y = 200 + proOffsetY;
        prepopRect.origin.y = formsRect.origin.y + formsRect.size.height + 20;
        historyAllRect.origin.y = formsRect.origin.y;
        historySendingRect.origin.y = historyAllRect.origin.y + historyAllRect.size.height + 20;
        historySentRect.origin.y = historySendingRect.origin.y;
        historyParkedRect.origin.y = historySendingRect.origin.y;
        historyAutoSavedRect.origin.y = historySendingRect.origin.y;
        
    } else {
        //landscape
        
        int proOffsetX = [self isIpadPro] ? 200 : 0;
        int proOffsetY = [self isIpadPro] ? 150 : 0;
        
        formsRect.origin.x = 80 + proOffsetX;
        historyAllRect.origin.x = 479 + proOffsetX;
        historySendingRect.origin.x = 719 + proOffsetX;
        prepopRect.origin.x = 320 + proOffsetX;
        historySentRect.origin.x = 719 + proOffsetX;
        historyParkedRect.origin.x = 839 + proOffsetX;
        historyAutoSavedRect.origin.x = 839 + proOffsetX;
        
        formsRect.origin.y = 184 + proOffsetY;
        historyAllRect.origin.y = 184 + proOffsetY;
        historySendingRect.origin.y = 184 + proOffsetY;
        prepopRect.origin.y = 184 + proOffsetY;
        historySentRect.origin.y = 342 + proOffsetY;
        historyParkedRect.origin.y = 184 + proOffsetY;
        historyAutoSavedRect.origin.y = 342 + proOffsetY;
    }
    
    
    
    
    [formsButton setFrame:formsRect];
    [historyAllButton setFrame:historyAllRect];
    [historySendingButton setFrame:historySendingRect];
    [historySentButton setFrame:historySentRect];
    [historyParkedButton setFrame:historyParkedRect];
    [prepopButton setFrame:prepopRect];
    [historyAutoSavedButton setFrame:historyAutoSavedRect];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[IWInkworksService getInstance].homeInstance = nil;
    [IWInkworksService getInstance].shouldLayoutHome = NO;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [IWInkworksService getInstance].homeInstance = self;
    [IWInkworksService getInstance].shouldLayoutHome = YES;
    [self refreshIndicators];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.view setNeedsDisplay];
        [self.view setNeedsLayout];
    });
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshIndicators];
}


@end
