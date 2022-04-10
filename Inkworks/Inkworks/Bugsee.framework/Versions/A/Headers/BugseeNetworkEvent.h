//
//  BugseeNetworkEvent.h
//  Bugsee
//
//  Created by ANDREY KOVALEV on 22.07.16.
//  Copyright © 2016 Bugsee. All rights reserved.
//

#import <Foundation/Foundation.h>

// Used to pass this class to decisionBlock() as complition handler
// in bugseeFilterNetworkEvent:completionHandler: delegate
// see documentation page to learn more https://docs.bugsee.com/sdk/ios/privacy/

@interface BugseeNetworkEvent : NSObject

/**
 *  Network event URL
 */
@property (nonatomic, strong) NSString * url;
/**
 *  URL of Network event that we were redirected from
 */
@property (nonatomic, strong) NSString * redirectedFromURL;

/**
 *  Raw body of the request or response were available.
 */
@property (nonatomic, strong) NSData * body;
@property (nonatomic, strong) NSDictionary * error;
/**
 *  HTTP headers
 */
@property (nonatomic, strong) NSDictionary * headers;

/**
 *  Http request method
 */
@property (nonatomic, strong) NSString * method;
@property (nonatomic, strong) NSString * noBodyReason;

/**
 *  Can be one of BugseeNetworkEventBegin, BugseeNetworkEventComplete, BugseeNetworkEventCancel or BugseeNetworkEventError
 *  @see BugseeConstants
 */
@property (nonatomic, strong) NSString * bugseeNetworkEventType;


@property (nonatomic, assign, readonly) BOOL urlChanged;
@property (nonatomic, assign, readonly) BOOL rURLChanged;
@property (nonatomic, assign, readonly) BOOL bodyChanged;
@property (nonatomic, assign, readonly) BOOL errorChanged;
@property (nonatomic, assign, readonly) BOOL headersChanged;

@end
