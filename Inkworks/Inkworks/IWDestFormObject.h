//
//  IWDestFormObject.h
//  Inkworks
//
//  Created by Jamie Duggan on 11/08/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"

@interface IWDestFormObject : NSObject {
    NSString *name;
    NSString *nameSpace;
}

@property NSString *name;
@property NSString *nameSpace;

-(id) initWithNamespace: (NSString *) aNameSpace;
- (id)initWithNamespace:(NSString *)aNameSpace andXml: (TBXMLElement *) xml;

- (NSDictionary *) getFields;
- (NSString *) getXml;
- (NSArray *) getFieldOrder;
@end
