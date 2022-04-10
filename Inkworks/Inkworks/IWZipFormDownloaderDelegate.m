//
//  IWZipFormDownloaderDelegate.m
//  Inkworks
//
//  Created by Jamie Duggan on 15/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWZipFormDownloaderDelegate.h"
#import "IWFileSystem.h"
#import "IWDestinyConstants.h"
#import "IWInkworksService.h"
#import "ZipArchive.h"
#import "Inkworks-Swift.h"
#import "IWFormRenderer.h"
#import <QuartzCore/QuartzCore.h>
#import "IWInkworksService.h"
#import "IWHomeController.h"
#import "IWMainController.h"
#import "IWDestinyResponse.h"
#import "IWFormDescriptor.h"

@implementation IWZipFormDownloaderDelegate

@synthesize formId, complete, completeDelegate, secSvc;
//@synthesize service;

- (void) formSendingComplete: (IWTransaction *) transaction completion: (IWDestinyResponse *) response{
    
}
- (void) formSendingError: (IWTransaction *) transaction error: (NSString *) error{
    
}

- (void) loginComplete: (NSObject *) info completion: (IWDestinyResponse *) response status: (int) status{
    
}

- (void) getEformsDownloaded: (NSObject *) info completion: (IWDestinyResponse *) response{
    
}

- (void)getZipFormSecureDownloaded:(NSObject *)info completion:(IWDestinyResponse *)response {
    [IWInkworksService getInstance].webserviceError = NO;
    NSString *decrypted = [IWInkworksService decrypt:response.Data withKey:[IWInkworksService getCryptoKey:response.Date]];
    
    IWSecureResponse *secResp = [[IWSecureResponse alloc] initWithXml:decrypted];
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:secResp.ByteData options:0];
    
    [IWFileSystem saveFileWithFileName:[IWFileSystem getZipFilePathWithId:formId] andData:data];
    
    ZipArchive *za = [ZipArchive new];
    BOOL success = [za UnzipOpenFile:[IWFileSystem getZipFilePathWithId:formId]];
    if (success){
        NSString *dest = [IWFileSystem getFormFolderWithId:formId];
        success = [za UnzipFileTo:dest overWrite:YES];
        if (success){
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSError *error;
                [[NSFileManager defaultManager] removeItemAtPath:[IWFileSystem getZipFilePathWithId:formId] error:&error];
                //IWInkworksListItem *item = [[IWInkworksDatabaseHelper helper] getFormFromFormId:formId forUser:[IWInkworksService getInstance].loggedInUser];
//                IWInkworksListItem *item = [[IWInkworksListItem alloc]initWithIndex:-1 andFormName:@"" andFormUser:@"" andFormId:formId andAmended:nil];
//                IWFormRenderer *renderer = [[IWFormRenderer alloc] initWithItem:item andTransaction:nil];
//                NSString *previewImageFile = [IWFileSystem getPreviewImagePathWithId:item.formId];
//                [renderer renderForm:YES];
//                //[renderer performSelectorOnMainThread:@selector(renderCanvas) withObject:nil waitUntilDone:YES];
//                [renderer renderCanvas];
//                [renderer.formDescriptor nilAll];
//                renderer.formDescriptor = nil;
//                UIView *canvas = [renderer formCanvas];
//                CGRect square = CGRectMake(0, 0, MIN(canvas.frame.size.width, canvas.frame.size.height),MIN(canvas.frame.size.width, canvas.frame.size.height));
//                [canvas setFrame:square];
//                
//                //Set it to visible
//                [((IWMainController *)[IWInkworksService getInstance].mainInstance) resetButtons];
//                UIGraphicsBeginImageContext(canvas.frame.size);
//                
//                [canvas.layer renderInContext:UIGraphicsGetCurrentContext()];
//                UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
//                canvas = nil;
//                renderer = nil;
//                NSData *myData3 = UIImagePNGRepresentation(img);
//                img = nil;
//                [myData3 writeToFile:previewImageFile atomically:NO];
//                myData3 = nil;

                NSString *previewImageFile = [IWFileSystem getPreviewImagePathWithId:formId];
                NSString *applicationPreviewImage = [IWFileSystem getApplicationPreviewWithId:formId];
                [[NSFileManager defaultManager] moveItemAtPath:applicationPreviewImage toPath:previewImageFile error:&error];
                if (completeDelegate != nil) {
                    [completeDelegate completeZip];
                    
                }
                
                
            });
        }
    }
    self.complete = YES;
    
    //[[IWInkworksService getInstance] getNextForm];
    
    if ([IWInkworksService getInstance].homeInstance) {
        __weak IWHomeController *home = (IWHomeController *)[IWInkworksService getInstance].homeInstance;
        BOOL finished = YES;
        for (IWZipFormDownloaderDelegate *del in home.done.objectEnumerator) {
            if (!del.complete) {
                finished = NO;
            }
        }
        if (finished) {
            [IWInkworksService getInstance].isRefreshing = NO;
            __weak IWMainController *main = (IWMainController *) [IWInkworksService getInstance].mainInstance;
            if (main) {
                [main.spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
            }
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    }
    //        });
}


- (void) proxydidFinishLoadingData:(id)data InMethod:(NSString *)method{
//    dispatch_queue_t queue = dispatch_queue_create("com.destiny.inkworks.getforms", NULL);
//    dispatch_async(queue, ^{
    [IWFileSystem saveFileWithFileName:[IWFileSystem getZipFilePathWithId:formId] andData:data];
    
    ZipArchive *za = [ZipArchive new];
    BOOL success = [za UnzipOpenFile:[IWFileSystem getZipFilePathWithId:formId]];
    if (success){
        NSString *dest = [IWFileSystem getFormFolderWithId:formId];
        success = [za UnzipFileTo:dest overWrite:YES];
        if (success){
            NSError *error;
            [[NSFileManager defaultManager] removeItemAtPath:[IWFileSystem getZipFilePathWithId:formId] error:&error];
            //IWInkworksListItem *item = [[IWInkworksDatabaseHelper helper] getFormFromFormId:formId forUser:[IWInkworksService getInstance].loggedInUser];
            IWInkworksListItem *item = [[IWInkworksListItem alloc] init];
            item.FormId = formId;
            
            IWFormRenderer *renderer = [[IWFormRenderer alloc] initWithItem:item andTransaction:nil];
            NSString *previewImageFile = [IWFileSystem getPreviewImagePathWithId:item.FormId];
            [renderer renderForm];
            [renderer renderCanvas];
            
            UIView *canvas = [renderer formCanvas];
            CGRect square = CGRectMake(0, 0, MIN(canvas.frame.size.width, canvas.frame.size.height),MIN(canvas.frame.size.width, canvas.frame.size.height));
            [canvas setFrame:square];
            
            UIGraphicsBeginImageContext(canvas.frame.size);
            //Set it to visible
            [canvas.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
            
            NSData *myData3 = UIImagePNGRepresentation(img);
            
            [myData3 writeToFile:previewImageFile atomically:YES];
            
            if (completeDelegate != nil) {
                [completeDelegate completeZip];
            }
        }
    }
    
    
    self.complete = YES;
    if ([IWInkworksService getInstance].homeInstance) {
        __weak IWHomeController *home = (IWHomeController *)[IWInkworksService getInstance].homeInstance;
        BOOL finished = YES;
        for (IWZipFormDownloaderDelegate *del in home.done.objectEnumerator) {
            if (!del.complete) {
                finished = NO;
            }
        }
        if (finished) {
            [IWInkworksService getInstance].isRefreshing = NO;
            __weak IWMainController *main = (IWMainController *) [IWInkworksService getInstance].mainInstance;
            if (main) {
                [main.spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
            }
        }
    }
//        });
}

- (void) proxyRecievedError:(NSException *)ex InMethod:(NSString *)method {
    
}

- (id) initWithFormId:(long)formid{
    self = [super init];
    if (self){
        self.formId = formid;
        //self.service = [[FormDataWSProxy alloc] initWithUrl:URL AndDelegate:self];
        self.secSvc = [[IWDestFormService alloc] initWithUrl:SecureServiceURL];
        self.secSvc.delegate = self;
    }
    
    return self;
}

- (void) start{
    //[self.service getZipFormSecure:formId :[IWInkworksService getInstance].loggedInUser :[IWInkworksService getInstance].loggedInPassword :NO :@"jamie.duggan@destinywireless.com"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [self.secSvc getZipFormsSecure:(UInt32)formId];
    
}


@end
