//
//  IWRadioButtonDescriptor.h
//  Inkworks
//
//  Created by Jamie Duggan on 16/04/2014.
//  Copyright (c) 2014 Jamie Duggan. All rights reserved.
//


#import "IWTickedFieldDescriptor.h"

@interface IWRadioButtonDescriptor : IWTickedFieldDescriptor {
    
}


+ (id) newWithXml: (GDataXMLElement *) aXml atZOrder:(int)aZOrder;
+ (id) newWithOriginal: (IWRadioButtonDescriptor *) original;

@end
