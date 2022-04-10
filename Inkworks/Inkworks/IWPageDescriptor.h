//
//  IWPageDescriptor.h
//  Inkworks
//
//  Created by Jamie Duggan on 14/04/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"
#import "GDataXMLNode.h"

@interface IWPageDescriptor : NSObject {
    GDataXMLElement * source;
    
    int pageNumber;
    int realPageNumber;
    
    NSMutableArray * fieldDescriptors;
    NSMutableArray * imageDescriptors;
    NSMutableArray * textLabelDescriptors;
    NSMutableArray * shapeDescriptors;
    
    NSMutableDictionary *radioGroups;
    NSMutableDictionary *repeatingRadioGroups;
    
    NSMutableDictionary *pageTriggers;
    BOOL andTriggers;
    BOOL visible;
    NSMutableArray *panels;
    NSMutableDictionary *allFieldIds;
    
    long pageWidth;
    long pageHeight;
    
    BOOL pageOk;
    
    @private
    int zOrderCount;
    
    NSMutableDictionary *mandatoryCheckBoxGroups;
    NSMutableArray *mandatoryFields;
    NSMutableArray *mandatoryRadioGroups;
    
    NSMutableDictionary *panelPointers;
    
    NSMutableArray *pageCalcFields;
    
    BOOL output;
}

@property (nonatomic) GDataXMLElement * source;
@property NSMutableDictionary *allFieldIds;
@property (nonatomic) int pageNumber;
@property (nonatomic) int realPageNumber;

@property (nonatomic) NSMutableArray * fieldDescriptors;
@property (nonatomic) NSMutableArray * imageDescriptors;
@property (nonatomic) NSMutableArray * textLabelDescriptors;
@property (nonatomic) NSMutableArray * shapeDescriptors;

@property (nonatomic) NSMutableDictionary *radioGroups;
@property (nonatomic) NSMutableDictionary *repeatingRadioGroups;

@property NSMutableDictionary *pageTriggers;
@property BOOL andTriggers;
@property BOOL visible;
@property NSMutableArray *panels;

@property BOOL output;

@property NSMutableDictionary *panelPointers;


@property NSMutableDictionary *mandatoryCheckBoxGroups;
@property NSMutableArray *mandatoryFields;
@property NSMutableArray *mandatoryRadioGroups;

@property (nonatomic) long pageWidth;
@property (nonatomic) long pageHeight;

@property (nonatomic) BOOL pageOk;
@property (nonatomic) NSMutableArray *pageCalcFields;
@property int zOrderCount;

- (void) nilAll;
+ (id) newWithXml: (GDataXMLElement *) aXmlElement asPageNumber:(int)aPageNumber;
-(BOOL) shouldShow;
- (BOOL) fieldIsOnPage:(NSString *)fieldId;
@end
