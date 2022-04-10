//
//  IWTickedFieldDescriptor.h
//  Inkworks
//
//  Created by Jamie Duggan on 16/04/2014.
//  Copyright (c) 2014 Jamie Duggan. All rights reserved.
//

#define RECT @"rect"

#define TICKED @"fdtTicked"
#define NOT_TICKED @"fdtNotTicked"

#define GROUP @"fdtGroupName"


#import "IWFieldDescriptor.h"
#import "IWRectElement.h"

@interface IWTickedFieldDescriptor : IWFieldDescriptor {
    NSString *tickedValue;
    NSString *notTickedValue;
    
    NSString *groupName;
    
    IWRectElement *rectElement;
}

@property (nonatomic) NSString *tickedValue;
@property (nonatomic) NSString *notTickedValue;
@property (nonatomic) NSString *groupName;
@property (nonatomic) IWRectElement *rectElement;

- (id) initWithXml:(GDataXMLElement *)aXml atZOrder:(int)aZOrder;
- (id) initWithOriginal:(IWTickedFieldDescriptor *)original;
- (NSString *) repeatingGroupName;
@end
