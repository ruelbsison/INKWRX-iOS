//
//  IWEformXmlSaveInfo.h
//  Inkworks
//
//  Created by Paul Gowing on 21/08/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWDestFormObject.h"

@interface IWEformXmlSaveInfo : IWDestFormObject {
    NSString *Username;
    NSString *Password;
    NSString *TabletId;
    NSNumber *ApplicationKey;
    NSString *XmlData;
    NSString *PenData;
    NSString *TransactionXml;
    
        
    
}


@property NSString *Username;
@property NSString *Password;
@property NSString *TabletId;
@property NSNumber *ApplicationKey;
@property NSString *XmlData;
@property NSString *PenData;
@property NSString *TransactionXml;

- (id) initWithNamespace:(NSString *)aNameSpace;
- (NSDictionary *)getFields;
- (NSArray *)getFieldOrder;
- (NSString *)getXml;

@end
