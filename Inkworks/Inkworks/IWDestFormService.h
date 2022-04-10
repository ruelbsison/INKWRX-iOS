//
//  IWDestFormService.h
//  Inkworks
//
//  Created by Jamie Duggan on 08/08/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "Inkworks-Swift.h"

@class IWDestFormObject;
@class IWTransaction;
@class IWAttachedPhoto;
@class IWInkworksDatabaseHelper;
@class IWFileDescriptionWithTabletInfo;
@class IWFileDescriptionPacketWithTabletInfo;
@class IWDestinyChunkResponseMessage;
@class IWDestinyResponse;
@class IWFilePacketWithTabletInfo;
@class IWEformXmlSaveInfo;
@class IWStartSendFilePacketWithTablet;

@protocol IWDestFormServiceDelegate <NSObject>

- (void) formSendingComplete: (IWTransaction *) transaction completion: (IWDestinyResponse *) response;
- (void) formSendingError: (IWTransaction *) transaction error: (NSString *) error;

- (void) loginComplete: (NSObject *) info completion: (IWDestinyResponse *) response status: (int) status;

- (void) getEformsDownloaded: (NSObject *) info completion: (IWDestinyResponse *) response;
- (void) getZipFormSecureDownloaded: (NSObject *) info completion: (IWDestinyResponse *)response;
@end


@interface IWDestFormService : NSObject {
    NSString *connURL;
    int currentSendingImage;
    NSArray *photoList;
    id<IWDestFormServiceDelegate> delegate;
    IWFileDescriptionPacketWithTabletInfo *fileDesc;
    IWStartSendFilePacketWithTablet *startSendDesc;
    NSData *fileData;
    NSMutableDictionary *filesSent;
    IWTransaction *sendingTransaction;
    NSOperationQueue *queue;
    int nextSendingChunk;
    NSString *originalProc;
}

@property NSString *connURL;
@property int currentSendingImage;
@property NSArray *photoList;
@property id<IWDestFormServiceDelegate> delegate;
@property IWFileDescriptionPacketWithTabletInfo *fileDesc;
@property IWStartSendFilePacketWithTablet *startSendDesc;
@property NSData *fileData;
@property NSMutableDictionary *filesSent;
@property IWTransaction *sendingTransaction;
@property NSOperationQueue *queue;
@property int nextSendingChunk;
@property NSString *originalProc;

- (id) initWithUrl: (NSString *) url;

+ (NSString *) getXmlStringWithName: (NSString *) name andObject: (NSObject *)obj andUrl:(NSString *)url serviceReq:(BOOL) serv;

- (void) sendTransaction: (IWTransaction *)tfBean;
- (void) sendSecureTransaction: (IWTransaction *)tfBean;



#pragma mark Login

- (void)login: (NSString *) username password: (NSString *) password;
- (void)secureLogin: (NSString *) username password: (NSString *) password;

- (void) getPrepopForms;
- (void) getPrepopFormsSecure;

- (void) getEFormsSecure;
- (void) getZipFormsSecure:(int) appKey;



@end
