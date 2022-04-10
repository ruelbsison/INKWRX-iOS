//
//  IWElementDescriptor.h
//  Inkworks
//
//  Created by Jamie Duggan on 14/04/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#define X @"x"
#define Y @"y"
#define ID @"id"
#define FDT_TYPE @"fdtType"
#define WIDTH @"width"
#define HEIGHT @"height"
#define X_OFFSET @"dx"
#define Y_OFFSET @"dy"
#define FDT_FIELD_NAME @"fdtFieldName"


#import <Foundation/Foundation.h>
#import "TBXML.h"
@class GDataXMLElement;

@interface IWElementDescriptor : NSObject {
    float x;
    float y;
    
    int zOrder;
    
    GDataXMLElement * source;
    
    long xOffset;
    long yOffset;
    
    float height;
    float width;
    
    NSString * fieldId;
    
    BOOL * fieldOk;
    
    UIColor *strokeColor;
    UIColor *fillColor;
    NSString *fdtFieldName;
    
    int repeatingIndex;
}

@property (nonatomic) float x;
@property (nonatomic) float y;

@property (nonatomic) int zOrder;
@property (nonatomic) GDataXMLElement *source;

@property (nonatomic) long xOffset;
@property (nonatomic) long yOffset;

@property (nonatomic) float height;
@property (nonatomic) float width;

@property (nonatomic) NSString *fieldId;
@property UIColor *strokeColor;
@property UIColor *fillColor;
@property (nonatomic) BOOL *fieldOk;

@property int repeatingIndex;

@property NSString *fdtFieldName;

- (NSString *) repeatingFieldId;
- (id) initWithXml: (GDataXMLElement *) aXml atZOrder: (int) aZOrder;
- (id) initWithOriginal: (IWElementDescriptor *)original;
+ (UIColor *) uiColorFromString:(NSString *) colorText withDefault:(UIColor *) aDefaultColour;
@end
