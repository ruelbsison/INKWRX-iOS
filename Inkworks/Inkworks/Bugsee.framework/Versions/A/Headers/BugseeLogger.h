//
//  BugseeLogger.h
//  Bugsee
//
//  Created by ANDREY KOVALEV on 29.11.15.
//  Copyright © 2016 Bugsee. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BugseeLumberjackLogger (id <DDLogger>)[BugseeLogger sharedInstance]

typedef enum : NSUInteger {
    BugseeLogLevelLow = 0,
    BugseeLogLevelError,
    BugseeLogLevelWarning,
    BugseeLogLevelInfo,
    BugseeLogLevelDebug,
    BugseeLogLevelVerbose
} BugseeLogLevel;

@interface BugseeLogger : NSObject 

+ (instancetype) sharedInstance;

@end


