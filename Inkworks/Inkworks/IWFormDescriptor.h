//
//  IWFormDescriptor.h
//  Inkworks
//
//  Created by Jamie Duggan on 16/04/2014.
//  Copyright (c) 2014 Jamie Duggan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"



@interface IWFormDescriptor : NSObject {
    
    GDataXMLDocument * source;
    NSMutableArray * pageDescriptors;
    
    long formHeight;
    long formWidth;
    
    NSMutableDictionary *mandatoryCheckBoxGroups;
    NSMutableArray *mandatoryFields;
    NSMutableArray *mandatoryRadioGroups;
    NSMutableDictionary *allFieldIds;
    NSMutableArray *formCalcFields;
}

@property (nonatomic) GDataXMLDocument * source;
@property (nonatomic) NSMutableArray * pageDescriptors;
@property (nonatomic) long formHeight;
@property (nonatomic) long formWidth;
@property NSMutableDictionary *mandatoryCheckBoxGroups;
@property NSMutableArray *mandatoryFields;
@property NSMutableArray *mandatoryRadioGroups;
@property NSMutableArray *formCalcFields;
@property NSMutableDictionary *allFieldIds;

- (void) nilAll;
- (long) numberOfPages;
- (BOOL) fieldIsOnPage: (NSString *)fieldId;
+ (id) newWithString: (NSString *)aXmlString;
+ (id) newWithXml: (GDataXMLDocument *) aXmlElement;
+ (id) newWithXml: (GDataXMLDocument *) aXmlElement onePage:(BOOL)onePage;
@end
