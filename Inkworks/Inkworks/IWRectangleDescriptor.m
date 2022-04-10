//
//  IWRectangleDescriptor.m
//  Inkworks
//
//  Created by Jamie Duggan on 16/04/2014.
//  Copyright (c) 2014 Jamie Duggan. All rights reserved.
//

#import "IWRectangleDescriptor.h"
#import "GDataXMLNode.h"
@implementation IWRectangleDescriptor


- (id) initWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder {
    self = [super initWithXml:aXml atZOrder:aZOrder];
    
    for (GDataXMLNode *att in source.attributes) {
    //TBXMLAttribute *att = source->firstAttribute;
    //while (att) {
        NSString *attName = att.name;
        if ([attName isEqualToString:FILL]){
            NSString *colorText = att.stringValue;
            
            fillColor = [IWElementDescriptor uiColorFromString:colorText withDefault:[UIColor whiteColor]];
        }
        //att = att->next;
    }
    
    return self;
}

- (id)initWithOriginal:(IWRectangleDescriptor *)original {
    self = [super initWithOriginal:original];
    if (self) {
        self.fillColor = original.fillColor;
    }
    return self;
}

+ (id) newWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder{
    return [[IWRectangleDescriptor alloc] initWithXml:aXml atZOrder:aZOrder];
}

+ (id) newWithOriginal:(IWRectangleDescriptor *)original {
    return [[IWRectangleDescriptor alloc] initWithOriginal:original];
}

@end
