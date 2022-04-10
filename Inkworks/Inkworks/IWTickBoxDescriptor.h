//
//  IWTickBoxDescriptor.h
//  Inkworks
//
//  Created by Jamie Duggan on 16/04/2014.
//  Copyright (c) 2014 Jamie Duggan. All rights reserved.
//

#import "IWTickedFieldDescriptor.h"

#define SMALL 0
#define NORMAL 1
#define LARGE 2

@interface IWTickBoxDescriptor : IWTickedFieldDescriptor{
    int tickBoxSize;
}

@property int tickBoxSize;
+ (id) newWithXml: (GDataXMLElement *) aXml atZOrder:(int)aZOrder;
+ (id) newWithOriginal: (IWTickBoxDescriptor *)original;

@end
