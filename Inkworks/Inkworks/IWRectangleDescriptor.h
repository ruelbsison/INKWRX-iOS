//
//  IWRectangleDescriptor.h
//  Inkworks
//
//  Created by Jamie Duggan on 16/04/2014.
//  Copyright (c) 2014 Jamie Duggan. All rights reserved.
//

#define FILL @"fill"


#import "IWShapeDescriptor.h"

@interface IWRectangleDescriptor : IWShapeDescriptor {
   
    
}


- (id) initWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder;
- (id) initWithOriginal:(IWRectangleDescriptor *)original;
+ (id) newWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder;
+ (id) newWithOriginal:(IWRectangleDescriptor *)original;
@end
