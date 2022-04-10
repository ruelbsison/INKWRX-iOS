//
//  IWTabletImageDescriptor.m
//  Inkworks
//
//  Created by Jamie Duggan on 10/11/2015.
//  Copyright © 2015 Destiny Wireless. All rights reserved.
//

#import "IWTabletImageDescriptor.h"
#import "IWRectElement.h"
#import "TBXML.h"
#import "GDataXMLNode.h"

@implementation IWTabletImageDescriptor

@synthesize rectElement, rX, rY, strokeWidth;

- (id)initWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder {
    self = [super initWithXml:aXml atZOrder:aZOrder];
    if (self) {
        IWRectElement *rect = [IWRectElement newWithXml:aXml];
        self.rectElement = rect;
        self.fdtFieldName = self.fieldId;
        self.rX = 0;
        self.rY = 0;
        for (GDataXMLNode *att in aXml.attributes) {
        //TBXMLAttribute *att = aXml->firstAttribute;
        //while (att) {
            NSString *attName = att.name;
            if ([attName isEqualToString:@"stroke-width"]){
                strokeWidth = [att.stringValue floatValue];
            } else if ([attName isEqualToString:@"rx"]) {
                self.rX = [att.stringValue floatValue];
            } else if ([attName isEqualToString:@"ry"]) {
                self.rY = [att.stringValue floatValue];
            }else if ([attName isEqualToString:@"stroke"]){
                NSString *colorText = att.stringValue;
                
                self.strokeColor = [IWElementDescriptor uiColorFromString:colorText withDefault:[UIColor blackColor]];
            }
            //att = att->next;
        }
    }
    return self;
}

- (id) initWithOriginal:(IWTabletImageDescriptor *)original {
    self = [super initWithOriginal:original];
    if (self) {
        self.rectElement = original.rectElement;
        self.rX = original.rX;
        self.rY = original.rY;
        self.strokeWidth = original.strokeWidth;
    }
    return self;
}

+ (id)newWithXml:(GDataXMLElement *)element andZOrder:(int)aZOrder {
    return [[IWTabletImageDescriptor alloc] initWithXml:element atZOrder:aZOrder];
}

+ (id)newWithOriginal:(IWTabletImageDescriptor *)original {
    return [[IWTabletImageDescriptor alloc] initWithOriginal:original];
}

@end
