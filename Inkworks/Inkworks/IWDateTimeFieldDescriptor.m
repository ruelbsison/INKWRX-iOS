//
//  IWDateTimeFieldDescriptor.m
//  Inkworks
//
//  Created by Jamie Duggan on 16/04/2014.
//  Copyright (c) 2014 Jamie Duggan. All rights reserved.
//
#define DELIMITER @"fdtDefDelimiter"

#import "IWDateTimeFieldDescriptor.h"
#import "GDataXMLNode.h"

@implementation IWDateTimeFieldDescriptor

@synthesize fdtDelimiter;

- (id) initWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder {
    self = [super initWithXml:aXml atZOrder:aZOrder];
    
    if (self) {
        for (GDataXMLNode *att in source.attributes) {
        //TBXMLAttribute *att = source->firstAttribute;
        //while (att) {
            NSString *attName = att.name;
            if ([attName isEqualToString:DELIMITER]){
                fdtDelimiter = att.stringValue;
                
            }
            //att = att->next;
        }

    }
    return self;
}

- (id) initWithOriginal:(IWDateTimeFieldDescriptor *)original {
    self = [super initWithOriginal:original];
    if (self) {
        self.fdtDelimiter = original.fdtDelimiter;
    }
    return self;
}

+ (id) newWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder {
    return [[IWDateTimeFieldDescriptor alloc] initWithXml:aXml atZOrder:aZOrder];
}

+ (id) newWithOriginal:(IWDateTimeFieldDescriptor *)original {
    return [[IWDateTimeFieldDescriptor alloc] initWithOriginal:original];
}

@end
