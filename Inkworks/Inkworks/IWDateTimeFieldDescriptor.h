//
//  IWDateTimeFieldDescriptor.h
//  Inkworks
//
//  Created by Jamie Duggan on 16/04/2014.
//  Copyright (c) 2014 Jamie Duggan. All rights reserved.
//

#define FDT_DELIMITER @"fdtDefDelimiter"

#import "IWIsoFieldDescriptor.h"



@interface IWDateTimeFieldDescriptor : IWIsoFieldDescriptor {
    NSString *fdtDelimiter;
    
}

@property NSString *fdtDelimiter;


+ (id) newWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder;
+ (id) newWithOriginal:(IWDateTimeFieldDescriptor *)original;

@end
