//
//  IWElementDescriptor.m
//  Inkworks
//
//  Created by Jamie Duggan on 14/04/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWElementDescriptor.h"
#import "GDataXMLNode.h"

@implementation IWElementDescriptor

@synthesize fieldId;
@synthesize x;
@synthesize y;
@synthesize source;
@synthesize xOffset;
@synthesize yOffset;
@synthesize width;
@synthesize fieldOk;
@synthesize height;
@synthesize zOrder;
@synthesize strokeColor, fillColor;
@synthesize fdtFieldName;
@synthesize repeatingIndex;

- (id) initWithXml: (GDataXMLElement *) aXml atZOrder: (int) aZOrder{
    self = [super init];
    
    source = aXml;
    zOrder = aZOrder;
    repeatingIndex = -1;
    for (GDataXMLNode *att in source.attributes) {
    //TBXMLAttribute *att = source->firstAttribute;
    //while (att) {
        NSString *attName = att.name;
        if ([attName isEqualToString:ID]){
            fieldId = att.stringValue;
        } else if ([attName isEqualToString:X]){
            x = [att.stringValue floatValue];
        } else if ([attName isEqualToString:Y]){
            y = [att.stringValue floatValue];
        } else if ([attName isEqualToString:WIDTH]){
            width = [att.stringValue floatValue];
        } else if ([attName isEqualToString:HEIGHT]){
            height = [att.stringValue floatValue];
        } else if ([attName isEqualToString:@"stroke"]){
            
        }
        if ([attName isEqualToString:@"fdtFieldName"]) {
            fdtFieldName = att.stringValue;
        }
    }
    
    return self;
}

- (id)initWithOriginal:(IWElementDescriptor *)original {
    self = [super init];
    if (self) {
        self.repeatingIndex = -1;
        self.fieldId = original.fieldId;
        self.x = original.x;
        self.y = original.y;
        self.source = original.source;
        self.xOffset = original.xOffset;
        self.yOffset = original.yOffset;
        self.width = original.width;
        self.fieldOk = original.fieldOk;
        self.height = original.height;
        self.zOrder = original.zOrder;
        self.strokeColor = original.strokeColor;
        self.fillColor = original.fillColor;
        self.fdtFieldName = original.fdtFieldName;
    }
    return self;
}

-(NSString *)repeatingFieldId {
    return repeatingIndex == -1? fieldId : [NSString stringWithFormat:@"%@_%d", fieldId, repeatingIndex];
}

+ (UIColor *) uiColorFromString:(NSString *)colorText withDefault:(UIColor *)aDefaultColour{
    
    @try {
        if ([colorText hasPrefix:@"rgb"]){
            colorText = [[colorText stringByReplacingOccurrencesOfString:@"rgb(" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSArray *stringSplit = [colorText componentsSeparatedByString:@","];
            
            return [UIColor colorWithRed: [[stringSplit objectAtIndex:0] floatValue]/255 green:[[stringSplit objectAtIndex:1] floatValue]/255 blue:[[stringSplit objectAtIndex:2] floatValue]/255 alpha:1.0];
        } else if ([colorText isEqualToString:@"transparent"]){
            return [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        } else {
            return [IWElementDescriptor colorFromHexString:colorText];
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
