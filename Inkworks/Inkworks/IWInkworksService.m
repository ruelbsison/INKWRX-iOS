//
//  IWInkworksService.m
//  Inkworks
//
//  Created by Jamie Duggan on 14/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWInkworksService.h"
#import <CommonCrypto/CommonDigest.h>

#import "IWFormProcessor.h"
#import "IWFormRenderer.h"
#import "IWGPSUnit.h"
#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonCryptor.h>

#import "IWMainController.h"

#import "Inkworks-Swift.h"
#import "IWFileSystem.h"

@implementation IWInkworksService

@synthesize galleryImages;
@synthesize currentHistoryScreen, currentViewedForm, currentProcessor, currentRenderer, currentViewedTransaction, currentAutoSavedTransaction, mainInstance, homeInstance, historyInstance, formListInstance, activeView, scrollView, delegateRef, formViewController, done;
@synthesize loggedInUser, loggedInPassword;
@synthesize fromHistory, shouldLayoutHome, isRefreshing;
@synthesize webserviceError, keyboardShown, dataChanged;
@synthesize locationManager, location;
@synthesize currentItemForPrepop, currentPrepopItem;
@synthesize encryptedDateFormatter, doReopenDropdwon, popController;
@synthesize embeddingView;

static IWInkworksService *instance;
static IWSwiftDbHelper *swiftHelper;

- (id)init {
    self = [super init];
    if(self) {
        
        self.location = nil;
        self.encryptedDateFormatter = [NSDateFormatter new];
        self.encryptedDateFormatter.dateFormat = @"ddMMyyyy HHmmss";
        self.doReopenDropdwon = false;
        if ([CLLocationManager locationServicesEnabled]) {
            [self startStandardUpdates];
            
        }
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *loc = [locations lastObject];
    location = [[IWGPSUnit alloc] init];
    location.longitude = [NSNumber numberWithDouble: loc.coordinate.longitude];
    location.latitude = [NSNumber numberWithDouble:loc.coordinate.latitude];
    location.altitude = [NSNumber numberWithDouble: loc.altitude];
    location.dateStamp = loc.timestamp;
    location.accuracy = @"gps";
    [locationManager stopUpdatingLocation];
}

- (void) startStandardUpdates {
    if (nil == locationManager) {
        locationManager = [[CLLocationManager alloc] init];
    }
    locationManager.delegate = self;
    [locationManager requestAlwaysAuthorization];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    locationManager.distanceFilter = 50;
    [locationManager startUpdatingLocation];
}

+ (IWInkworksService *) getInstance {
    if (!instance){
        instance = [[IWInkworksService alloc] init];
    }
    return instance;
}

+ (IWSwiftDbHelper *) dbHelper {
    if (!swiftHelper) {
        swiftHelper = [[IWSwiftDbHelper alloc] init];
    }
    [swiftHelper removeOldTransactions];
    return swiftHelper;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [IWInkworksService getInstance].activeView = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    //[IWInkworksService getInstance].activeView = nil;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [IWInkworksService getInstance].activeView = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    //[IWInkworksService getInstance].activeView = nil;
}

- (void)textWillChange:(id<UITextInput>)textInput {
    
}

- (void)selectionWillChange:(id<UITextInput>)textInput {
    
}

- (void)selectionDidChange:(id<UITextInput>)textInput {
    
}

- (void)textDidChange:(id<UITextInput>)textInput {
    
}

+(NSString *)getHashedPassword:(NSString *)password {
   
        // Create pointer to the string as UTF8
        const char *ptr = [password UTF8String];
        
        // Create byte array of unsigned chars
        unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
        
        // Create 16 byte MD5 hash value, store in buffer
        CC_MD5(ptr, strlen(ptr), md5Buffer);
        
        // Convert MD5 value in the buffer to NSString of hex values
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
            [output appendFormat:@"%02x",md5Buffer[i]];
        
        return [output uppercaseString];
    
}

- (void)dismissKeyboard {
    
}

#pragma mark Crypto

+(NSData *)getHashedCryptoKey:(NSString *)key {
    if (key == nil || [key isEqualToString:@""]) return nil;
    // Create pointer to the string as UTF8
    const char *ptr = [key UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char shaBuffer[CC_SHA256_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_SHA256(ptr, (int)strlen(ptr), shaBuffer);
    
    NSData *data = [NSData dataWithBytes:shaBuffer length:24];
    
    return data;
    
}

+ (NSString *)encrypt:(NSString *)original withKey:(NSString *)key {
    @try {
        size_t outlength;
        NSData *message = [original dataUsingEncoding:NSUTF8StringEncoding];
        NSData *keydata = [IWInkworksService getHashedCryptoKey:key];
        if (keydata == nil) {
            return nil;
        }
        NSMutableData *outputData = [NSMutableData dataWithLength:(message.length + kCCBlockSize3DES)];
        CCCryptorStatus result = CCCrypt(kCCEncrypt, kCCAlgorithm3DES, kCCOptionECBMode + kCCOptionPKCS7Padding, keydata.bytes, keydata.length, nil, message.bytes, message.length, outputData.mutableBytes, outputData.length, &outlength);
        if (result != kCCSuccess) {
            return nil;
        }
        [outputData setLength:outlength];
        NSString *b64 = [outputData base64EncodedStringWithOptions:0];
        return b64;
    } @catch (NSException *ex) {
        return nil;
    }
}

+ (NSString *)decrypt:(NSString *)original withKey:(NSString *)key {
    @try {
        size_t outlength;
        NSData *message = [[NSData alloc] initWithBase64EncodedString:original options:0];
        NSData *keydata = [IWInkworksService getHashedCryptoKey:key];
        if (keydata == nil) {
            return nil;
        }
        NSMutableData *outputData = [NSMutableData dataWithLength:(message.length + kCCBlockSize3DES)];
        CCCryptorStatus result = CCCrypt(kCCDecrypt, kCCAlgorithm3DES, kCCOptionECBMode + kCCOptionPKCS7Padding, keydata.bytes, keydata.length, nil, message.bytes, message.length, outputData.mutableBytes, outputData.length, &outlength);
        
        if (result != kCCSuccess) {
            return nil;
        }
        [outputData setLength:outlength];
        NSString *decText = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
        return decText;
    } @catch (NSException *ex) {
        return nil;
    }
}

+ (NSString *)getCryptoKey:(NSString *)dateString {
    //ddmmyyyy hhmmss
    if (!dateString || [dateString length] == 0) return PRIVATE_KEY;
    if ([dateString rangeOfString:@" "].location == NSNotFound) {
        return nil;
    }
    NSArray *split = [dateString componentsSeparatedByString:@" "];
    if ([split count] != 2) return nil;
    NSString *key = [NSString stringWithFormat:@"%@%@%@", split[1], PRIVATE_KEY, split[0]];
    return key;
}

- (void) handleNewEforms:(NSArray *)newList {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSArray *original = [[IWInkworksService dbHelper] getFormsList:[IWInkworksService getInstance].loggedInUser];
    NSMutableArray *includedIds = [NSMutableArray array];
    NSMutableArray *requireForms = [NSMutableArray array];
    
    for (IWInkworksListItem *newItem in newList){
        [includedIds addObject:[NSNumber numberWithInt: newItem.FormId]];
        IWInkworksListItem *existing = [[IWInkworksService dbHelper] getForm:newItem.FormId user:[IWInkworksService getInstance].loggedInUser];
        if (existing == nil){
            existing = [[IWInkworksListItem alloc] initWithIndex:-1 name:newItem.FormName user:newItem.FormUser id:newItem.FormId amended:newItem.Amended parent:-1];
            [[IWInkworksService dbHelper] addOrUpdateForm:existing];
            [requireForms addObject:existing];
            
        } else {
            
            if ([existing.Amended timeIntervalSinceDate:newItem.Amended] != 0){
                existing.Amended = newItem.Amended;
                existing.FormName = newItem.FormName;
                
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
            [del performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:YES];
        }
        [self getNextForm];
    } else {
        [IWInkworksService getInstance].isRefreshing = NO;
        __weak IWMainController *main = (IWMainController *) [IWInkworksService getInstance].mainInstance;
        if (main) {
            [main.spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
        }
        
    }

}

- (void) getNextForm {
    if (done == nil) return;
    for (NSString *key in done.keyEnumerator) {
        IWZipFormDownloaderDelegate *del = done[key];
        if (del.complete) {
            continue;
        }
        [del start];
        return;
    }
    //when all finished....
    
    [IWInkworksService getInstance].isRefreshing = NO;
    __weak IWMainController *main = (IWMainController *) [IWInkworksService getInstance].mainInstance;
    if (main) {
        [main.spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void) resetButtons {
    if (self.mainInstance != nil) {
        [((IWMainController *)self.mainInstance) resetButtons];
    }
}

- (IWFormProcessor *)getProcessor {
    return self.currentProcessor;
}

@end
