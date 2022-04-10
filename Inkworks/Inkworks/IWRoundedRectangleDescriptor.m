//
//  IWRoundedRectangleDescriptor.m
//  Inkworks
//
//  Created by Jamie Duggan on 16/04/2014.
//  Copyright (c) 2014 Jamie Duggan. All rights reserved.
//

#import "IWRoundedRectangleDescriptor.h"
#import "GDataXMLNode.h"

@implementation IWRoundedRectangleDescriptor

@synthesize rX;
@synthesize rY;

- (id) initWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder{
    self = [super initWithXml:aXml atZOrder:aZOrder];
    
    for (GDataXMLNode *att in source.attributes) {
    //TBXMLAttribute *att = source->firstAttribute;
    //while (att) {
        NSString *attName = att.name;
        if ([attName isEqualToString:RADIUS_X]){
            rX = [att.stringValue floatValue];
        } else if ([attName isEqualToString:RADIUS_Y]){
            rY = [att.stringValue floatValue];
        }
        //att = att->next;
    }
    
    return self;
}

- (id) initWithOriginal:(IWRoundedRectangleDescriptor *)original {
    self = [super initWithOriginal:original];
    if (self) {
        self.rX = original.rX;
        self.rY = original.rY;
    }
    return self;
}

+ (id) newWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder {
    return [[IWRoundedRectangleDescriptor alloc] initWithXml:aXml atZOrder:aZOrder];
}
+ (id) newWithOriginal:(IWRoundedRectangleDescriptor *)original {
    return [[IWRoundedRectangleDescriptor alloc] initWithOriginal:original];
}


@end
