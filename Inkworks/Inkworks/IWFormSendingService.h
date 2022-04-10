//
//  IWFormSendingService.h
//  Inkworks
//
//  Created by Jamie Duggan on 21/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "FormDataWS/FormDataWSProxy.h"
#import "IWDestFormService.h"

@interface IWFormSendingService : NSObject < IWDestFormServiceDelegate> {
    NSOperationQueue *queue;
    NSTimer *delayTimer;
    NSDate *lastFail;
}

@property NSOperationQueue *queue;
@property NSTimer *delayTimer;
@property NSDate *lastFail;

+ (IWFormSendingService *) getInstance;

@end
