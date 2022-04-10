//
//  IWDecimalFieldDescriptor.m
//  Inkworks
//
//  Created by Jamie Duggan on 16/04/2014.
//  Copyright (c) 2014 Jamie Duggan. All rights reserved.
//

#import "IWDecimalFieldDescriptor.h"

@implementation IWDecimalFieldDescriptor

- (id) initWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder {
    self = [super initWithXml:aXml atZOrder:aZOrder];
    if (self) {
        
        
    }
    
    return self;
}

- (id) initWithOriginal:(IWDecimalFieldDescriptor *)original {
    self = [super initWithOriginal:original];
    if (self) {
        
    }
    return self;
}

+ (id) newWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder {
    return [[IWDecimalFieldDescriptor alloc] initWithXml:aXml atZOrder:aZOrder];
}

+ (id)newWithOriginal:(IWDecimalFieldDescriptor *)original {
    return [[IWDecimalFieldDescriptor alloc] initWithOriginal:original];
}

@end
