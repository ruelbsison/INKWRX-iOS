//
//  IWDataChangeHandler.m
//  Inkworks
//
//  Created by Jamie Duggan on 28/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWDataChangeHandler.h"

@implementation IWDataChangeHandler

@synthesize dataChanged, openedFromAutosave;

static IWDataChangeHandler *instance;

+ (IWDataChangeHandler *) getInstance {
    if (instance == nil) {
        instance = [[IWDataChangeHandler alloc] init];
    }
    return instance;
}

@end
