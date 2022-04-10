//
//  IWDestinyResponse.m
//  Inkworks
//
//  Created by Jamie Duggan on 11/08/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWDestinyResponse.h"

@implementation IWDestinyResponse

@synthesize Errorcode, GeneralResponse, ParamVersion, RouterConfigVersion, Date, Data;

- (id) initWithNamespace:(NSString *)aNameSpace {
    self = [super initWithNamespace:aNameSpace];
    if (self) {
        self.name = @"DestinyResponseMessage";
        self.Errorcode = @(-1);
        self.GeneralResponse = @"";
        self.ParamVersion = @(-1);
        self.RouterConfigVersion = @"";
        self.Date = @"";
        self.Data = @"";
    }
    return self;
}

- (id)initWithNamespace:(NSString *)aNameSpace andXml:(TBXMLElement *)xml {
    self = [self initWithNamespace:aNameSpace];
    if (self) {
        TBXMLElement *destChild = xml->firstChild;
        while (destChild) {
            NSString *elemname = [TBXML elementName:destChild];
            NSString *val = @"";
            if (destChild -> text != NULL)
                val = [NSString stringWithUTF8String:destChild->text];
            
            if ([elemname isEqualToString:@"Errorcode"]) {
                if (![val isEqualToString:@""]) {
                    self.Errorcode = [NSNumber numberWithInt: [val intValue]];
                }
            } else if ([elemname isEqualToString:@"GeneralResponse"]) {
                self.GeneralResponse = val;
            } else if ([elemname isEqualToString:@"ParamVersion"]) {
                if (![val isEqualToString:@""]) {
                    self.ParamVersion = [NSNumber numberWithInt:[val intValue]];
                }
            } else if ([elemname isEqualToString:@"RouterConfigVersion"]) {
                self.RouterConfigVersion = val;
            } else if ([elemname isEqualToString:@"Date"]) {
                self.Date = val;
            } else if ([elemname isEqualToString:@"Data"]) {
                self.Data = val;
            }
            
            destChild = destChild -> nextSibling;
        }
    }
    return self;
}

- (NSArray *)getFieldOrder {
    return @[@"Errorcode", @"GeneralResponse", @"ParamVersion", @"RouterConfigVersion"];
}

- (NSDictionary *) getFields {
    NSMutableDictionary *fields = [NSMutableDictionary dictionary];
    
    [fields setObject:Errorcode forKey:@"Errorcode"];
    [fields setObject:GeneralResponse forKey:@"GeneralResponse"];
    [fields setObject:ParamVersion forKey:@"ParamVersion"];
    [fields setObject:RouterConfigVersion forKey:@"RouterConfigVersion"];
    
    return fields;
}

@end
