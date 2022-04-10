//
//  IWDrawingFieldDescriptor.m
//  Inkworks
//
//  Created by Jamie Duggan on 16/04/2014.
//  Copyright (c) 2014 Jamie Duggan. All rights reserved.
//

#import "IWDrawingFieldDescriptor.h"
#import "GDataXMLNode.h"

@implementation IWDrawingFieldDescriptor

- (id) initWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder{
    self = [super initWithXml:aXml atZOrder:aZOrder];
    return self;
}

- (id) initWithOriginal:(IWDrawingFieldDescriptor *)original {
    self = [super initWithOriginal:original];
    if (self) {
        
    }
    return self;
}

+ (id) newWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder{
    return [[IWDrawingFieldDescriptor alloc] initWithXml:aXml atZOrder:aZOrder];
}

+ (id) newWithOriginal:(IWDrawingFieldDescriptor *)original {
    return [[IWDrawingFieldDescriptor alloc] initWithOriginal:original];
}

- (NSString *)repeatingFieldId {
    NSString *index =repeatingIndex == -1 ? fieldId : [NSString stringWithFormat:@"%@_%u", fieldId, repeatingIndex];
    return index;
}

@end
