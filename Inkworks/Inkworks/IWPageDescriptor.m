//
//  IWPageDescriptor.m
//  Inkworks
//
//  Created by Jamie Duggan on 14/04/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWPageDescriptor.h"
#import "IWImageDescriptor.h"
#import "IWTextLabelDescriptor.h"
#import "IWRectangleDescriptor.h"
#import "IWRoundedRectangleDescriptor.h"
#import "IWLineDescriptor.h"
#import "IWIsoFieldDescriptor.h"
#import "IWDateTimeFieldDescriptor.h"
#import "IWDecimalFieldDescriptor.h"
#import "IWNoteFieldDescriptor.h"
#import "IWDropdownDescriptor.h"
#import "IWDrawingFieldDescriptor.h"
#import "IWRadioButtonDescriptor.h"
#import "IWTickBoxDescriptor.h"
#import "IWDynamicPanel.h"
#import "Inkworks-Swift.h"
#import "IWTabletImageDescriptor.h"
#import "IWCircleDescriptor.h"



@implementation IWPageDescriptor



@synthesize source;

@synthesize pageNumber, realPageNumber;

@synthesize fieldDescriptors;
@synthesize imageDescriptors;
@synthesize textLabelDescriptors;
@synthesize shapeDescriptors;

@synthesize radioGroups;

@synthesize pageHeight;
@synthesize pageWidth;

@synthesize pageOk;

@synthesize zOrderCount, pageCalcFields, allFieldIds;

@synthesize mandatoryRadioGroups, mandatoryFields, mandatoryCheckBoxGroups;

@synthesize repeatingRadioGroups, pageTriggers, andTriggers, visible, panels, panelPointers, output;

-(id) init{
    self = [super init];
    if (self) {
        self.repeatingRadioGroups = [NSMutableDictionary dictionary];
        self.pageTriggers = [NSMutableDictionary dictionary];
        self.pageCalcFields = [NSMutableArray array];
        self.andTriggers = NO;
        self.visible = YES;
        self.panels = [NSMutableArray array];
    }
    return self;
}

+ (id) newWithXml:(GDataXMLElement *)aXmlElement asPageNumber:(int)aPageNumber{
    return [[IWPageDescriptor alloc] initWithXml:aXmlElement asPageNumber:aPageNumber];
}

-(id) initWithXml:(GDataXMLElement *)aXmlElement asPageNumber:(int)aPageNumber{
    self = [self init];
    mandatoryCheckBoxGroups = [NSMutableDictionary dictionary];
    mandatoryFields = [NSMutableArray array];
    mandatoryRadioGroups = [NSMutableArray array];
    panels = [NSMutableArray array];
    pageTriggers = [NSMutableDictionary dictionary];
    repeatingRadioGroups = [NSMutableDictionary dictionary];
    panelPointers = [NSMutableDictionary dictionary];
    source = aXmlElement;
    pageNumber = aPageNumber;
    output = NO;
    self.allFieldIds = [NSMutableDictionary dictionary];
    
    for (GDataXMLNode *sourceAtt in source.attributes) {
        NSString *attName = sourceAtt.name;
        NSString *attValue = sourceAtt.stringValue;
        
        if ([attName isEqualToString:@"id"]) {
            self.realPageNumber = [[attValue stringByReplacingOccurrencesOfString:@"formSide" withString:@""] intValue];
        }
        if ([attName isEqualToString:@"fdtpageuse"]) {
            //NSString *pageUse = [TBXML attributeValue:sourceAtt];
            if ([[attValue lowercaseString] isEqualToString:@"output"]) {
                visible = NO;
                output = YES;
            }
        }
        
        if ([attName isEqualToString:@"fdtpagetype"]) {
            //NSString *pageType = [TBXML attributeValue:sourceAtt];
            if ([[attValue lowercaseString] isEqualToString:@"conditional"]) {
                visible = NO;
            }
        }
        
        if ([attName isEqualToString:@"fdtpageconditionalfields"]){
            NSString *s = [[[[[attValue stringByReplacingOccurrencesOfString:@" and " withString:@"&"] stringByReplacingOccurrencesOfString:@" or " withString:@"|"] stringByReplacingOccurrencesOfString:@";" withString:@"&"] stringByReplacingOccurrencesOfString:@"," withString:@"|"] stringByReplacingOccurrencesOfString:@" " withString:@""];
            if ([s rangeOfString:@"|"].location != NSNotFound || [s rangeOfString:@"&"].location != NSNotFound) {
                NSArray *split;
                if ([s rangeOfString:@"|"].location != NSNotFound) {
                    split = [s componentsSeparatedByString:@"|"];
                    andTriggers = NO;
                } else {
                    split = [s componentsSeparatedByString:@"&"];
                    andTriggers = YES;
                    
                }
                for (NSString *st in split) {
                    [pageTriggers setObject:@0 forKey:st];
                    
                }
                
            } else {
                [pageTriggers setObject:@0 forKey:s];
            }
            
        }
        
    }
    
    
    pageOk = NO;
    
    fieldDescriptors = [NSMutableArray array];
    imageDescriptors = [NSMutableArray array];
    textLabelDescriptors = [NSMutableArray array];
    shapeDescriptors = [NSMutableArray array];
    
    radioGroups = [NSMutableDictionary dictionary];
    
    GDataXMLElement *firstSvg = [source.children firstObject];
    if (!firstSvg) return self;
    
    GDataXMLElement *secondSvg = [firstSvg.children firstObject];
    
    if (!secondSvg) return self;
    
    for (GDataXMLNode *att in secondSvg.attributes) {
        NSString *attName = att.name;
        NSString *attValue = att.stringValue;
        
        if ([attName isEqualToString:@"viewBox"]) {
            NSArray *viewBoxVals = [attValue componentsSeparatedByString:@" "];
            pageWidth = [viewBoxVals[2] floatValue];
            pageHeight = [viewBoxVals[3] floatValue];
            break;
        }
    }
    
    GDataXMLElement *pageNode = nil;
    
    for (GDataXMLElement *pageNode1 in secondSvg.children) {
        BOOL rubberBandBox = NO;
        BOOL mainNode = NO;
        NSString *nodeName = pageNode1.name;
        if (![nodeName isEqualToString:@"g"]){
            continue;
        }
        
        for (GDataXMLNode *nodeAtt in pageNode1.attributes) {
            NSString *attName1 = nodeAtt.name;
            if ([attName1 isEqualToString:@"class"]){
                NSString *classValue = nodeAtt.stringValue;
                if ([classValue isEqualToString:@"rubberBandBox"]){
                    rubberBandBox = YES;
                    continue;
                }
            }
            if ([attName1 isEqualToString:@"id"]){
                NSString *idVal = nodeAtt.stringValue;
                if ([idVal rangeOfString:@"Main"].location != NSNotFound){
                    mainNode = YES;
                    pageNode = pageNode1;
                    break;
                }
            }
        }
        
        if (mainNode && !rubberBandBox) {
            break;
        }
    }
    
    if (!pageNode) return self;
    zOrderCount = 0;

    for (GDataXMLElement *element in pageNode.children) {
        [self processElementWithXml:element];
    }

    for (IWDynamicPanel *panel in panels) {
        IWRectElement *r = panel.rectArea;
        for (IWFieldDescriptor *fd in fieldDescriptors) {
            if (fd.y > r.y + r.height) {
                [panel.fieldBelowPanel addObject:fd];
                continue;
            }
            
            if (fd.y >= r.y) {
                panel.shouldMoveFieldsBelow = NO;
                continue;
            }
            
            if (fd.y + fd.height > r.y) {
                panel.shouldMoveFieldsBelow = NO;
            }
        }
        
        
        for (NSString *s in radioGroups.keyEnumerator) {
            NSMutableArray *list = radioGroups[s];
            for (IWRadioButtonDescriptor *fd in list) {
                if (fd.y > r.y + r.height) {
                    [panel.fieldBelowPanel addObject:fd];
                    continue;
                }
                
                if (fd.y >= r.y) {
                    panel.shouldMoveFieldsBelow = NO;
                    continue;
                }
                
                if (fd.y + fd.height > r.y) {
                    panel.shouldMoveFieldsBelow = NO;
                }
            }
        }
        
        for (IWDynamicPanel *dp in panels) {
            if (dp == panel) continue;
            IWRectElement *fd = dp.rectArea;
            if (fd.y > r.y + r.height) {
                [panel.fieldBelowPanel addObject:fd];
                continue;
            }
            
            if (fd.y >= r.y) {
                panel.shouldMoveFieldsBelow = NO;
                continue;
            }
            
            if (fd.y + fd.height > r.y) {
                panel.shouldMoveFieldsBelow = NO;
            }
        }
    }
    
    pageOk = YES;
    
    return self;
}

- (void) processElementWithXml:(GDataXMLElement *) element{
    [self processElementWithXml:element andArray:nil];
}

- (void) processElementWithXml:(GDataXMLElement *) element andArray:(NSMutableArray *) list{
    NSString *elementName = element.name;
    
    if ([elementName isEqualToString:@"rect"]) {
        
        BOOL tabletImage = NO;
        BOOL roundedRect = NO;
        //TBXMLAttribute *rectAtt = element->firstAttribute;
        
        for (GDataXMLNode *rectAtt in element.attributes) {
        //while (rectAtt) {
            NSString *rectAttName = rectAtt.name;
            NSString *rectAttVal = rectAtt.stringValue;
            //NSString *rectAttName = [TBXML attributeName:rectAtt];
            if ([rectAttName isEqualToString:@"fdtSignatureOptions"]) {
                //NSString *rectAttVal = [TBXML attributeValue:rectAtt];
                if ([rectAttVal isEqualToString:@"Tablet Image"]) {
                    tabletImage = YES;
                }
            } else if ([rectAttName isEqualToString:@"fdtType"]) {
                //NSString *rectAttVal = [TBXML attributeValue:rectAtt];
                if ([rectAttVal isEqualToString:ROUNDED_RECTANGLE]) {
                    roundedRect = YES;
                }
            }
            //rectAtt = rectAtt->next;
        }
        
        if (tabletImage) {
            //tablet image
            if (list == nil) {
                [fieldDescriptors addObject:[IWTabletImageDescriptor newWithXml:element andZOrder:zOrderCount]];
            } else {
                [list addObject:[IWTabletImageDescriptor newWithXml:element andZOrder:zOrderCount]];
            }
        } else {
            if (list == nil)
                [shapeDescriptors addObject:(roundedRect ? [IWRoundedRectangleDescriptor newWithXml:element atZOrder:zOrderCount] :  [IWRectangleDescriptor newWithXml:element atZOrder:zOrderCount])];
            else
                [list addObject:(roundedRect ? [IWRoundedRectangleDescriptor newWithXml:element atZOrder:zOrderCount] :  [IWRectangleDescriptor newWithXml:element atZOrder:zOrderCount])];
        }
        
        
     
        zOrderCount++;
        return;
    }
    
    if ([elementName isEqualToString:@"image"]){
        if (list == nil)
            [imageDescriptors addObject: [IWImageDescriptor newWithXml:element atZOrder:zOrderCount]];
        else
            [list addObject:[IWImageDescriptor newWithXml:element atZOrder:zOrderCount]];
        zOrderCount++;
        return;
    }
    
    if ([elementName isEqualToString:@"line"]){
        if (list == nil)
            [shapeDescriptors addObject: [IWLineDescriptor newWithXml:element atZOrder:zOrderCount]];
        else
            [list addObject:[IWLineDescriptor newWithXml:element atZOrder:zOrderCount]];
        zOrderCount++;
        return;
    }
    
    if ([elementName isEqualToString:@"text"]){
        if (list == nil)
            [textLabelDescriptors addObject:[IWTextLabelDescriptor newWithXml:element atZOrder:zOrderCount]];
        else
            [list addObject:[IWTextLabelDescriptor newWithXml:element atZOrder:zOrderCount]];
        zOrderCount++;
        return;
    }
    
    if ([elementName isEqualToString:@"circle"]) {
        if (list == nil) {
            [shapeDescriptors addObject:[IWCircleDescriptor newWithXml:element atZOrder:zOrderCount]];
        } else {
            [list addObject:[IWCircleDescriptor newWithXml:element atZOrder:zOrderCount]];
        }
        zOrderCount++;
        return;
    }
    
    //only other option here is "g" which is either a group or a field...
    //we determine this by seeing if an attribute of "fdtType" exists on the g element...
    GDataXMLNode *gTypeAtt;
    for (gTypeAtt in element.attributes) {
    //TBXMLAttribute *gTypeAtt = element->firstAttribute;
    //while (gTypeAtt){
        
        NSString *attName = gTypeAtt.name;
        if ([attName isEqualToString:@"fdtType"]){
            //break here leaving "gTypeAtt" as a valid object
            break;
        }
        
        //gTypeAtt = gTypeAtt->next;
    }
    
    if (gTypeAtt){
        //field
        NSString *fdtType = gTypeAtt.stringValue;
        if ([fdtType isEqualToString:ISO_FIELD]){
            IWIsoFieldDescriptor *testIsoDescriptor = [IWIsoFieldDescriptor newWithXml:element atZOrder:zOrderCount];
            IWIsoFieldDescriptor *thisIso = nil;
            switch (testIsoDescriptor.lexiconId) {
                case 13:
                case 14:
                case 20:
                case 21:
                case 22:
                case 23:
                case 15:
                    
                    if (list == nil){
                        thisIso = [IWDateTimeFieldDescriptor newWithXml:element atZOrder:zOrderCount];
                        [fieldDescriptors addObject:thisIso];
                    }
                    else{
                        thisIso = [IWDateTimeFieldDescriptor newWithXml:element atZOrder:zOrderCount];
                        [list addObject:thisIso];
                    }
                    break;
                case 18:
                    if (list == nil){
                        thisIso = [IWDecimalFieldDescriptor newWithXml:element atZOrder:zOrderCount];
                        [fieldDescriptors addObject:thisIso];
                    }
                    else{
                        thisIso = [IWDecimalFieldDescriptor newWithXml:element atZOrder:zOrderCount];
                        [list addObject:thisIso];
                    }
                    
                    break;
                default:
                    if ([[testIsoDescriptor.fdtFormat lowercaseString] isEqualToString:@"decimal"]){
                        if (list == nil){
                            thisIso = [IWDecimalFieldDescriptor newWithXml:element atZOrder:zOrderCount];
                            [fieldDescriptors addObject:thisIso];
                        }
                        else {
                            thisIso = [IWDecimalFieldDescriptor newWithXml:element atZOrder:zOrderCount];
                            [list addObject:thisIso];
                        }
                    } else {
                        
                        thisIso = testIsoDescriptor;
                        if (list == nil)
                            [fieldDescriptors addObject:testIsoDescriptor];
                        else
                            [list addObject:testIsoDescriptor];
                    }
                    
                    break;
            }
            
            if (thisIso.isCalcField) {
                IWCalcList *calcItem = [[IWCalcList alloc] init];
                calcItem.descriptor = thisIso;
                calcItem.fieldName = thisIso.fdtFieldName;
                calcItem.inputs = [IWCalcList getFieldListFromString:thisIso.calc];
                [pageCalcFields addObject:calcItem];
            }
            
            if (thisIso.mandatory){
                if (![mandatoryFields containsObject:thisIso]) {
                    [mandatoryFields addObject:thisIso];
                }
            }
            IWFieldDescriptor *testDesc = [[IWFieldDescriptor alloc] initWithXml:element atZOrder:zOrderCount];
            allFieldIds[testDesc.fieldId] = testDesc.fdtFieldName;
        } else if ([fdtType isEqualToString:TICK_BOX]){
            IWTickBoxDescriptor *tbd = [IWTickBoxDescriptor newWithXml:element atZOrder:zOrderCount];
            
            if (list == nil)
                [fieldDescriptors addObject:tbd];
            else
                [list addObject:tbd];
            
            
            if (tbd.mandatory){
                
                if (tbd.groupName && ![tbd.groupName isEqualToString:@""]) {
                    if ([mandatoryCheckBoxGroups objectForKey:tbd.groupName] == nil) {
                        [mandatoryCheckBoxGroups setObject:[NSMutableArray array] forKey:tbd.groupName];
                    }
                    [((NSMutableArray *)mandatoryCheckBoxGroups[tbd.groupName]) addObject:tbd.fieldId];
                } else {
                    [mandatoryFields addObject:tbd];
                }
            }
            IWFieldDescriptor *testDesc = [[IWFieldDescriptor alloc] initWithXml:element atZOrder:zOrderCount];
            allFieldIds[testDesc.fieldId] = testDesc.fdtFieldName;
        } else if ([fdtType isEqualToString:RADIO]){
            IWRadioButtonDescriptor *radioDescriptor = [IWRadioButtonDescriptor newWithXml:element atZOrder:zOrderCount];
            if (list == nil) {
                NSMutableArray *radioList;
                if ([radioGroups objectForKey:radioDescriptor.groupName]){
                    radioList = [radioGroups objectForKey:radioDescriptor.groupName];
                } else {
                    radioList = [NSMutableArray array];
                }
                [radioList addObject:radioDescriptor];
                [radioGroups setObject:radioList forKey:radioDescriptor.groupName];
            } else {
                if (![list containsObject:radioDescriptor.groupName]) {
                    [list addObject:radioDescriptor.groupName];
                    
                    
                }
                NSMutableArray *radioList;
                if ([repeatingRadioGroups objectForKey:radioDescriptor.groupName]){
                    radioList = [repeatingRadioGroups objectForKey:radioDescriptor.groupName];
                } else {
                    radioList = [NSMutableArray array];
                }
                [radioList addObject:radioDescriptor];
                [repeatingRadioGroups setObject:radioList forKey:radioDescriptor.groupName];
                
            }
            if (radioDescriptor.mandatory) {
                if (![mandatoryRadioGroups containsObject:radioDescriptor.groupName]) {
                    [mandatoryRadioGroups addObject:radioDescriptor.groupName];
                }
            }
            IWFieldDescriptor *testDesc = [[IWFieldDescriptor alloc] initWithXml:element atZOrder:zOrderCount];
            allFieldIds[testDesc.fieldId] = testDesc.fdtFieldName;
        } else if ([fdtType isEqualToString:NOTES] || [fdtType isEqualToString:NOTES2]){
            IWNoteFieldDescriptor *thisNotes = nil;
            if (list == nil) {
                thisNotes = [IWNoteFieldDescriptor newWithXml:element atZOrder:zOrderCount];
                [fieldDescriptors addObject:thisNotes];
            }
            else{
                thisNotes = [IWNoteFieldDescriptor newWithXml:element atZOrder:zOrderCount];
                [list addObject:thisNotes];
            }
            if (thisNotes.mandatory){
                if (![mandatoryFields containsObject:thisNotes]) {
                    [mandatoryFields addObject:thisNotes];
                }
            }
            IWFieldDescriptor *testDesc = [[IWFieldDescriptor alloc] initWithXml:element atZOrder:zOrderCount];
            allFieldIds[testDesc.fieldId] = testDesc.fdtFieldName;
        } else if ([fdtType isEqualToString:SIGNATURE_FIELD] || [fdtType isEqualToString:SKETCHBOX]){
            IWDrawingFieldDescriptor *thisDrawing = nil;
            if (list == nil){
                thisDrawing =[IWDrawingFieldDescriptor newWithXml:element atZOrder:zOrderCount];
                [fieldDescriptors addObject:thisDrawing];
            }
            else {
                thisDrawing = [IWDrawingFieldDescriptor newWithXml:element atZOrder:zOrderCount];
                [list addObject:thisDrawing];
            }
            if (thisDrawing.mandatory){
                if (![mandatoryFields containsObject:thisDrawing]) {
                    [mandatoryFields addObject:thisDrawing];
                }
            }
            IWFieldDescriptor *testDesc = [[IWFieldDescriptor alloc] initWithXml:element atZOrder:zOrderCount];
            allFieldIds[testDesc.fieldId] = testDesc.fdtFieldName;
        } else if ([fdtType isEqualToString:DROP_DOWNN]){
            IWDropdownDescriptor *thisDropDown = nil;
            if (list == nil){
                thisDropDown = [IWDropdownDescriptor newWithXml:element atZOrder:zOrderCount];
                [fieldDescriptors addObject:thisDropDown];
            }
            else{
                thisDropDown = [IWDropdownDescriptor newWithXml:element atZOrder:zOrderCount];
                [list addObject:thisDropDown];
            }
            
            if (thisDropDown.mandatory){
                if (![mandatoryFields containsObject:thisDropDown]) {
                    [mandatoryFields addObject:thisDropDown];
                }
            }
            IWFieldDescriptor *testDesc = [[IWFieldDescriptor alloc] initWithXml:element atZOrder:zOrderCount];
            allFieldIds[testDesc.fieldId] = testDesc.fdtFieldName;
        } else if ([fdtType isEqualToString:RECTANGLE]){
            BOOL tabletImage = NO;
            for (GDataXMLNode *rectAtt in element.attributes) {
            //TBXMLAttribute *rectAtt = element->firstAttribute;
            //while (rectAtt) {
                NSString *rectAttName = rectAtt.name;
                if ([rectAttName isEqualToString:@"fdtSignatureOptions"]) {
                    NSString *rectAttVal = rectAtt.stringValue;
                    if ([rectAttVal isEqualToString:@"Tablet Image"]) {
                        tabletImage = YES;
                    }
                }
                //rectAtt = rectAtt->next;
            }
            
            if (tabletImage) {
                //tablet image
                if (list == nil) {
                    [fieldDescriptors addObject:[IWTabletImageDescriptor newWithXml:element andZOrder:zOrderCount]];
                } else {
                    [list addObject:[IWTabletImageDescriptor newWithXml:element andZOrder:zOrderCount]];
                }
            } else {
                if (list == nil)
                    [shapeDescriptors addObject:[IWRectangleDescriptor newWithXml:element atZOrder:zOrderCount]];
                else
                    [list addObject:[IWRectangleDescriptor newWithXml:element atZOrder:zOrderCount]];
            }
        } else if ([fdtType isEqualToString:ROUNDED_RECTANGLE]){
            BOOL tabletImage = NO;
            for (GDataXMLNode *rectAtt in element.attributes) {
            //TBXMLAttribute *rectAtt = element->firstAttribute;
            //while (rectAtt) {
                NSString *rectAttName = rectAtt.name;
                if ([rectAttName isEqualToString:@"fdtSignatureOptions"]) {
                    NSString *rectAttVal = rectAtt.stringValue;
                    if ([rectAttVal isEqualToString:@"Tablet Image"]) {
                        tabletImage = YES;
                    }
                }
                //rectAtt = rectAtt->next;
            }

            if (tabletImage) {
                if (list == nil) {
                    [fieldDescriptors addObject:[IWTabletImageDescriptor newWithXml:element andZOrder:zOrderCount]];
                } else {
                    [list addObject:[IWTabletImageDescriptor newWithXml:element andZOrder:zOrderCount]];
                }
                IWFieldDescriptor *testDesc = [[IWFieldDescriptor alloc] initWithXml:element atZOrder:zOrderCount];
                allFieldIds[testDesc.fieldId] = testDesc.fdtFieldName;
            } else {
                if (list == nil)
                    [shapeDescriptors addObject:[IWRoundedRectangleDescriptor newWithXml:element atZOrder:zOrderCount]];
                else {
                    [list addObject:[IWRoundedRectangleDescriptor newWithXml:element atZOrder:zOrderCount]];
                }
            }
        }
        
        
        if ([fdtType isEqualToString:@"panelPanel"]) {
            return;
        }
        zOrderCount++;
        return;
        
        
    }
    GDataXMLNode *panel;
    for (panel in element.attributes) {
    //TBXMLAttribute *panel = element->firstAttribute;
    //while (panel){
        
        NSString *attName = panel.name;
        if ([attName isEqualToString:@"panelContainer"]){
            //break here leaving "panel" as a valid object
            break;
        }
        
        //panel = panel->next;
    }

    if (panel && [panel.stringValue isEqualToString:@"true"]) {
        GDataXMLElement *firstRect = [element.children firstObject];
        //TBXMLElement *firstRect = element->firstChild;
        IWDynamicPanel *dynamicPanel = [IWDynamicPanel panel];
        [panelPointers setObject:dynamicPanel forKey:[NSString stringWithFormat:@"%p", dynamicPanel]];
        if (list) {
            dynamicPanel.shouldMoveFieldsBelow = NO;
        }
        
        GDataXMLNode *fieldId;
        //TBXMLAttribute *fieldId = element->firstAttribute;
        //while (panel){
        for (fieldId in element.attributes){
            NSString *attName = fieldId.name;
            if ([attName isEqualToString:@"id"]){
                //break here leaving "panel" as a valid object
                break;
            }
            
            //fieldId = fieldId->next;
        }

        if (fieldId) {
            dynamicPanel.fieldId = fieldId.stringValue;
        }
        
        GDataXMLNode *gvisible;
        for (gvisible in firstRect.attributes) {
        //TBXMLAttribute *gvisible = firstRect->firstAttribute;
        //while (gvisible){
            
            NSString *attName = gvisible.name;
            if ([attName isEqualToString:@"fdtpaneltype"]){
                //break here leaving "panel" as a valid object
                break;
            }
            
            //gvisible = gvisible->next;
        }

        GDataXMLNode *repeating;
        for (repeating in firstRect.attributes) {
        //TBXMLAttribute *repeating = firstRect->firstAttribute;
        //while (repeating){
            
            NSString *attName = repeating.name;
            if ([attName isEqualToString:@"fdtrepeating"]){
                //break here leaving "panel" as a valid object
                break;
            }
            
            //repeating = repeating->next;
        }

        dynamicPanel.panelInitiallyVisible = !gvisible || ![gvisible.stringValue isEqualToString:@"conditional"];
        
        
        [self setPanelElementTriggers:firstRect forPanel:dynamicPanel];
        dynamicPanel.repeatingPanel = repeating && [repeating.stringValue isEqualToString:@"true"];
        if (dynamicPanel.repeatingPanel) {
            //dynamicPanel.panelInitiallyVisible = YES;
        }
        
        IWRectElement *r = [IWRectElement newWithXml:firstRect];
        NSMutableArray *panelList = [NSMutableArray array];
        dynamicPanel.rectArea = r;
        
        for (GDataXMLElement *elementChild in element.children) {
        //TBXMLElement *elementChild = element->firstChild;
        //elementChild = elementChild->nextSibling;
        //while (elementChild){
            
            //recursion here to drill down into the groups...
            
            [self processElementWithXml:elementChild andArray:panelList];
            
            //elementChild = elementChild->nextSibling;
        }
        dynamicPanel.children = panelList;
        if (!list) {
            [panels addObject:dynamicPanel];
            [panelPointers setObject:dynamicPanel forKey:[NSString stringWithFormat:@"%p", dynamicPanel]];
        } else {
            [list addObject:dynamicPanel];
        }
        
        
        
        return;
    }
    
        //group... or just a random g element (can happen)
    for (GDataXMLElement *elementChild in element.children) {
        //TBXMLElement *elementChild = element->firstChild;
        //while (elementChild){
            
            //recursion here to drill down into the groups...
            
            [self processElementWithXml:elementChild andArray:list];
            
            //elementChild = elementChild->nextSibling;
        }
        
    
    
    
}

-(void) setPanelElementTriggers:(GDataXMLElement *) rect forPanel:(IWDynamicPanel *) panel {
    NSMutableDictionary *triggers = [NSMutableDictionary dictionary];
    GDataXMLNode *panelFields;
    for (panelFields in rect.attributes) {
    //TBXMLAttribute *panelFields = rect->firstAttribute;
    //while (panelFields){
        
        NSString *attName = panelFields.name;
        if ([attName isEqualToString:@"fdtconditionalfields"]){
            //break here leaving "panel" as a valid object
            break;
        }
        
        //panelFields = panelFields->next;
    }

    if (panelFields) {
        NSString *s = [[[[[panelFields.stringValue stringByReplacingOccurrencesOfString:@" and " withString:@"&"] stringByReplacingOccurrencesOfString:@" or " withString:@"|"] stringByReplacingOccurrencesOfString:@";" withString:@"&"] stringByReplacingOccurrencesOfString:@"," withString:@"|"] stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([s rangeOfString:@"|"].location != NSNotFound || [s rangeOfString:@"&"].location != NSNotFound) {
            NSArray *split;
            if ([s rangeOfString:@"|"].location != NSNotFound) {
                split = [s componentsSeparatedByString:@"|"];
                panel.andTriggers = NO;
            } else {
                split = [s componentsSeparatedByString:@"&"];
                panel.andTriggers = YES;
                
            }
            for (NSString *st in split) {
                [triggers setObject:@0 forKey:st];
                
            }
            
        } else {
            if ([s isEqualToString:@""]) {
                return;
            }
            [triggers setObject:@0 forKey:s];
        }
    }
    
    
    panel.panelTriggers = triggers;
    for (NSString *key in panel.panelTriggers.keyEnumerator) {
        [panel.panelTriggersNegated setObject:@0 forKey:key];
    }
    
    
}

-(BOOL) shouldShow {
    if (self.pageTriggers.count == 0) {
        return visible;
        
    }
    
    if (self.andTriggers) {
        NSDictionary *triggers = [pageTriggers copy];
        for (NSString *s in triggers) {
            NSNumber *b = pageTriggers[s];
            
            if ([b isEqualToNumber:@0] && [s rangeOfString:@"!"].location == NSNotFound) {
                return NO;
            }
            
            if ([b isEqualToNumber:@1] && [s rangeOfString:@"!"].location != NSNotFound) {
                return NO;
            }
            
        }
        
        return YES;
    }
    
    //Or Triggers
    BOOL show = NO;
    NSDictionary *triggers = [pageTriggers copy];
    for (NSString *s in triggers) {
        NSNumber *b = pageTriggers[s];
        if ([b isEqualToNumber:@1] && [s rangeOfString:@"!"].location == NSNotFound) {
            show = YES;
        }
        
        if ([b isEqualToNumber:@0] && [s rangeOfString:@"!"].location != NSNotFound) {
            show = YES;
        }
        
        
    }
    
    return show;
    
}
- (BOOL)fieldIsOnPage:(NSString *)fieldId {
    for (IWFieldDescriptor *fld in self.fieldDescriptors) {
        if ([fld.fieldId isEqualToString:fieldId]) {
            return true;
        }
    }
    for (NSString *key in self.radioGroups) {
        if ([key isEqualToString:fieldId]) {
            return true;
        }
    }
    return false;
}

- (void) nilAll {
    self.fieldDescriptors = nil;
}

@end
