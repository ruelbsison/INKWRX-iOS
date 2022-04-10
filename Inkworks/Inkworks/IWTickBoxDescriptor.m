//
//  IWTickBoxDescriptor.m
//  Inkworks
//
//  Created by Jamie Duggan on 16/04/2014.
//  Copyright (c) 2014 Jamie Duggan. All rights reserved.
//

#import "IWTickBoxDescriptor.h"
#import "GDataXMLNode.h"

@implementation IWTickBoxDescriptor

@synthesize tickBoxSize;

- (id) initWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder{
    self = [super initWithXml:aXml atZOrder:aZOrder];
    if (self) {
        if (self) {
            switch ((int)floor(self.rectElement.width)) {
                case 11:
                    self.tickBoxSize = SMALL;
                    break;
                case 24:
                    self.tickBoxSize = LARGE;
                    break;
                default:
                    self.tickBoxSize = NORMAL;
                    break;
            }
        }
    }
    return self;
}

- (id) initWithOriginal:(IWTickBoxDescriptor *)original {
    self = [super initWithOriginal:original];
    
    if (self) {
        self.tickBoxSize = original.tickBoxSize;
    }
    
    return self;
}

+ (id) newWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder{
    return [[IWTickBoxDescriptor alloc] initWithXml:aXml atZOrder:aZOrder];
}

+ (id)newWithOriginal:(IWTickBoxDescriptor *)original {
    return [[IWTickBoxDescriptor alloc] initWithOriginal:original];
}

@end
