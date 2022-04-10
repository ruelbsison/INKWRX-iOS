//
//  IWJsonForm.m
//  Inkworks
//
//  Created by Jamie Duggan on 15/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWJsonForm.h"

@implementation IWJsonForm

@synthesize name, formId, amended;

- (id) initWithName:(NSString *)formName andFormId:(NSNumber *)aId andAmended:(NSDate *)date {
    self = [super init];
    if (self) {
        self.name = formName;
        self.formId = aId;
        self.amended = date;
    }
    
    return self;
}

@end
