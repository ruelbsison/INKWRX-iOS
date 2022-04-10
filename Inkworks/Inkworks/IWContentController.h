//
//  IWContentController.h
//  Inkworks
//
//  Created by Jamie Duggan on 13/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//
#define HOME_CONTENT_NAME @"HOME"
#define HISTORY_CONTENT_NAME @"HISTORY"
#define HISTORY_PARKED_CONTENT_NAME @"HISTORY_PARKED"
#define HISTORY_SENT_CONTENT_NAME @"HISTORY_SENT"
#define HISTORY_SENDING_CONTENT_NAME @"HISTORY_SENDING"
#define HISTORY_AUTOSAVED_CONTENT_NAME @"HISTORY_AUTOSAVED"
#define FORM_VIEW_CONTENT_NAME @"FORM_VIEW"
#define FORM_LIST_CONTENT_NAME @"FORM_LIST"

#import <UIKit/UIKit.h>
@class IWInkworksService;
//#import "FormDataWSProxy.h"
@class IWDestinyConstants;

@class IWDestFormService;
@interface IWContentController : UIViewController  {
    NSString *windowTitle;
    NSString *viewName;
    //FormDataWSProxy *service;
    IWDestFormService *secureService;
    NSTimer *oriTimer;
}

@property (strong, nonatomic) NSString *windowTitle;
@property (strong, nonatomic) NSString *viewName;
//@property (retain) FormDataWSProxy *service;
@property (retain) IWDestFormService *secureService;
- (void) orientationChanged;
@property NSTimer *oriTimer;
@end
