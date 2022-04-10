//
//  IWRectElement.h
//  Inkworks
//
//  Created by Jamie Duggan on 17/04/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#define X @"x"
#define Y @"y"
#define WIDTH @"width"
#define HEIGHT @"height"

#import <Foundation/Foundation.h>
#import "TBXML.h"
@class GDataXMLElement;

@interface IWRectElement : NSObject {
    float x;
    float y;
    float width;
    float height;
    
    UIColor *strokeColor;
    UIColor *fillColor;
}

@property float x;
@property float y;
@property float width;
@property float height;

@property UIColor *strokeColor;
@property UIColor *fillColor;

+ (id) newWithXml: (GDataXMLElement *) aXml;

@end
