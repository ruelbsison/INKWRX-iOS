//
//  IWDropdownDescriptor.m
//  Inkworks
//
//  Created by Jamie Duggan on 16/04/2014.
//  Copyright (c) 2014 Jamie Duggan. All rights reserved.
//

#import "IWDropdownDescriptor.h"
#import "GDataXMLNode.h"
@implementation IWDropdownDescriptor

@synthesize lexicon;
@synthesize rectElement;
@synthesize lexiconId;
@synthesize isCalc;

- (id) initWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder{
    self = [super initWithXml:aXml atZOrder:aZOrder];
    
    lexicon = [NSMutableArray array];
    lexiconId = @"";
    
    for (GDataXMLNode *att in source.attributes) {
    //TBXMLAttribute *att = source->firstAttribute;
    //while (att) {
        NSString *attName = att.name;
        if ([attName isEqualToString:LEXICON_ID]){
            lexiconId = att.stringValue;
        }
        if ([attName isEqualToString:@"fdtIsCalc"]) {
            NSString *attVal = att.stringValue;
            if ([attVal isEqualToString:@"true"]) {
                isCalc = YES;
            }
        }
        //att = att->next;
    }
    
    for (GDataXMLElement *child in source.children) {
    //TBXMLElement *child = source->firstChild;
    //if (child){
        NSString *elemName = child.name;
        if ([elemName isEqualToString:RECT]){
            rectElement = [IWRectElement newWithXml:child];
            self.strokeColor = rectElement.strokeColor;
            break;
        }
    }
    
    self.x = rectElement.x;
    self.y = rectElement.y;
    self.width = rectElement.width;
    self.height = rectElement.height;
    
    return self;
    
}

- (id) initWithOriginal:(IWDropdownDescriptor *)original {
    self = [super initWithOriginal:original];
    if (self) {
        self.rectElement = original.rectElement;
        self.lexicon = original.lexicon;
        self.lexiconId = original.lexiconId;
        self.isCalc = original.isCalc;
    }
    return self;
}

+ (id) newWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder{
    return [[IWDropdownDescriptor alloc] initWithXml:aXml atZOrder:aZOrder];
}

+ (id) newWithOriginal:(IWDropdownDescriptor *)original {
    return [[IWDropdownDescriptor alloc] initWithOriginal:original];
}

- (void) loadLexiconValues{
    
}

@end
