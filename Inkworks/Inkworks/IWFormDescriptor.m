//
//  IWFormDescriptor.m
//  Inkworks
//
//  Created by Jamie Duggan on 14/04/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWFormDescriptor.h"
#import "IWPageDescriptor.h"
#import "Inkworks-Swift.h"

@implementation IWFormDescriptor

@synthesize source;
@synthesize pageDescriptors;
@synthesize formWidth;
@synthesize formHeight;
@synthesize mandatoryCheckBoxGroups, mandatoryFields, mandatoryRadioGroups, formCalcFields, allFieldIds;


-(long) numberOfPages {
    return pageDescriptors.count;
}

-(id) init {
    self = [super init];
    if (self) {
        formCalcFields = [NSMutableArray array];
    }
    return self;
}

+ (id) newWithString:(NSString *)aXmlString{
    return [[IWFormDescriptor alloc] initWithString:aXmlString];
}

-(id) initWithString:(NSString *)aXmlString {
    self = [self init];
    
    NSError * error;
    GDataXMLDocument * xmlDoc = [[GDataXMLDocument alloc] initWithXMLString:aXmlString options:0 error:&error];
    return [self initWithXml:xmlDoc onePage:NO];
    
}

+ (id) newWithXml:(GDataXMLDocument *)aXmlString {
    return [IWFormDescriptor newWithXml:aXmlString onePage:NO];
}

+ (id) newWithXml:(GDataXMLDocument *)aXmlElement onePage:(BOOL)onePage{
    return [[IWFormDescriptor alloc] initWithXml:aXmlElement onePage:onePage];
}

- (BOOL)fieldIsOnPage:(NSString *)fieldId {
    for (IWPageDescriptor *page in pageDescriptors) {
        if ([page fieldIsOnPage:fieldId]) {
            return true;
        }
    }
    return false;
}

- (id) initWithXml:(GDataXMLDocument *)aXmlElement onePage:(BOOL) onePage {
    self = [self init];
    if (self) {
        NSString *xml = aXmlElement.rootElement.XMLString;
        mandatoryCheckBoxGroups = [NSMutableDictionary dictionary];
        mandatoryFields = [NSMutableArray array];
        mandatoryRadioGroups = [NSMutableArray array];
        allFieldIds = [NSMutableDictionary dictionary];
        pageDescriptors = [NSMutableArray array];
        
        source = aXmlElement;
        GDataXMLElement *root = [source rootElement];
        NSString *xmlStr = root.XMLString;
        //GDataXMLElement * secondDivElement = [[root children] firstObject];
        //TBXMLElement * pageDiv = secondDivElement->firstChild;
        
        int pageNumber = 1;
        int realPageNumber = 1;
        for (; pageNumber <= root.children.count;pageNumber++) {
            GDataXMLElement *element = root.children[pageNumber-1];
            IWPageDescriptor *page = [IWPageDescriptor newWithXml:element asPageNumber:realPageNumber];
            if (page.output) {
                continue;
            }
            [allFieldIds addEntriesFromDictionary:page.allFieldIds];
            [pageDescriptors addObject:page];
            [formCalcFields addObjectsFromArray:page.pageCalcFields];
            
            [mandatoryFields addObjectsFromArray:page.mandatoryFields];
            [mandatoryRadioGroups addObjectsFromArray:page.mandatoryRadioGroups];
            
            [mandatoryCheckBoxGroups addEntriesFromDictionary:page.mandatoryCheckBoxGroups];
            
            if (pageDescriptors.count == 1){
                formWidth = ((IWPageDescriptor *)[pageDescriptors firstObject]).pageWidth;
                formHeight = ((IWPageDescriptor *)[pageDescriptors firstObject]).pageHeight;
            }
            realPageNumber++;
            
            if (onePage) break;
        }
        
        formCalcFields = [[IWCalcList getOrderedCalcList:formCalcFields] mutableCopy];
    }
    return self;
}

- (void) nilAll {
    for (IWPageDescriptor *page in pageDescriptors) {
        [page nilAll];
    }
    pageDescriptors = nil;
}

@end

