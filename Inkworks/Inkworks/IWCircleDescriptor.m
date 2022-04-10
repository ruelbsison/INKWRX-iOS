//
//  IWCircleDescriptor.m
//  Inkworks
//
//  Created by Jamie Duggan on 12/02/2016.
//  Copyright © 2016 Destiny Wireless. All rights reserved.
//

#import "IWCircleDescriptor.h"
#import "GDataXMLNode.h"

@implementation IWCircleDescriptor

@synthesize cX, cY, r;

- (id) initWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder {
    self = [super initWithXml:aXml atZOrder:aZOrder];
    
    for (GDataXMLNode *att in source.attributes) {
    //TBXMLAttribute *att = source->firstAttribute;
    //while (att) {
        NSString *attName = att.name;
        if ([attName isEqualToString:FILL]){
            NSString *colorText = att.stringValue;
            
            fillColor = [IWElementDescriptor uiColorFromString:colorText withDefault:[UIColor whiteColor]];
        } else if ([attName isEqualToString:@"cx"]) {
            NSString *cXText = att.stringValue;
            if (cXText != nil && ![cXText isEqualToString:@""]) {
                self.cX = [cXText floatValue];
            }
        } else if ([attName isEqualToString:@"cy"]) {
            NSString *cYText = att.stringValue;
            
            if (cYText != nil && ![cYText isEqualToString:@""]) {
                self.cY = [cYText floatValue];
            }
        } else if ([attName isEqualToString:@"r"]) {
            NSString *rText = att.stringValue;
            
            if (rText != nil && ![rText isEqualToString:@""]) {
                self.r = [rText floatValue];
            }
        }
        //att = att->next;
    }
    
    return self;
}

- (id)initWithOriginal:(IWCircleDescriptor *)original {
    self = [super initWithOriginal:original];
    if (self) {
        self.fillColor = original.fillColor;
        self.cX = original.cX;
        self.cY = original.cY;
        self.r = original.r;
    }
    return self;
}

+ (id) newWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder{
    return [[IWCircleDescriptor alloc] initWithXml:aXml atZOrder:aZOrder];
}

+ (id) newWithOriginal:(IWCircleDescriptor *)original {
    return [[IWCircleDescriptor alloc] initWithOriginal:original];
}

@end
