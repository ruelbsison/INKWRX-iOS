//
//  IWFieldDescriptor.m
//  Inkworks
//
//  Created by Jamie Duggan on 14/04/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//


#define FONT_FILL @"fill"
#define FONT_FAMILY @"font-family"
#define FONT_SIZE @"font-size"
#define FONT_STYLE @"font-style"
#define FONT_WEIGHT @"font-weight"
#define FONT_DECORATION @"text-decoration"


#import "IWFieldDescriptor.h"
#import "TBXML.h"
#import "GDataXMLNode.h"

@implementation IWFieldDescriptor

@synthesize fdtType, mandatory;


- (id) initWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder{
    self = [super initWithXml:aXml atZOrder:aZOrder];
    
    for (GDataXMLNode *att in source.attributes) {
    //TBXMLAttribute *att = source->firstAttribute;
    //while (att) {
        NSString *attName = att.name;
        if ([attName isEqualToString:FDT_TYPE]){
            fdtType = att.stringValue;
        }
        if ([attName isEqualToString:@"fdtMandatory"]){
            mandatory = [att.stringValue isEqualToString:@"true"];
        }
        //att = att->next;
    }
    
    
    return self;
}

- (id)initWithOriginal:(IWFieldDescriptor *)original {
    self = [super initWithOriginal:original];
    if (self) {
        self.fdtType = original.fdtType;
        self.mandatory = original.mandatory;
    }
    return self;
}

@end
