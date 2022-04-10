//
//  IWTabletImageDescriptor.h
//  Inkworks
//
//  Created by Jamie Duggan on 10/11/2015.
//  Copyright © 2015 Destiny Wireless. All rights reserved.
//

#import "IWFieldDescriptor.h"
@class IWRectElement;
@class GDataXMLElement;

@interface IWTabletImageDescriptor : IWFieldDescriptor {
    IWRectElement *rectElement;
    float rX;
    float rY;
    int strokeWidth;
}

@property IWRectElement *rectElement;
@property float rX;
@property float rY;
@property int strokeWidth;

+ (id) newWithXml: (GDataXMLElement *)element andZOrder:(int) aZOrder;
+ (id) newWithOriginal: (IWTabletImageDescriptor *) original;

@end
