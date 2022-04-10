//
//  IWIsoFieldDescriptor.h
//  Inkworks
//
//  Created by Jamie Duggan on 16/04/2014.
//  Copyright (c) 2014 DestinyWireless. All rights reserved.
//

#define FDT_FORMAT @"fdtFormat"
#define FDT_DEF_LETTERS @"fdtDefLetters"
#define FDT_LEXICON_ID @"fdtLexicon"

#define RECT @"rect"
#define TEXT @"text"

//Listed here for convenience; worked out manually as currently (16/04/2014) incorrect from webservice.
#define FDT_LIST_ARRAY @"fdtListArray"

#import "IWFieldDescriptor.h"

@interface IWIsoFieldDescriptor : IWFieldDescriptor {
    @public
    
    NSMutableArray *rectElements;
    NSMutableArray *textLabelDescriptors;
    NSString *hintChars;
    int lexiconId;
    NSString *fdtFormat;
    NSString *fdtListArray;
    BOOL isCalcInput;
    NSString *calc;
    BOOL isCalcField;
    
    BOOL hasDelimiterCharacters;
}

@property (nonatomic) NSMutableArray *rectElements;
@property (nonatomic) NSMutableArray *textLabelDescriptors;
@property (nonatomic) NSString *hintChars;
@property (nonatomic) int lexiconId;
@property (nonatomic) NSString *fdtFormat;
@property (nonatomic) NSString *fdtListArray;
@property (nonatomic) BOOL hasDelimiterCharacters;
@property (nonatomic) NSString *calc;
@property (nonatomic) BOOL isCalcField;
@property (nonatomic) BOOL isCalcInput;

- (id) initWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder;
- (id) initWithOriginal:(IWIsoFieldDescriptor *)original;
+ (id) newWithXml:(GDataXMLElement *)aXml atZOrder: (int) aZOrder;
+ (id) newWithOriginal:(IWIsoFieldDescriptor *)original;
@end
