//
//  IWFieldDescriptor.h
//  Inkworks
//
//  Created by Jamie Duggan on 14/04/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//


#define ISO_FIELD @"iso"
#define DROP_DOWNN @"dropdown"
#define TICK_BOX @"tickBox"
#define RADIO @"radioList"
#define NOTES @"cursiveNotes"
#define NOTES2 @"cursiveStandard"
#define SIGNATURE_FIELD @"cursiveSignature"
#define SKETCHBOX @"cursiveSketchBox"


#import <Foundation/Foundation.h>
#import "IWElementDescriptor.h"

@interface IWFieldDescriptor : IWElementDescriptor {
    NSString *fdtType;
    BOOL mandatory;
    
}

@property (nonatomic) NSString *fdtType;
@property BOOL mandatory;

- (id) initWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder;
- (id) initWithOriginal:(IWFieldDescriptor *)original;
@end
