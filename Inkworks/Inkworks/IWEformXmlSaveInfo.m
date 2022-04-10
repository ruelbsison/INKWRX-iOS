//
//  IWEformXmlSaveInfo.m
//  Inkworks
//
//  Created by Paul Gowing on 21/08/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWEformXmlSaveInfo.h"

@implementation IWEformXmlSaveInfo
@synthesize Username, Password, TabletId, ApplicationKey, XmlData, PenData, TransactionXml;

-(id)initWithNamespace:(NSString *)aNameSpace {
    
    self=[super initWithNamespace:aNameSpace];
    if(self) {
        
        self.name = @"EformXmlSaveInfo";
    }
    
    return self;
}

- (NSArray *)getFieldOrder {
    return @[@"Username", @"Password",@"TabletId", @"ApplicationKey", @"XmlData", @"PenData", @"TransactionXml"];
}

-(NSDictionary *)getFields {
    NSMutableDictionary *fields = [NSMutableDictionary dictionary];
    [fields setObject:Username forKey:@"Username"];
    [fields setObject:Password forKey:@"Password"];
    [fields setObject:TabletId forKey:@"TabletId"];
    [fields setObject:ApplicationKey forKey:@"ApplicationKey"];
    [fields setObject:XmlData forKey:@"XmlData"];
    [fields setObject:PenData forKey:@"PenData"];
    [fields setObject:TransactionXml forKey:@"TransactionXml"];
    
    return [NSDictionary dictionaryWithDictionary:fields];
}

- (NSString *)getXml {
    NSDictionary *fields = [self getFields];
    NSArray *fieldOrder = [self getFieldOrder];
    
    NSMutableString *xml = [NSMutableString string];
    [xml appendString:[NSString stringWithFormat:@"        <n2:%@ xmlns:n2=\"%@\">\n", name, nameSpace]];
    for (NSString *key in fieldOrder) {
        if ([key isEqualToString:@"XmlData"] || [key isEqualToString:@"PenData"] || [key isEqualToString:@"TransactionXml"]){
            NSString *line = [NSString stringWithFormat:@"            <n2:%@><![CDATA[%@]]></n2:%@>\n", key, [fields objectForKey:key ], key];
            [xml appendString:line];
        } else {
            NSString *line = [NSString stringWithFormat:@"            <n2:%@>%@</n2:%@>\n", key, [fields objectForKey:key ], key];
            [xml appendString:line];
        }
    }
    [xml appendString:[NSString stringWithFormat:  @"        </n2:%@>\n", name]];
    
    return xml;
    
}

@end


