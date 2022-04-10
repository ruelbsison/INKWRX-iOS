//
//  IWFormSendingService.m
//  Inkworks
//
//  Created by Jamie Duggan on 21/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWFormSendingService.h"
#import "IWInkworksService.h"
#import "IWMainController.h"
#import "IWHomeController.h"
#import "MBProgressHUD.h"
#import "IWDestinyConstants.h"
#import "Inkworks-Swift.h"
@import Bugsee;

@implementation IWFormSendingService

@synthesize queue, delayTimer, lastFail;

//FormDataWSProxy *service;

static IWFormSendingService *instance;
dispatch_source_t t;
- (id) init {
    self = [super init];
    if (self) {
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
        [self performBackgroundUpdates];
    }
    return self;
}

- (void) performBackgroundUpdates {
    //MyCreateTimer(self);
    [queue addOperationWithBlock:^{
        [self checkSending];
    }];
}

+ (IWFormSendingService *) getInstance {
    if (instance == nil) {
        instance = [[IWFormSendingService alloc] init];
    }
    return instance;
}


dispatch_source_t CreateDispatchTimer(uint64_t interval,
                                      uint64_t leeway,
                                      dispatch_queue_t queue,
                                      dispatch_block_t block)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                                     0, 0, queue);
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), interval, leeway);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    return timer;
}

void MyCreateTimer(id delegate)
{
    dispatch_source_t aTimer = CreateDispatchTimer(15ull * NSEC_PER_SEC,
                                                   1ull * NSEC_PER_SEC,
                                                   dispatch_get_main_queue(),
                                                   ^{ checkForSending(delegate); });
    
    // Store it somewhere for later use.
    if (aTimer)
    {
        t = aTimer;
    }
}

IWTransaction *trans;
void checkForSending(id delegate) {
    trans = [[IWInkworksService dbHelper] getNextSendingItem];
    if (trans != nil) {
        //service = [[FormDataWSProxy alloc] initWithUrl:URL AndDelegate:[IWFormSendingService getInstance]];
        //[service SaveEFormWithXML:trans.username :trans.formId :trans.penDataXml :trans.strokesXml];
        if ([trans.Username isEqualToString: [IWInkworksService getInstance].loggedInUser]) {
            trans.HashedPassword = [IWInkworksService getHashedPassword:[IWInkworksService getInstance].loggedInPassword];
            [[IWInkworksService dbHelper] addOrUpdateTransaction:trans];
        }
        
//        IWDestFormService *serv = [[IWDestFormService alloc] initWithUrl:NewURL];
//        serv.delegate = delegate;
//        [serv sendTransaction:trans];

        IWDestFormService *serv = [[IWDestFormService alloc] initWithUrl:SecureFormsURL];
        serv.delegate = delegate;
        [serv sendSecureTransaction:trans];

        
    }
}

- (void) checkSending {
    IWInkworksDatabaseHelper *helper = [IWInkworksService dbHelper];
    trans = [[IWInkworksService dbHelper] getNextSendingItem];
    //NSLog(@"Timer Ticked");
    if (trans != nil) {
        //service = [[FormDataWSProxy alloc] initWithUrl:URL AndDelegate:[IWFormSendingService getInstance]];
        //[service SaveEFormWithXML:trans.username :trans.formId :trans.penDataXml :trans.strokesXml];
        if ([trans.Username isEqualToString:[IWInkworksService getInstance].loggedInUser]) {
            trans.hashedPassword = [IWInkworksService getHashedPassword:[IWInkworksService getInstance].loggedInPassword];
            [[IWInkworksService dbHelper] addOrUpdateTransaction:trans];
        }
        
        
//        IWDestFormService *serv = [[IWDestFormService alloc] initWithUrl:NewURL];
//        serv.delegate = self;
//        [serv sendTransaction:trans];

        IWDestFormService *serv = [[IWDestFormService alloc] initWithUrl:SecureFormsURL];
        serv.delegate = self;
        [serv sendSecureTransaction:trans];
    } else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            delayTimer = [NSTimer scheduledTimerWithTimeInterval:15.0
                                                          target:self
                                                        selector:@selector(performBackgroundUpdates:)
                                                        userInfo:nil
                                                         repeats:NO];
            
        });
    }
}

- (void)performBackgroundUpdates: (NSTimer *) timer {
    [self performBackgroundUpdates];
}

- (void)proxydidFinishLoadingData:(id)data InMethod:(NSString *)method {
    [[IWInkworksService getInstance] setWebserviceError:NO];
    
    trans.Sent = YES;
    trans.SentDate = [NSDate date];
    trans.Status = @"Sent";
    
    [[IWInkworksService dbHelper] addOrUpdateTransaction:trans];
    
    if ([IWInkworksService getInstance].mainInstance != nil) {
        [(IWMainController *)[IWInkworksService getInstance].mainInstance resetButtons];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[IWInkworksService getInstance].mainInstance.view animated:YES];
        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"Form sent";
        hud.margin = 10.f;
        hud.yOffset = 150.f;
        hud.removeFromSuperViewOnHide = YES;
        
        [hud hide:YES afterDelay:1];
        
        if ([IWInkworksService getInstance].homeInstance != nil) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^(){
                
                [(IWHomeController *)[IWInkworksService getInstance].homeInstance performSelectorOnMainThread:@selector(refreshIndicators) withObject:nil waitUntilDone:YES];
            }];
        }
        if ([IWInkworksService getInstance].historyInstance != nil) {
            NSArray *historyItems = nil;
            if ([[IWInkworksService getInstance].currentHistoryScreen isEqualToString: HISTORY_CONTENT_NAME]){
                historyItems = [[IWInkworksService dbHelper] getAllHistory:[IWInkworksService getInstance].loggedInUser search:nil];
            } else if ([[IWInkworksService getInstance].currentHistoryScreen isEqualToString: HISTORY_SENDING_CONTENT_NAME]){
                historyItems = [[IWInkworksService dbHelper] getSendingHistory:[IWInkworksService getInstance].loggedInUser search:nil];
            } else if ([[IWInkworksService getInstance].currentHistoryScreen isEqualToString: HISTORY_SENT_CONTENT_NAME]){
                historyItems = [[IWInkworksService dbHelper] getSentHistory:[IWInkworksService getInstance].loggedInUser search:nil];
            } else if ([[IWInkworksService getInstance].currentHistoryScreen isEqualToString: HISTORY_PARKED_CONTENT_NAME]){
                historyItems = [[IWInkworksService dbHelper] getParkedHistory:[IWInkworksService getInstance].loggedInUser search:nil];
            }
            
            ((IWHistoryController *)[IWInkworksService getInstance].historyInstance).historyItems = historyItems;
            [((IWHistoryController *)[IWInkworksService getInstance].historyInstance).table performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
        }
    }
    
}

- (void)proxyRecievedError:(NSException *)ex InMethod:(NSString *)method {
    [[IWInkworksService getInstance] setWebserviceError:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([IWInkworksService getInstance].mainInstance != nil){
            [(IWMainController *)[IWInkworksService getInstance].mainInstance resetButtons];
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[IWInkworksService getInstance].mainInstance.view animated:YES];
            
            // Configure for text only and offset down
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"Form sending failed. Check internet connection.";
            hud.margin = 10.f;
            hud.yOffset = 150.f;
            hud.removeFromSuperViewOnHide = YES;
            
            [hud hide:YES afterDelay:3];
        }
    });
    

}

- (void)formSendingComplete:(IWTransaction *)transaction completion:(IWDestinyResponse *)response {
    lastFail = nil;
    [[IWInkworksService getInstance] setWebserviceError:NO];
    
    transaction.Sent = YES;
    transaction.SentDate = [NSDate date];
    transaction.Status = @"Sent";
    
    [[IWInkworksService dbHelper] addOrUpdateTransaction:transaction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
    if ([IWInkworksService getInstance].mainInstance != nil) {
        [(IWMainController *)[IWInkworksService getInstance].mainInstance resetButtons];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[IWInkworksService getInstance].mainInstance.view animated:YES];
        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"Form sent";
        hud.margin = 10.f;
        hud.yOffset = 150.f;
        hud.removeFromSuperViewOnHide = YES;
        
        [hud hide:YES afterDelay:1];
        
        if ([IWInkworksService getInstance].homeInstance != nil) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^(){
                
                [(IWHomeController *)[IWInkworksService getInstance].homeInstance performSelectorOnMainThread:@selector(refreshIndicators) withObject:nil waitUntilDone:YES];
            }];
        }
        if ([IWInkworksService getInstance].historyInstance != nil) {
            NSArray *historyItems = nil;
            if ([[IWInkworksService getInstance].currentHistoryScreen isEqualToString: HISTORY_CONTENT_NAME]){
                historyItems = [[IWInkworksService dbHelper] getAllHistory:[IWInkworksService getInstance].loggedInUser search:nil];
            } else if ([[IWInkworksService getInstance].currentHistoryScreen isEqualToString: HISTORY_SENDING_CONTENT_NAME]){
                historyItems = [[IWInkworksService dbHelper] getSendingHistory:[IWInkworksService getInstance].loggedInUser search:nil];
            } else if ([[IWInkworksService getInstance].currentHistoryScreen isEqualToString: HISTORY_SENT_CONTENT_NAME]){
                historyItems = [[IWInkworksService dbHelper] getSentHistory:[IWInkworksService getInstance].loggedInUser search:nil];
            } else if ([[IWInkworksService getInstance].currentHistoryScreen isEqualToString: HISTORY_PARKED_CONTENT_NAME]){
                historyItems = [[IWInkworksService dbHelper] getParkedHistory:[IWInkworksService getInstance].loggedInUser search:nil];
            }
            
            ((IWHistoryController *)[IWInkworksService getInstance].historyInstance).historyItems = historyItems;
            [((IWHistoryController *)[IWInkworksService getInstance].historyInstance).table performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
            [((IWHistoryController *)[IWInkworksService getInstance].historyInstance).table performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
            
        }
    }
        
    });
    
    [queue addOperationWithBlock:^{
        [self checkSending];
    }];
    
}

- (void)formSendingError:(IWTransaction *)transaction error:(NSString *)error{
    [[IWInkworksService getInstance] setWebserviceError:YES];
    NSDate *last = lastFail == nil? [NSDate dateWithTimeIntervalSince1970:0] : lastFail;
    NSTimeInterval timediff = [[NSDate date] timeIntervalSinceDate:last];
    if (![error isEqualToString:@"404"] && ![error isEqualToString:@"The Internet connection appears to be offline."] && ![error isEqualToString:@"The request timed out."]) {
        NSLog(@"Form Sending Error: %@", error);
        [Bugsee uploadWithSummary:@"Form Sending Error" description:error severity:BugseeSeverityCritical];
    }
    if (timediff > 60) {
        lastFail = [NSDate date];
    
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([IWInkworksService getInstance].mainInstance != nil){
                [(IWMainController *)[IWInkworksService getInstance].mainInstance resetButtons];
                if ([error isEqualToString:@"The Internet connection appears to be offline."]) {
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[IWInkworksService getInstance].mainInstance.view animated:YES];
                    
                    // Configure for text only and offset down
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = @"Form sending failed. Check internet connection.";
                    hud.margin = 10.f;
                    hud.yOffset = 150.f;
                    hud.removeFromSuperViewOnHide = YES;
                    
                    [hud hide:YES afterDelay:3];
                } else {
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[IWInkworksService getInstance].mainInstance.view animated:YES];
                    
                    // Configure for text only and offset down
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = @"Unable to connect to INKWRX. Please try again later.";
                    hud.margin = 10.f;
                    hud.yOffset = 150.f;
                    hud.removeFromSuperViewOnHide = YES;
                    
                    [hud hide:YES afterDelay:3];
                }
                
            }
        });
        
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([IWInkworksService getInstance].mainInstance != nil){
                [(IWMainController *)[IWInkworksService getInstance].mainInstance resetButtons];
            }
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        delayTimer = [NSTimer scheduledTimerWithTimeInterval:15.0
                                                      target:self
                                                    selector:@selector(performBackgroundUpdates:)
                                                    userInfo:nil
                                                     repeats:NO];
        
    });
}

- (void)loginComplete:(IWFileDescriptionWithTabletInfo *)info completion:(IWDestinyResponse *)response status:(int)status{
    
}

- (void)getEformsDownloaded:(NSObject *)info completion:(IWDestinyResponse *)response {
    
}

-(void)getZipFormSecureDownloaded:(NSObject *)info completion:(IWDestinyResponse *)response {
    
}

@end
