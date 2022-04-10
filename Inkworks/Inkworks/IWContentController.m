//
//  IWContentController.m
//  Inkworks
//
//  Created by Jamie Duggan on 13/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWContentController.h"
#import "IWMainController.h"
#import "IWDestinyConstants.h"
#import "IWInkworksService.h"
#import "IWDestFormService.h"

@interface IWContentController ()

@end

@implementation IWContentController

@synthesize windowTitle, viewName, secureService, oriTimer;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

- (void) viewWillAppear:(BOOL)animated{
    CGRect frame = ((IWMainController *)[IWInkworksService getInstance].mainInstance).contentView.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    [self.view setFrame: frame];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void) orientationChanged {
    if (oriTimer != nil) {
        [oriTimer invalidate];
        oriTimer = nil;
    }
    CGRect frame = ((IWMainController *)[IWInkworksService getInstance].mainInstance).contentView.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    if (frame.size.height == 0) {
        frame.size.height = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? 718.0 : 974.0;
        //frame.size.height = UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) ? 718.0 : 974.0;
    }
    if (frame.size.width == 0) {
        frame.size.width = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? 1024 : 768;
        //frame.size.width = UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) ? 1024 : 768;
    }
    [self.view setFrame: frame];
    [self.view setNeedsDisplay];
    [self.view setNeedsLayout];
    
    oriTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(orientationSwitchTimerTick) userInfo:nil repeats:NO];
}


- (void) orientationSwitchTimerTick {
    
    CGRect frame = ((IWMainController *)[IWInkworksService getInstance].mainInstance).contentView.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    if (frame.size.height == 0) {
        frame.size.height = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? 718.0 : 974.0;
        //frame.size.height = UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) ? 718.0 : 974.0;
    }
    if (frame.size.width == 0) {
        frame.size.width = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? 1024 : 768;
        //frame.size.width = UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) ? 1024 : 768;
    }
    [self.view setFrame: frame];
    [self.view setNeedsDisplay];
    [self.view setNeedsLayout];
    
    
    oriTimer = nil;
}

- (void) viewDidAppear:(BOOL)animated{
    CGRect frame = ((IWMainController *)[IWInkworksService getInstance].mainInstance).contentView.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    if (frame.size.height == 0) {
        frame.size.height = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? 718.0 : 974.0;
        //frame.size.height = UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) ? 718.0 : 974.0;
    }
    if (frame.size.width == 0) {
        frame.size.width = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? 1024 : 768;
        //frame.size.width = UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) ? 1024 : 768;
    }
    
    [self.view setFrame: frame];
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

-(void)viewWillLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect superframe = self.view.superview.frame;
    superframe.origin.x = 0;
    superframe.origin.y = 0;
    self.view.frame = superframe;
}



- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

#pragma mark Web Service delegates

- (void) proxydidFinishLoadingData:(id)data InMethod:(NSString *)method{
    
}

- (void) proxyRecievedError:(NSException *)ex InMethod:(NSString *)method{
    
}

#pragma mark DestFormService

- (void)getEformsDownloaded:(NSObject *)info completion:(IWDestinyResponse *)response {
    
}

- (void)loginComplete:(NSObject *)info completion:(IWDestinyResponse *)response status:(int)status {
    
}

- (void)formSendingComplete:(IWTransaction *)transaction completion:(IWDestinyResponse *)response {
    
}

- (void)formSendingError:(IWTransaction *)transaction error:(NSString *)error {
    
}

@end
