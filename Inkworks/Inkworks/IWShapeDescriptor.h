//
//  IWShapeDescriptor.h
//  Inkworks
//
//  Created by Jamie Duggan on 14/04/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#define RECTANGLE @"shapeRect"
#define ROUNDED_RECTANGLE @"shapeRectRounded"

#define STROKE_WIDTH @"stroke-width"
#define STROKE @"stroke"

#import <Foundation/Foundation.h>
#import "IWElementDescriptor.h"

@interface IWShapeDescriptor : IWElementDescriptor {
    
    int strokeWidth;
}

@property (nonatomic) int strokeWidth;

- (id) initWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder;
- (id) initWithOriginal:(IWShapeDescriptor *)original;
@end
