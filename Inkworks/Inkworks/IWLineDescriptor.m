//
//  IWLineDescriptor.m
//  Inkworks
//
//  Created by Jamie Duggan on 16/04/2014.
//  Copyright (c) 2014 Jamie Duggan. All rights reserved.
//

#import "IWLineDescriptor.h"
#import "GDataXMLNode.h"

@implementation IWLineDescriptor

@synthesize lineType;
@synthesize x1;
@synthesize x2;
@synthesize y1;
@synthesize y2;

- (id) initWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder{
    self = [super initWithXml:aXml atZOrder:aZOrder];
    
    for (GDataXMLNode *att in source.attributes) {
    //TBXMLAttribute *att = source->firstAttribute;
    //while (att) {
        NSString *attName = att.name;
        if ([attName isEqualToString:X1]){
            x1 = [att.stringValue floatValue];
        } else if ([attName isEqualToString:X2]){
            x2 = [att.stringValue floatValue];
        } else if ([attName isEqualToString:Y1]){
            y1 = [att.stringValue floatValue];
        } else if ([attName isEqualToString:Y2]){
            y2 = [att.stringValue floatValue];
        } else if ([attName isEqualToString:@"fdtType"]){
            NSString *line = att.stringValue;
            lineType = [line stringByReplacingOccurrencesOfString:@"shapeLine" withString:@""];
        }
        //att = att->next;
    }
    
    return self;
}

- (id) initWithOriginal:(IWLineDescriptor *)original {
    self = [super initWithOriginal:original];
    if (self) {
        self.lineType = original.lineType;
        self.x1 = original.x1;
        self.x2 = original.x2;
        self.y1 = original.y1;
        self.y2 = original.y2;
    }
    return self;
}

+ (id) newWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder{
    return [[IWLineDescriptor alloc] initWithXml:aXml atZOrder:aZOrder];
}

+ (id) newWithOriginal:(IWLineDescriptor *)original {
    return [[IWLineDescriptor alloc] initWithOriginal:original];
}

@end
