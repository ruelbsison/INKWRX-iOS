//
//  IWIsoFieldDescriptor.m
//  Inkworks
//
//  Created by Jamie Duggan on 16/04/2014.
//  Copyright (c) 2014 Jamie Duggan. All rights reserved.
//

#import "IWIsoFieldDescriptor.h"
#import "IWRectElement.h"
#import "IWTextLabelDescriptor.h"
#import "GDataXMLNode.h"

@implementation IWIsoFieldDescriptor

@synthesize rectElements;
@synthesize textLabelDescriptors;
@synthesize fdtFormat;
@synthesize lexiconId;
@synthesize hintChars;
@synthesize fdtListArray;
@synthesize hasDelimiterCharacters, calc, isCalcField, isCalcInput;

- (id) initWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder{
    self = [super initWithXml:aXml atZOrder:aZOrder];
    
    rectElements = [NSMutableArray array];
    textLabelDescriptors = [NSMutableArray array];
    lexiconId = -1;
    calc = nil;
    isCalcField = false;
    
    for (GDataXMLNode *att in source.attributes) {
    //TBXMLAttribute *att = source->firstAttribute;
    //while (att) {
        NSString *attName = att.name;
        if ([attName isEqualToString:FDT_FORMAT]){
            fdtFormat = att.stringValue;
        } else if ([attName isEqualToString:FDT_DEF_LETTERS]){
            hintChars = att.stringValue;
        } else if ([attName isEqualToString:FDT_LEXICON_ID]){
            @try {
                lexiconId = [att.stringValue floatValue];
            } @catch (NSException *e){
                lexiconId = -1;
            }
        } else if ([attName isEqualToString:@"fdtCalc"]) {
            calc = att.stringValue;
            if (![calc isEqualToString:@""]) {
                isCalcField = true;
            } else {
                isCalcInput = true;
            }
        }
        //att = att->next;
    }
    
    int listChar = 0;
    hasDelimiterCharacters = NO;
    NSString *hints = @"DMYH";
    NSMutableString *newListArrayString = [NSMutableString string];
    for (GDataXMLElement *child in source.children) {
    //TBXMLElement *child = source->firstChild;
    //while (child){
        
        NSString *elementName = child.name;
        if ([elementName isEqualToString:RECT]){
            [rectElements addObject:[IWRectElement newWithXml:child]];
            listChar++;
        } else if ([elementName isEqualToString:TEXT] && [hints rangeOfString:child.stringValue].location == NSNotFound){
            hasDelimiterCharacters = YES;
            [textLabelDescriptors addObject:[IWTextLabelDescriptor newWithXml:child atZOrder:aZOrder]];
            if (![newListArrayString isEqualToString:@""]){
                [newListArrayString appendString:@"|"];
            }
            [newListArrayString appendFormat:@"%i", listChar];
            listChar = 0;
        }
        
        //child = child->nextSibling;
    }
    if (![newListArrayString isEqualToString:@""]){
        [newListArrayString appendString:@"|"];
    }
    [newListArrayString appendFormat:@"%i", listChar];
    fdtListArray = newListArrayString;
    
    IWRectElement *firstRect = [rectElements firstObject];
    IWRectElement *lastRect = [rectElements lastObject];
    self.strokeColor = ((IWRectElement *)[rectElements objectAtIndex:0]).strokeColor;
    x = firstRect.x;
    y = firstRect.y;
    height = firstRect.height;
    width = lastRect.x + lastRect.width - firstRect.x;
    
    return self;
}

- (id) initWithOriginal:(IWIsoFieldDescriptor *)original {
    self = [super initWithOriginal:original];
    if (self) {
        self.rectElements = original.rectElements;
        self.textLabelDescriptors = [NSMutableArray array];
        for (IWTextLabelDescriptor *tld in original.textLabelDescriptors) {
            [self.textLabelDescriptors addObject:[IWTextLabelDescriptor newWithOriginal:tld]];
        }
        self.fdtFormat = original.fdtFormat;
        self.lexiconId = original.lexiconId;
        self.hintChars = original.hintChars;
        self.fdtListArray = original.fdtListArray;
        self.isCalcField = original.isCalcField;
        self.isCalcInput = original.isCalcInput;
        self.calc = original.calc;
        self.hasDelimiterCharacters = original.hasDelimiterCharacters;
    }
    return self;
}

+ (id) newWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder{
    return [[IWIsoFieldDescriptor alloc] initWithXml:aXml atZOrder:aZOrder];
}

+ (id)newWithOriginal:(IWIsoFieldDescriptor *)original {
    return [[IWIsoFieldDescriptor alloc] initWithOriginal:original];
}

@end
