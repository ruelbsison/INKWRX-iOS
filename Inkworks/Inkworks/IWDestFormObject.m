//
//  IWDestFormObject.m
//  Inkworks
//
//  Created by Jamie Duggan on 11/08/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWDestFormObject.h"

@implementation IWDestFormObject

@synthesize name, nameSpace;

-(NSDictionary *)getFields {
    NSDictionary *ret = [NSDictionary dictionary];
    
    return ret;
}

- (id)initWithNamespace:(NSString *)aNameSpace {
    self = [super init];
    if (self) {
        self.nameSpace = aNameSpace;
    }
    return self;
}

- (id)initWithNamespace:(NSString *)aNameSpace andXml:(TBXMLElement *)xml {
    self = [self initWithNamespace:aNameSpace];
    if (self) {
        
        
    }
    
    return self;
}

- (NSString *)getXml {
    NSDictionary *fields = [self getFields];
    NSArray *fieldOrder = [self getFieldOrder];
    
    NSMutableString *xml = [NSMutableString string];
    [xml appendString:[NSString stringWithFormat:@"        <n2:%@ xmlns:n2=\"%@\">\n", name, nameSpace]];
    for (NSString *key in fieldOrder) {
        NSString *line = [NSString stringWithFormat:@"            <n2:%@>%@</n2:%@>\n", key, [fields objectForKey:key ], key];
        [xml appendString:line];
    }
    [xml appendString:[NSString stringWithFormat:  @"        </n2:%@>\n", name]];
    
    return xml;
    
}

- (NSArray *)getFieldOrder {
    NSArray *array = [NSArray array];
    return array;
}

@end
