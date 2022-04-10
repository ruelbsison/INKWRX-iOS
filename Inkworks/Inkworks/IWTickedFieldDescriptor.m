//
//  IWTickedFieldDescriptor.m
//  Inkworks
//
//  Created by Jamie Duggan on 16/04/2014.
//  Copyright (c) 2014 Jamie Duggan. All rights reserved.
//

#import "IWTickedFieldDescriptor.h"
#import "GDataXMLNode.h"

@implementation IWTickedFieldDescriptor

@synthesize tickedValue;
@synthesize notTickedValue;
@synthesize groupName;
@synthesize rectElement;

- (id) initWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder{
    self = [super initWithXml:aXml atZOrder:aZOrder];
    
    tickedValue = @"";
    notTickedValue = @"";
    for (GDataXMLNode *att in source.attributes) {
    //TBXMLAttribute *att = source->firstAttribute;
    //while (att) {
        NSString *attName = att.name;
        if ([attName isEqualToString:TICKED]){
            tickedValue = att.stringValue;
        } else if ([attName isEqualToString:NOT_TICKED]){
            notTickedValue = att.stringValue;
        } else if ([attName isEqualToString:GROUP]){
            groupName = att.stringValue;
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
    
    x = rectElement.x;
    y = rectElement.y;
    width = rectElement.width;
    height = rectElement.height;
    self.strokeColor = rectElement.strokeColor;
    
    return self;
}

- (NSString *)repeatingGroupName {
    return repeatingIndex == -1? groupName : [NSString stringWithFormat:@"%@_%d", groupName, repeatingIndex];
}

- (id)initWithOriginal:(IWTickedFieldDescriptor *)original {
    self = [super initWithOriginal:original];
    if (self) {
        self.tickedValue = original.tickedValue;
        self.notTickedValue = original.notTickedValue;
        self.groupName = original.groupName;
        self.rectElement = original.rectElement;
    }
    return self;
}

@end
