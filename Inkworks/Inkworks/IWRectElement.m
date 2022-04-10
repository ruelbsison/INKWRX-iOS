//
//  IWRectElement.m
//  Inkworks
//
//  Created by Jamie Duggan on 17/04/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWRectElement.h"
#import "GDataXMLNode.h"
@implementation IWRectElement

@synthesize x;
@synthesize y;
@synthesize width;
@synthesize height;
@synthesize strokeColor, fillColor;

- (id) initWithXml: (GDataXMLElement *) aXml{
    self = [super init];
    for (GDataXMLNode *att in aXml.attributes) {
    //TBXMLAttribute *att = aXml->firstAttribute;
    //while (att) {
        NSString *attName = att.name;
        if ([attName isEqualToString:X]){
            x = [att.stringValue floatValue];
        } else if ([attName isEqualToString:Y]){
            y = [att.stringValue floatValue];
        }
        else if ([attName isEqualToString:HEIGHT]){
            height = [att.stringValue floatValue];
        }
        else if ([attName isEqualToString:WIDTH]){
            width = [att.stringValue floatValue];
        } else if ([attName isEqualToString:@"stroke"]){
            NSString *colorText = att.stringValue;
            
            strokeColor = [IWRectElement uiColorFromString:colorText withDefault:[UIColor blackColor]];
        } else if ([attName isEqualToString:@"fill"]){
            NSString *colorText = att.stringValue;
            
            fillColor = [IWRectElement uiColorFromString:colorText withDefault:[UIColor whiteColor]];
        }
        
        //att = att->next;
    }

    
    return self;
}

+ (id) newWithXml:(GDataXMLElement *)aXml{
    return [[IWRectElement alloc] initWithXml:aXml];
}

+ (UIColor *) uiColorFromString:(NSString *)colorText withDefault:(UIColor *)aDefaultColour{
    
    @try {
        if ([colorText hasPrefix:@"rgb"]){
            colorText = [[colorText stringByReplacingOccurrencesOfString:@"rgb(" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSArray *stringSplit = [colorText componentsSeparatedByString:@","];
            
            return [UIColor colorWithRed: [[stringSplit objectAtIndex:0] floatValue] green:[[stringSplit objectAtIndex:1] floatValue] blue:[[stringSplit objectAtIndex:2] floatValue] alpha:1.0];
        } else if ([colorText isEqualToString:@"transparent"]){
            return [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        } else {
            return [IWRectElement colorFromHexString:colorText];
        }
    } @catch(NSException *error) {
        
        return aDefaultColour;
    }
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
