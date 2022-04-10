//
//  IWTextLabelDescriptor.h
//  Inkworks
//
//  Created by Jamie Duggan on 14/04/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define FONT_FILL @"fill"
#define FONT_FAMILY @"font-family"
#define FONT_SIZE @"font-size"
#define FONT_STYLE @"font-style"
#define FONT_WEIGHT @"font-weight"
#define FONT_DECORATION @"text-decoration"

#import <Foundation/Foundation.h>
#import "IWElementDescriptor.h"
@class GDataXMLElement;
@interface IWTextLabelDescriptor : IWElementDescriptor {
    
    UIColor *textColor;
    int textSize;
    NSString *textStyle;
    NSString *textWeight;
    NSString *fontDecoration;
    NSString *fontFamily;
    
    @private
    BOOL didSetXOffset;
    BOOL didSetYOffset;
    NSMutableAttributedString *attString;
    NSString *textValue;
    
    NSString *lastY;

}

@property (nonatomic) UIColor *textColor;
@property (nonatomic) int textSize;
@property (nonatomic) NSString *textStyle;
@property (nonatomic) NSString *textWeight;
@property (nonatomic) NSString *fontDecoration;
@property (nonatomic) NSString *fontFamily;
@property NSMutableAttributedString *attString;
@property (nonatomic) NSString *textValue;

@property NSString *lastY;

//- (id) initWithXml:(TBXMLElement *)aXml atZOrder:(int)aZOrder;
+ (id) newWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder;
+ (id) newWithOriginal:(IWTextLabelDescriptor *)original;

@end
