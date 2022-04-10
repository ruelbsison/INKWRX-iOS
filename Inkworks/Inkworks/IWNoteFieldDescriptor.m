//
//  IWNoteFieldDescriptor.m
//  Inkworks
//
//  Created by Jamie Duggan on 16/04/2014.
//  Copyright (c) 2014 Jamie Duggan. All rights reserved.
//

#import "IWNoteFieldDescriptor.h"
#import "IWRectElement.h"
#import "GDataXMLNode.h"

@implementation IWNoteFieldDescriptor

@synthesize limitPerLine;
@synthesize rectElements, isGraphical, isBarcode;

- (id) initWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder{
    self = [super initWithXml:aXml atZOrder:aZOrder];
    
    rectElements = [NSMutableArray array];
    isGraphical = false;
    for (GDataXMLElement *child in source.children) {
    //TBXMLElement *child = source->firstChild;
    //while (child){
        
        NSString *elementName = child.name;
        if ([elementName isEqualToString:@"rect"]){
            [rectElements addObject:[IWRectElement newWithXml:child]];
            
        }
        
        //child = child->nextSibling;
    }
    
    for (GDataXMLNode *att in source.attributes) {
    //TBXMLAttribute *att = source->firstAttribute;
    //while (att) {
        NSString *elementName = att.name;
        if ([elementName isEqualToString:@"fdtTypeFormat"]) {
            NSString *val = att.stringValue;
            if ([val isEqualToString:@"Graphical"]) {
                isGraphical = true;
            }
        }
        if ([elementName isEqualToString:@"fdtBarcodeField"]) {
            NSString *val = att.stringValue;
            if ([val isEqualToString:@"true"]) {
                isBarcode = true;
            }
        }
        //att = att->next;
    }
    
    IWRectElement *firstRect = [rectElements firstObject];
    IWRectElement *lastRect = [rectElements lastObject];
    self.strokeColor = firstRect.strokeColor;
    x = firstRect.x;
    y = firstRect.y;
    width = firstRect.width;
    height = lastRect.y + lastRect.height - firstRect.y;
    
    
    
    return self;
}

- (id) initWithOriginal:(IWNoteFieldDescriptor *)original {
    self = [super initWithOriginal:original];
    if (self) {
        self.rectElements = original.rectElements;
        self.limitPerLine = original.limitPerLine;
        self.isGraphical = original.isGraphical;
        self.isBarcode = original.isBarcode;
    }
    return self;
}

+ (id) newWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder{
    return [[IWNoteFieldDescriptor alloc] initWithXml:aXml atZOrder:aZOrder];
}

+ (id)newWithOriginal:(IWNoteFieldDescriptor *)original {
    return [[IWNoteFieldDescriptor alloc] initWithOriginal:original];
}

- (NSString *)repeatingFieldId {
    NSString *index =repeatingIndex == -1 ? fieldId : [NSString stringWithFormat:@"%@_%u", fieldId, repeatingIndex];
    return index;
}

@end
