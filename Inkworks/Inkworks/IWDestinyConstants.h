//
//  IWDestinyConstants.h
//  Inkworks
//
//  Created by Jamie Duggan on 12/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#pragma mark Main URL

#pragma mark ======== Prelive
#define sPreliveURL @"http://inkworksprelive.destinywireless.com/formdataws.asmx?WSDL"
#define sNewPreliveURL @"http://inkworksprelive.destinywireless.com/formmanager/service/DestFormService.svc?wsdl"
#define sPreliveSvcURL @"http://inkworksprelive.destinywireless.com/servicecenter/service/ServiceCenterService.svc"
#define sPreliveSecureFormsURL @"http://inkworksprelive.destinywireless.com/formmanagersec/service/DestFormServiceSec.svc"
#define sPreliveSecureServiceURL @"http://inkworksprelive.destinywireless.com/servicecentersec/service/SvcCenterSecService.svc"

#pragma mark ======== Live
#define sLiveURL @"http://inkworks.destinywireless.com/formdataws.asmx?WSDL"
#define sNewLiveURL @"http://inkworks.destinywireless.com/formmanager/service/DestFormService.svc?wsdl"
#define sLiveSvcURL @"http://inkworks.destinywireless.com/servicecenter/service/ServiceCenterService.svc"
#define sLiveSecureFormsURL @"https://cloud.inkwrx.com/formmanagersec/service/DestFormServiceSec.svc"
#define sLiveSecureServiceURL @"https://cloud.inkwrx.com/servicecentersec/service/SvcCenterSecService.svc"
//#define sLiveSecureFormsURL @"http://inkworks.destinywireless.com/formmanagersec/service/DestFormServiceSec.svc"
//#define sLiveSecureServiceURL @"http://inkworks.destinywireless.com/servicecentersec/service/SvcCenterSecService.svc"


#pragma mark ======== Dev
#define sDevURL @"http://inkworksdev.destinywireless.com/formdataws.asmx?WSDL"
#define sNewDevURL @"http://inkworksdev.destinywireless.com/formmanager/service/DestFormService.svc?wsdl"
#define sDevSvcURL @"http://inkworksdev.destinywireless.com/servicecenter/service/ServiceCenterService.svc"
#define sDevSecureFormsURL @"http://inkworksdev.destinywireless.com/formmanagersec/service/DestFormServiceSec.svc"
#define sDevSecureServiceURL @"http://inkworksdev.destinywireless.com/servicecentersec/service/SvcCenterSecService.svc"

#pragma mark ======== N3
#define sN3URL @"http://inkworksn3.destinywireless.local/formdataws.asmx?WSDL"
#define sNewN3URL @"http://inkworksn3.destinywireless.local/formmanager/service/DestFormService.svc?wsdl"
#define sN3SvcURL @"http://inkworksn3.destinywireless.local/servicecenter/service/ServiceCenterService.svc"
#define sN3SecureFormsURL @"https://mobileinkworksn3.destinywireless.com/formmanagersec/service/DestFormServiceSec.svc"
#define sN3SecureServiceURL @"https://mobileinkworksn3.destinywireless.com/servicecentersec/service/SvcCenterSecService.svc"


#pragma mark Server Ints
#define sLive 0
#define sPrelive 1

#define sServer sLive

//redundant
#pragma mark Old Servers
#define URL sLiveURL
#define NewURL sNewLiveURL
#define SvcURL sLiveSvcURL

#pragma mark New Servers
#define SecureFormsURL sLiveSecureFormsURL
#define SecureServiceURL sLiveSecureServiceURL
// REMEMBER TO CHANGE BUGSEE KEY IN BUILD PHASE

#pragma mark Status

#define STATUS_SENDING @"Sending"
#define STATUS_SENT @"Sent"
#define STATUS_PARKED @"Parked"
#define STATUS_AUTOSAVED @"Autosaved"

#define USE_SECURE YES

#pragma mark Screens
#define HOME @"HOME"
#define FORM_LIST @"FORM_LIST"
#define FORM_VIEW @"FORM_VIEW"
#define HISTORY @"HISTORY"
#define HISTORY_SAVED @"HISTORY_SAVED"
#define HISTORY_SENT @"HISTORY_SENT"
#define HISTORY_SENDING @"HISTORY_SENDING"
#define HISTORY_AUTOSAVED @"HISTORY_AUTOSAVED"

#pragma mark Buttons (also using some of the screen names)
#define CLEAR @"CLEAR"
#define SAVE @"SAVE"
#define SEND @"SEND"
#define REFRESH @"REFRESH"
#define BACK @"BACK"

#pragma mark SavedSettings
#define REMEMBER_PASSWORD @"REMEMBER_PASSWORD"
#define SAVED_PASSWORD @"SAVED_PASSWORD"
#define SAVED_USERNAME @"SAVED_USERNAME"
#define HIDE_PARK_NOTIFICATION @"HIDE_PARK_NOTIFICATION"
#define HIDE_CLEAR_NOTIFICATION @"HIDE_CLEAR_NOTIFICATION"
#define HIDE_SEND_NOTIFICATION @"HIDE_SEND_NOTIFICATION"
#define SAVE_TO_GALLERY @"SAVE_TO_GALLERY"


#import <Foundation/Foundation.h>

@interface IWDestinyConstants : NSObject{
    
}

+ (IWDestinyConstants *) main;

@end
