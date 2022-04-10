//
//  IWImageDescriptor.m
//  Inkworks
//
//  Created by Jamie Duggan on 14/04/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWImageDescriptor.h"
#import "GDataXMLNode.h"

@implementation IWImageDescriptor

@synthesize imageId;

+ (id) newWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder{
    return [[IWImageDescriptor alloc] initWithXml:aXml atZOrder:aZOrder];
}

+ (id) newWithOriginal:(IWImageDescriptor *)original {
    return [[IWImageDescriptor alloc] initWithOriginal:original];
}

- (id) initWithOriginal:(IWImageDescriptor *)original {
    self = [super initWithOriginal:original];
    if (self) {
        self.imageId = original.imageId;
    }
    return self;
}

- (id) initWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder{
    self = [super initWithXml:aXml atZOrder:aZOrder];
    
    for (GDataXMLNode *att in source.attributes) {
    //TBXMLAttribute *att = source->firstAttribute;
    //while (att) {
        NSString *attName = att.name;
        if ([attName isEqualToString:IMAGE_ID]){
            imageId = [[att.stringValue stringByReplacingOccurrencesOfString:@"/ImageHandler.ashx?id=" withString:@""] stringByReplacingOccurrencesOfString:@"&amp;border=false" withString:@""];
        }
        //att = att->next;
    }

    
    return self;
}

@end
