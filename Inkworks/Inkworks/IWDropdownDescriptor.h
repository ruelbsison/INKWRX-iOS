//
//  IWDropdownDescriptor.h
//  Inkworks
//
//  Created by Jamie Duggan on 16/04/2014.
//  Copyright (c) 2014 Jamie Duggan. All rights reserved.
//

#define RECT @"rect"
#define LEXICON_ID @"fdtLexicon"

#import "IWFieldDescriptor.h"
#import "IWRectElement.h"

@interface IWDropdownDescriptor : IWFieldDescriptor {
    NSMutableArray *lexicon;
    IWRectElement *rectElement;
    NSString *lexiconId;
    BOOL isCalc;
}

@property (atomic) NSMutableArray *lexicon;
@property (nonatomic) IWRectElement *rectElement;
@property (atomic) NSString *lexiconId;
@property BOOL isCalc;

+ (id) newWithXml:(GDataXMLElement *)aXml atZOrder: (int) aZOrder;
+ (id) newWithOriginal:(IWDropdownDescriptor *)original;
- (void) loadLexiconValues;

@end
