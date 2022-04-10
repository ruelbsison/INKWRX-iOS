//
//  IWDestinyResponse.h
//  Inkworks
//
//  Created by Jamie Duggan on 11/08/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWDestFormObject.h"

@interface IWDestinyResponse : IWDestFormObject {
    NSNumber *Errorcode;
    NSString *GeneralResponse;
    NSNumber *ParamVersion;
    NSString *RouterConfigVersion;
    NSString *Date;
    NSString *Data;
}

@property NSNumber *Errorcode;
@property NSString *GeneralResponse;
@property NSNumber *ParamVersion;
@property NSString *RouterConfigVersion;
@property NSString *Date;
@property NSString *Data;

- (id) initWithNamespace:(NSString *)aNameSpace;
- (id) initWithNamespace:(NSString *)aNameSpace andXml:(TBXMLElement *)xml;
- (NSDictionary *)getFields;
- (NSArray *)getFieldOrder;
@end
