//
//  IWImageDescriptor.h
//  Inkworks
//
//  Created by Jamie Duggan on 14/04/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#define IMAGE_ID @"xlink:href"

#import <Foundation/Foundation.h>
#import "IWElementDescriptor.h"

@interface IWImageDescriptor : IWElementDescriptor {
    NSString *imageId;
}

@property (nonatomic) NSString *imageId;

//- (id) initWithXml:(TBXMLElement *)aXml atZOrder:(int)aZOrder;
+ (id) newWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder;
+ (id) newWithOriginal:(IWImageDescriptor *)original;
@end
