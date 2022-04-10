//
//  IWDestinyConstants.m
//  Inkworks
//
//  Created by Jamie Duggan on 12/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWDestinyConstants.h"

@implementation IWDestinyConstants

static IWDestinyConstants *instance;

+ (IWDestinyConstants *) main {
    if (instance == nil){
        instance = [[IWDestinyConstants alloc] init];
    }
    return instance;
}

@end
