//
//  IWShapeDescriptor.m
//  Inkworks
//
//  Created by Jamie Duggan on 14/04/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//


#import "IWShapeDescriptor.h"
#import "GDataXMLNode.h"
@implementation IWShapeDescriptor

@synthesize strokeWidth;


- (id) initWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder{
    self = [super initWithXml:aXml atZOrder:aZOrder];
    
    for (GDataXMLNode *att in source.attributes) {
    //TBXMLAttribute *att = source->firstAttribute;
    //while (att) {
        NSString *attName = att.name;
        if ([attName isEqualToString:STROKE_WIDTH]){
            strokeWidth = [att.stringValue floatValue];
        } else if ([attName isEqualToString:STROKE]){
            NSString *colorText = att.stringValue;
            
            strokeColor = [IWElementDescriptor uiColorFromString:colorText withDefault:[UIColor blackColor]];
        }
        //att = att->next;
    }
    
    return self;
}

- (id)initWithOriginal:(IWShapeDescriptor *)original {
    self = [super initWithOriginal:original];
    if (self) {
        self.strokeWidth = original.strokeWidth;
        self.strokeColor = original.strokeColor;
    }
    return self;
}

@end
