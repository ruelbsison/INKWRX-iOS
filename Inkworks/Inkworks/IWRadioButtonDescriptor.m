//
//  IWRadioButtonDescriptor.m
//  Inkworks
//
//  Created by Jamie Duggan on 16/04/2014.
//  Copyright (c) 2014 Jamie Duggan. All rights reserved.
//

#import "IWRadioButtonDescriptor.h"

@implementation IWRadioButtonDescriptor


- (id) initWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder{
    self = [super initWithXml:aXml atZOrder:aZOrder];
    
    return self;
}

- (id) initWithOriginal:(IWRadioButtonDescriptor *)original {
    self = [super initWithOriginal:original];
    if (self) {
        
    }
    return self;
}

+ (id) newWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder{
    return [[IWRadioButtonDescriptor alloc] initWithXml:aXml atZOrder:aZOrder];
}

+ (id)newWithOriginal:(IWRadioButtonDescriptor *)original {
    return [[IWRadioButtonDescriptor alloc] initWithOriginal:original];
}

@end
