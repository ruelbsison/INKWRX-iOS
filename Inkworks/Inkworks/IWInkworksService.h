//
//  IWInkworksService.h
//  Inkworks
//
//  Created by Jamie Duggan on 14/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

//RandomQuote:
// Of all the things I've lost, I miss my mind the most...
//#define PRIVATE_KEY @"25cfdfc48954334b0fe7c0fb7569229240feceef"
#define PRIVATE_KEY @"OfAllTheThingsIveLostIMissMyMindTheMost"


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

//#import "IWMainController.h"


@class IWFormRenderer;
@class IWFormProcessor;
@class IWGPSUnit;
@class IWInkworksDatabaseHelper;
@class IWTransaction;
@class IWFormViewController;
@class IWInkworksListItem;
@class IWPrepopForm;
@class IWTabletImageView;
@class IWSwiftDbHelper;

@interface IWInkworksService : NSObject <UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate> {
    NSString *currentHistoryScreen;
    IWInkworksListItem *currentViewedForm;
    IWTransaction *currentViewedTransaction;
    IWTransaction *currentAutoSavedTransaction;
    UIViewController *mainInstance;
    UIViewController *homeInstance;
    UIViewController *historyInstance;
    UIViewController *formListInstance;
    IWFormViewController *formViewInstance;
    __weak IWFormProcessor *currentProcessor;
    __weak IWFormRenderer *currentRenderer;
        
    NSString *loggedInUser;
    NSString *loggedInPassword;
    BOOL fromHistory;
    BOOL keyboardShown;
    BOOL webserviceError;
    
    BOOL dataChanged;
    
    BOOL doReopenDropdown;
    BOOL shouldLayoutHome;
    BOOL isRefreshing;
    UIView *activeView;
    UIScrollView *scrollView;
    id <UITextFieldDelegate, UITextViewDelegate> delegateRef;
    
    IWTabletImageView *embeddingView;
    
    UIPopoverController *popController;
    NSMutableArray *galleryImages;
    
    IWPrepopForm *currentPrepopItem;
    IWInkworksListItem *currentItemForPrepop;
    
    IWGPSUnit *location;
    CLLocationManager *locationManager;
    NSDateFormatter *encryptedDateFormatter;
    
    
    
    NSMutableDictionary *done;
}



@property NSMutableArray *galleryImages;
@property (strong, nonatomic) NSString *currentHistoryScreen;
@property IWInkworksListItem *currentViewedForm;
@property (weak) IWFormProcessor *currentProcessor;
@property (weak) IWFormRenderer *currentRenderer;
@property IWTransaction *currentViewedTransaction;
@property IWTransaction *currentAutoSavedTransaction;
@property UIViewController *mainInstance;
@property UIViewController *homeInstance;
@property UIViewController *historyInstance;
@property UIViewController *formListInstance;
@property IWFormViewController *formViewController;
@property NSString *loggedInUser;
@property NSString *loggedInPassword;
@property BOOL fromHistory;
@property BOOL webserviceError;
@property BOOL keyboardShown;
@property UIView *activeView;
@property UIScrollView *scrollView;
@property id<UITextFieldDelegate, UITextViewDelegate> delegateRef;
@property BOOL dataChanged;
@property BOOL shouldLayoutHome;
@property BOOL isRefreshing;
@property NSDateFormatter *encryptedDateFormatter;
@property BOOL doReopenDropdwon;
@property UIPopoverController *popController;
@property IWPrepopForm *currentPrepopItem;
@property IWInkworksListItem *currentItemForPrepop;

@property IWTabletImageView *embeddingView;

@property IWGPSUnit *location;

@property NSMutableDictionary *done;
@property CLLocationManager *locationManager;

+ (NSString *) encrypt:(NSString *) original withKey:(NSString *)key;
+ (NSString *) decrypt:(NSString *) original withKey:(NSString *)key;
+ (NSString *) getCryptoKey:(NSString *)dateString;
+ (IWInkworksService *) getInstance;
+ (IWSwiftDbHelper *) dbHelper;
- (void) dismissKeyboard;
+ (NSString *) getHashedPassword: (NSString *) password;
- (void) startStandardUpdates;
- (void) handleNewEforms:(NSArray *)newList;
- (void) resetButtons;
- (void) getNextForm;
- (IWFormProcessor *) getProcessor;
@end
