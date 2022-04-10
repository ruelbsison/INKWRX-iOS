//
//  IWZipFormDownloaderDelegate.h
//  Inkworks
//
//  Created by Jamie Duggan on 15/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "FormDataWSProxy.h"
#import "IWDestFormService.h"

@protocol ZipCompletedDelegate <NSObject>

- (void) completeZip;

@end

@interface IWZipFormDownloaderDelegate : NSObject <IWDestFormServiceDelegate> {
    long formId;
    //FormDataWSProxy *service;
    IWDestFormService *secSvc;
    BOOL complete;
    id<ZipCompletedDelegate> completeDelegate;
}

@property long formId;
//@property (retain) FormDataWSProxy *service;
@property (retain) IWDestFormService *secSvc;
@property BOOL complete;
@property id<ZipCompletedDelegate> completeDelegate;

- (id) initWithFormId: (long) formid;
- (void) start;
@end
