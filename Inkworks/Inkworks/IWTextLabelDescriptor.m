//
//  IWTextLabelDescriptor.m
//  Inkworks
//
//  Created by Jamie Duggan on 14/04/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWTextLabelDescriptor.h"
#import "GDataXMLNode.h"

@implementation IWTextLabelDescriptor


@synthesize textColor;
@synthesize textSize;
@synthesize textStyle;
@synthesize textWeight;
@synthesize fontDecoration;
@synthesize fontFamily;
@synthesize textValue;
@synthesize lastY;
@synthesize attString;

- (void) processTSpanElementWithXml:(GDataXMLElement *) aXml isFirstElement:(BOOL)first baseAtts:(NSDictionary *)baseAtts {
    [self processTSpanElementWithXml:aXml isFirstElement:first baseAtts:baseAtts baseString:nil];
}

- (void) processTSpanElementWithXml:(GDataXMLElement *) aXml isFirstElement:(BOOL)first baseAtts:(NSDictionary *) baseAtts baseString: (NSMutableAttributedString *) baseStr {
    
    UIColor *thistextColor = baseAtts[NSForegroundColorAttributeName];
    int thistextSize = [baseAtts[@"FONTSIZE"] intValue];
    NSNumber *thistextStyle = baseAtts[NSObliquenessAttributeName];
    NSString *thistextWeight = baseAtts[@"BOLD"];
    NSNumber *thisfontDecoration = baseAtts[NSUnderlineStyleAttributeName];
    NSString *thisfontFamily = baseAtts[@"FONTFAMILY"];
    
    
    BOOL addNewLine = NO;
    NSMutableAttributedString *thisString = [[NSMutableAttributedString alloc] initWithString:@""];
    BOOL starttaghere = NO;
    //TBXMLAttribute *att = aXml->firstAttribute;
    BOOL changed = NO;
    for (GDataXMLNode *att in aXml.attributes) {
    //while (att) {
        NSString *attName = att.name;
        if ([attName isEqualToString:@"starttag"]) {
            if (baseStr && baseStr.length > 0) {
                addNewLine = YES;
                starttaghere = YES;
            }
        }
        if ([attName isEqualToString:@"display"]) {
            if ([att.stringValue isEqualToString:@"none"]) {
                return;
            }
        }
        
        if ([attName isEqualToString:X_OFFSET]){
            if (!didSetXOffset){
                xOffset = [att.stringValue floatValue];
                didSetXOffset = YES;
            }
        } else if ([attName isEqualToString:Y_OFFSET]){
            
            NSString *thisY = att.stringValue;
            if (lastY == nil) {
                lastY = thisY;
            } else {

                if (![lastY isEqualToString:@"0"] && [thisY isEqualToString:@"0"]) {
                    int lastYInt = [lastY intValue];
                    y -= lastYInt;
                }
            }
            if (![thisY isEqualToString:lastY] && ![thisY isEqualToString:@"0"]) {
                //textValue = [textValue stringByAppendingString:@"\n"];
                if (![baseAtts[@"BASESTART"] isEqualToString:@"YES"]) {
                    addNewLine = YES;
                }
                changed = YES;
                //lastY = thisY;
            } /*else if (![thisY isEqualToString:lastY]) {
                //textValue = [textValue stringByAppendingString:@"\n"];
                if (![baseAtts[@"BASESTART"] isEqualToString:@"YES"]) {
                    addNewLine = YES;
                }
                changed = YES;
                //lastY = thisY;
            }*/
            
            if (!didSetYOffset){
                yOffset = [att.stringValue floatValue];
                didSetYOffset = YES;
            }
            
            
        } else if ([attName isEqualToString:FONT_FAMILY]){
            thisfontFamily = att.stringValue;
        } else if ([attName isEqualToString:FONT_DECORATION]){
            thisfontDecoration = [att.stringValue isEqualToString:@"underline"] ? @(NSUnderlineStyleSingle) : @(NSUnderlineStyleNone);
        } else if ([attName isEqualToString:FONT_FILL]){
            // Color stuff....
            NSString *colorText = att.stringValue;
            
            thistextColor = [IWElementDescriptor uiColorFromString:colorText withDefault:[UIColor blackColor]];
            
        } else if ([attName isEqualToString:FONT_SIZE]){
            thistextSize = [[[att.stringValue stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"pt" withString:@""] floatValue] - 1;
        } else if ([attName isEqualToString:FONT_STYLE]){
            thistextStyle = [att.stringValue isEqualToString:@"italic"] ? @(0.4) : @(0.0);
        } else if ([attName isEqualToString:FONT_WEIGHT]){
            thistextWeight = att.stringValue;
        }
        
        //att = att->next;
    }
    
    NSMutableDictionary *passedAtts = @{
                                 NSForegroundColorAttributeName : thistextColor,
                                 @"FONTSIZE" : @(thistextSize),
                                 NSObliquenessAttributeName : thistextStyle,
                                 @"BOLD" : thistextWeight,
                                 NSUnderlineStyleAttributeName : thisfontDecoration,
                                 @"FONTFAMILY" : thisfontFamily,
                                 @"BASESTART" : (starttaghere ? @"YES" : @"NO")
                                 }.mutableCopy;
    
    NSDictionary *fonts = @{
                                   @"arial narrow": @"ArialNarrow",
                                   @"arial":@"ArialMT",
                                   @"times new roman":@"TimesNewRomanPSMT",
                                   @"times new roman,times":@"TimesNewRomanPSMT",
                                   @"times new roman, times":@"TimesNewRomanPSMT",
                                   @"tahoma": @"Tahoma"
                            };
    
    NSMutableDictionary *attribs = [NSMutableDictionary dictionary];
    
    NSString *newFontName = [fonts objectForKey:thisfontFamily != nil ? [thisfontFamily lowercaseString] : @"arial"];
    if (!newFontName) {
        newFontName = @"ArialMT";
    }
    NSString *fontAddition;
    if ([thistextWeight isEqualToString:@"bold"]){
        fontAddition = @"-Bold";
    } else {
        fontAddition = @"";
    }
    
    
    newFontName = [newFontName stringByAppendingString:fontAddition];
    if ([newFontName isEqualToString:@"ArialMT-Bold"]){
        newFontName = @"Arial-BoldMT";
    }
    if ([newFontName isEqualToString:@"TimesNewRomanPSMT-Bold"]){
        newFontName = @"TimesNewRomanPS-BoldMT";
    }
    
    UIFont *font = [UIFont fontWithName: newFontName size:(((float)thistextSize) / 3.0) * 4.0];
    [attribs setObject:font forKey:NSFontAttributeName];
    
    [attribs setObject:thisfontDecoration forKey:NSUnderlineStyleAttributeName];
    
    [attribs setObject:thistextStyle forKey:NSObliquenessAttributeName];
    
    [attribs setObject:thistextColor forKey:NSForegroundColorAttributeName];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:0];
    [attribs setObject:style forKey:NSParagraphStyleAttributeName];
    
    if (addNewLine ) {
        NSMutableAttributedString *addString = [[NSMutableAttributedString alloc] initWithString:@"\n" attributes:attribs];
        [thisString appendAttributedString:addString];
    }
    
    
    //TBXMLElement *child = aXml->firstChild;
    if (aXml.childCount > 0){
        for (GDataXMLElement *child in aXml.children) {
        //while (child){
            if ([child isKindOfClass:[GDataXMLElement class]]) {
                [self processTSpanElementWithXml:child isFirstElement:NO baseAtts:[passedAtts copy] baseString:thisString];
                passedAtts[@"BASESTART"] = [NSString stringWithFormat:@"%@1", passedAtts[@"BASESTART"]];
            } else {
            //if ([child isKindOfClass:[GDataXMLNode class]]) {
                NSMutableAttributedString *addString = [[NSMutableAttributedString alloc] initWithString:child.stringValue attributes:attribs];
                [thisString appendAttributedString:addString];
            }
            //child = child->nextSibling;
        }
    }
    
    if (baseStr) {
        [baseStr appendAttributedString:thisString];
    } else {
        [attString appendAttributedString:thisString];
    }
    
    
}

- (id) initWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder{
    self = [super initWithXml:aXml atZOrder:aZOrder];
    textColor = [UIColor blackColor];
    textStyle = @"";
    textSize = 14;
    textWeight = @"normal";
    fontDecoration = @"none";
    fontFamily = @"arial";
    textValue = @"";
    attString = [[NSMutableAttributedString alloc] initWithString:@""];
    NSDictionary *passedAtts = @{
                                 NSForegroundColorAttributeName : textColor,
                                 @"FONTSIZE" : @(textSize),
                                 NSObliquenessAttributeName : [textStyle isEqualToString:@"italic"] ? @(0.4) : @(0.0),
                                 @"BOLD" : textWeight,
                                 NSUnderlineStyleAttributeName : [fontDecoration isEqualToString:@"underline"] ? @(NSUnderlineStyleSingle) : @(NSUnderlineStyleNone),
                                 @"FONTFAMILY" : fontFamily,
                                 @"BASESTART": @"NO"
                                 };
    
    [self processTSpanElementWithXml:source isFirstElement:YES baseAtts:passedAtts];
    textValue = [textValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return self;
}

- (id) initWithOriginal:(IWTextLabelDescriptor *)original {
    self = [super initWithOriginal:original];
    if (self) {
        self.textColor = original.textColor;
        self.textStyle = original.textStyle;
        self.textSize = original.textSize;
        self.textWeight = original.textWeight;
        self.fontDecoration = original.fontDecoration;
        self.fontFamily = original.fontFamily;
        self.textValue = original.textValue;
        self.attString = original.attString;
    }
    return self;
}

+ (id) newWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder {
    return [[IWTextLabelDescriptor alloc] initWithXml:aXml atZOrder:aZOrder];
}

+ (id)newWithOriginal:(IWTextLabelDescriptor *)original {
    return [[IWTextLabelDescriptor alloc] initWithOriginal:original];
}

@end
