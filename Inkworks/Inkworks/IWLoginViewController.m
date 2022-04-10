//
//  IWLoginViewController.m
//  Inkworks
//
//  Created by Jamie Duggan on 02/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#define IS_OS_5_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
#define IS_OS_6_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#import "IWLoginViewController.h"
#import "IWInkworksService.h"
#import "IWMainController.h"
#import "IWFileSystem.h"
#import "IWDestinyChunkResponseMessage.h"
#import "IWDestFormService.h"
#import "IWDestinyConstants.h"
#import "Inkworks-Swift.h"
//#import "IWSavedSettings.h"
#import <QuartzCore/QuartzCore.h>
#import "IWDestinyResponse.h"
@import Bugsee;

@interface IWLoginViewController ()

@end

@implementation IWLoginViewController

@synthesize versionLabel;
@synthesize usernameField;
@synthesize passwordField;
@synthesize rememberPasswordButton;
@synthesize loginButton;
//@synthesize service;
@synthesize scrollView, activity, deviceIdLabel, loginWorking;

BOOL rememberPassword = YES;

BOOL isLandscape;

NSString *savedUsernameString;
NSString *savedPasswordString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
    }
    return self;
}

-(id) init{
    self = [super init];
    
    if (self){
    }
    return self;
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation) && !isLandscape){
        NSLog(@"to landscape");
        isLandscape = YES;
    } else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation) && isLandscape){
        NSLog(@"to portrait");
        isLandscape = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Bugsee clearEmail];
    loginWorking = NO;
    NSString *vendorId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    deviceIdLabel.text = [NSString stringWithFormat:@"Device Id: %@", vendorId];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([IWInkworksService dbHelper]) {
            
        };
    });
    // Do any additional setup after loading the view.
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        isLandscape = YES;
    } else {
        isLandscape = NO;
    }
    [self registerForKeyboardNotifications];
    BOOL prelive = [URL rangeOfString:@"prelive"].location != NSNotFound;
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    appVersionString = [NSString stringWithFormat:@"Version: %@", appVersionString];
    //NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];


    //NSString *appVersion = [NSString stringWithFormat:@"Version %@.%@", appVersionString, appBuildString];
    if (prelive) appVersionString = [appVersionString stringByAppendingString:@" (PreLive)"];
    versionLabel.text = appVersionString;
    
//    UIColor *buttonColor = loginButton.backgroundColor;
//    loginButton.backgroundColor = [UIColor clearColor];
//    loginButton.layer.backgroundColor = [buttonColor CGColor];
//    loginButton.layer.borderColor = [[UIColor whiteColor] CGColor];
//    loginButton.layer.borderWidth = 1;
    UIGestureRecognizer *tapLogin = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginButtonPressed)];
    [loginButton addGestureRecognizer:tapLogin];
    IWSwiftDbHelper *helper = [IWInkworksService dbHelper];
    
    IWSavedSettings *rememberPasswordSetting = [helper getSetting:REMEMBER_PASSWORD];
    
    IWSavedSettings *savedUsername = [helper getSetting:SAVED_USERNAME];
    IWSavedSettings *savedPassword = [helper getSetting:SAVED_PASSWORD];
    
    if (rememberPasswordSetting != nil){
        // remember is not nil...
        if ([rememberPasswordSetting.SettingValue isEqualToString: @"true"]){
            //remember...
            [rememberPasswordButton setTitle:@"\u2611 Remember Password" forState:UIControlStateNormal];
            [rememberPasswordButton setTitle:@"\u2611 Remember Password" forState:UIControlStateHighlighted];
            [rememberPasswordButton setTitle:@"\u2611 Remember Password" forState:UIControlStateSelected];
            rememberPassword = YES;
            
            if (savedUsername != nil){
                [usernameField setText:[savedUsername.SettingValue lowercaseString]];
                savedUsernameString = [savedUsername.SettingValue lowercaseString];
            } else {
                [usernameField setText:@""];
                savedUsernameString = @"";
            }
            if (savedPassword != nil){
                [passwordField setText:savedPassword.SettingValue];
                savedPasswordString = savedPassword.SettingValue;
            } else {
                [passwordField setText:@""];
                savedPasswordString = @"";
            }
            
            
        } else {
            //don't remember...
            
            [rememberPasswordButton setTitle:@"\u2610 Remember Password" forState:UIControlStateNormal];
            [rememberPasswordButton setTitle:@"\u2610 Remember Password" forState:UIControlStateHighlighted];
            [rememberPasswordButton setTitle:@"\u2610 Remember Password" forState:UIControlStateSelected];
            rememberPassword = NO;
            
            [usernameField setText:@""];
            [passwordField setText:@""];
            
        }
        
        
        
    } else {
        //remember is nil
        [rememberPasswordButton setTitle:@"\u2611 Remember Password" forState:UIControlStateNormal];
        [rememberPasswordButton setTitle:@"\u2611 Remember Password" forState:UIControlStateHighlighted];
        [rememberPasswordButton setTitle:@"\u2611 Remember Password" forState:UIControlStateSelected];
        
        
    }
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (IBAction)privacyButtonPressed {
    NSURL *url = [[NSURL alloc]initWithString:@"http://www.inkwrx.com/website-privacy-policy/"];
    [[UIApplication sharedApplication] openURL:url];

}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (IBAction)loginButtonPressed {
    if (!loginWorking) {
        loginWorking = YES;
        [loginButton setHidden:YES];
        [activity startAnimating];
        //self.service = [[FormDataWSProxy alloc] initWithUrl:URL AndDelegate:self];
        //[self.service ValidateDockingStation:usernameField.text :passwordField.text];
        //IWDestFormService *serv = [[IWDestFormService alloc] initWithUrl:NewURL];
        //serv.delegate = self;
        
        //[serv login:usernameField.text password:[IWInkworksService getHashedPassword:passwordField.text]];
        IWDestFormService *serv = [[IWDestFormService alloc] initWithUrl:SecureFormsURL];
        serv.delegate = self;
        
        
        [serv secureLogin:[usernameField.text lowercaseString] password:[IWInkworksService getHashedPassword:passwordField.text]];
    }
}

-(void) proxyRecievedError:(NSException *)ex InMethod:(NSString *)method{
    [IWInkworksService getInstance].webserviceError = YES;
    if (rememberPassword){
        if ([savedUsernameString isEqualToString:self.usernameField.text]
            && [savedPasswordString isEqualToString:self.passwordField.text]){
            //password ok
            [IWInkworksService getInstance].loggedInUser = self.usernameField.text;
            [IWInkworksService getInstance].loggedInPassword = self.passwordField.text;
            [self performSegueWithIdentifier:@"LoginSegue" sender:self];
        } else {
            //paassword wrong
            
            if ([savedUsernameString isEqualToString:self.usernameField.text]){
                UIAlertView *alert = [UIAlertView new];
                [alert setTitle:@"Incorrect"];
                [alert setMessage:@"Username or Password incorrect"];
                //[alert setMessage:[ex reason]];
                [alert addButtonWithTitle:@"Close"];
                [alert show];
            } else {
                UIAlertView *alert = [UIAlertView new];
                [alert setTitle:@"Data connection error"];
                [alert setMessage:@"Check internet connection then try again"];
                //[alert setMessage:[ex reason]];
                [alert addButtonWithTitle:@"Close"];
                [alert show];
            }
            
            
        }
    } else {
        //data error..
        UIAlertView *alert = [UIAlertView new];
        [alert setTitle:@"Data connection error"];
        [alert setMessage:@"Check internet connection then try again"];
        //[alert setMessage:[ex reason]];
        [alert addButtonWithTitle:@"Close"];
        [alert show];
        
    }
    loginWorking = NO;
    [loginButton setHidden:NO];
    [activity stopAnimating];
}

- (void) proxydidFinishLoadingData:(id)data InMethod:(NSString *)method {
    NSNumber *num = (NSNumber *)data;
    [IWInkworksService getInstance].webserviceError = NO;
    BOOL ok = [num isEqualToNumber:@1];
    
    if (ok){
        //password ok
        
        IWSwiftDbHelper *helper = [IWInkworksService dbHelper];
        if (rememberPassword){
            [helper saveSetting:REMEMBER_PASSWORD value:@"true"];
            [helper saveSetting:SAVED_USERNAME value:[usernameField.text lowercaseString]];
            [helper saveSetting:SAVED_PASSWORD value:passwordField.text];
        } else {
            [helper saveSetting:REMEMBER_PASSWORD value:@"false"];
            [helper saveSetting:SAVED_USERNAME value:@""];
            [helper saveSetting:SAVED_PASSWORD value:@""];
        }
        
        [IWInkworksService getInstance].loggedInUser = [self.usernameField.text lowercaseString];
        [IWInkworksService getInstance].loggedInPassword = self.passwordField.text;
        [self performSegueWithIdentifier:@"LoginSegue" sender:self];
        
    } else {
        //password not OK
        UIAlertView *alert = [UIAlertView new];
        [alert setTitle:@"Incorrect"];
        [alert setMessage:@"Username or Password incorrect"];
        //[alert setMessage:[ex reason]];
        [alert addButtonWithTitle:@"Close"];
        [alert show];
        
        loginWorking = NO;
        [loginButton setHidden:NO];
        [activity stopAnimating];
    }
    
    
}

- (void)formSendingComplete:(IWTransaction *)transaction completion:(IWDestinyResponse *)response {
    
}

- (void)formSendingError:(IWTransaction *)transaction error:(NSString *)error {
    
}

- (void)loginComplete:(NSObject *)info completion:(IWDestinyResponse *)response status:(int)status {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
    if (status > 0) {
        [IWInkworksService getInstance].webserviceError = YES;
    } else {
        [IWInkworksService getInstance].webserviceError = NO;
    }
    });
    
    
    if (status == 1 || status == 2 || status == 3) {
        //server error
        NSString *alertTitle = @"Server error";
        NSString *alertText = @"Unable to connect to INKWRX. Please try again later.";
        if (status == 2) { //internet connection error
            alertTitle = @"Data connection error";
            alertText = @"Check internet connection then try again";
        }
        if (status == 3) { //xml parse error
            alertTitle = @"Data Parsing Error";
            alertText = @"There was a problem with the server data. If this problem persists, please contact Destiny Wireless support.";
        }
        if (rememberPassword){
            if ([savedUsernameString isEqualToString:[self.usernameField.text lowercaseString]]
                && [savedPasswordString isEqualToString:self.passwordField.text]){
                //password ok
                dispatch_async(dispatch_get_main_queue(), ^{
                [IWInkworksService getInstance].loggedInUser = [self.usernameField.text lowercaseString];
                [IWInkworksService getInstance].loggedInPassword = self.passwordField.text;
                
                    [Bugsee setEmail:[IWInkworksService getInstance].loggedInUser];
                    [self performSegueWithIdentifier:@"LoginSegue" sender:self];
                    
                });
            } else {
                //paassword wrong
                
                dispatch_async(dispatch_get_main_queue(), ^{
                
                    if ([savedUsernameString isEqualToString:[self.usernameField.text lowercaseString]]){
                        UIAlertView *alert = [UIAlertView new];
                        [alert setTitle:@"Incorrect"];
                        [alert setMessage:@"Username or Password incorrect"];
                        //[alert setMessage:[ex reason]];
                        [alert addButtonWithTitle:@"Close"];
                        [alert show];
                    } else {
                        UIAlertView *alert = [UIAlertView new];
                        [alert setTitle:alertTitle];
                        [alert setMessage:alertText];
                        //[alert setMessage:[ex reason]];
                        [alert addButtonWithTitle:@"Close"];
                        [alert show];
                    }
                    
                });
                
                
                
                
            }
        } else {
            //data error..
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                UIAlertView *alert = [UIAlertView new];
                [alert setTitle:alertTitle];
                [alert setMessage:alertText];
                //[alert setMessage:[ex reason]];
                [alert addButtonWithTitle:@"Close"];
                [alert show];
                
            });
            
            
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            loginWorking = NO;
            [loginButton setHidden:NO];
            [activity stopAnimating];

        });
        
    } else if (status == 0) {
        //ok response...
        IWSecureResponse *secResp = nil;
        if (![response.Data isEqualToString:@""]) {
            NSString *decrypted = [IWInkworksService decrypt:response.Data withKey:[IWInkworksService getCryptoKey:response.Date]];
            secResp = [[IWSecureResponse alloc] initWithXml:decrypted];
        }
        NSNumber *num = secResp ? [NSNumber numberWithInt:secResp.ErrorCode] : response.Errorcode;
        BOOL ok = [num isEqualToNumber:@0];
        
        if (ok){
            //password ok
            
            IWSwiftDbHelper *helper = [IWInkworksService dbHelper];
            if (rememberPassword){
                [helper saveSetting:REMEMBER_PASSWORD value:@"true"];
                [helper saveSetting:SAVED_USERNAME value:[usernameField.text lowercaseString]];
                [helper saveSetting:SAVED_PASSWORD value:passwordField.text];
            } else {
                [helper saveSetting:REMEMBER_PASSWORD value:@"false"];
                [helper saveSetting:SAVED_USERNAME value:@""];
                [helper saveSetting:SAVED_PASSWORD value:@""];
            }
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [IWInkworksService getInstance].loggedInUser = [self.usernameField.text lowercaseString];
                [IWInkworksService getInstance].loggedInPassword = self.passwordField.text;
                
                [Bugsee setEmail:[IWInkworksService getInstance].loggedInUser];
                [self performSegueWithIdentifier:@"LoginSegue" sender:self];
                
            });
            
        } else {
            //password not OK
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [UIAlertView new];
                [alert setTitle:@"Incorrect"];
                [alert setMessage:@"Username or Password incorrect"];
                //[alert setMessage:[ex reason]];
                [alert addButtonWithTitle:@"Close"];
                [alert show];
                
                loginWorking = NO;
                [loginButton setHidden:NO];
                [activity stopAnimating];
            });
            
            
        }

    }
}

- (IBAction)rememberPasswordButtonPressed {
    rememberPassword = !rememberPassword;
    if (rememberPassword){
        [rememberPasswordButton setTitle:@"\u2611 Remember Password" forState:UIControlStateNormal];
        [rememberPasswordButton setTitle:@"\u2611 Remember Password" forState:UIControlStateHighlighted];
        [rememberPasswordButton setTitle:@"\u2611 Remember Password" forState:UIControlStateSelected];
    } else {
        [rememberPasswordButton setTitle:@"\u2610 Remember Password" forState:UIControlStateNormal];
        [rememberPasswordButton setTitle:@"\u2610 Remember Password" forState:UIControlStateHighlighted];
        [rememberPasswordButton setTitle:@"\u2610 Remember Password" forState:UIControlStateSelected];
        
    }
}



#pragma mark Keyboard Handlers☐

UITextField *activeField;

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    if (!IS_OS_8_OR_LATER && isLandscape){
        float width = kbSize.height;
        kbSize.height = kbSize.width;
        kbSize.width = width;
    }
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    CGPoint origin = activeField.frame.origin;
    origin.y += activeField.superview.frame.origin.y;
    origin.y += activeField.superview.superview.frame.origin.y;
    origin.y -= scrollView.contentOffset.y;
    if (!CGRectContainsPoint(aRect, origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, origin.y - aRect.size.height-150);
        [scrollView setContentOffset:scrollPoint animated:NO];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}

- (IBAction)textFieldBeginEdit:(UITextField *)sender {
    
    activeField = sender;
}

- (IBAction)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 1) {
        //password field
        [self loginButtonPressed];
    } else {
        [passwordField becomeFirstResponder];
    }
    
    return NO;
}

- (void)getEformsDownloaded:(NSObject *)info completion:(IWDestinyResponse *)response {
    
}

@end
