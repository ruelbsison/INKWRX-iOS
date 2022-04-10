//
//  IWNoteFieldDescriptor.h
//  Inkworks
//
//  Created by Jamie Duggan on 16/04/2014.
//  Copyright (c) 2014 Jamie Duggan. All rights reserved.
//

#import "IWFieldDescriptor.h"

@interface IWNoteFieldDescriptor : IWFieldDescriptor {
    int limitPerLine;
    NSMutableArray *rectElements;
    BOOL isGraphical;
    BOOL isBarcode;
}

@property (nonatomic) int limitPerLine;
@property (nonatomic) NSMutableArray *rectElements;
@property (nonatomic) BOOL isGraphical;
@property (nonatomic) BOOL isBarcode;

+ (id) newWithXml: (GDataXMLElement *)aXml atZOrder: (int) aZOrder;
+ (id) newWithOriginal: (IWNoteFieldDescriptor *) original;

- (NSString *) repeatingFieldId;
@end
