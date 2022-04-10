//
//  IWFileDescriptionWithTabletInfo.h
//  Inkworks
//
//  Created by Jamie Duggan on 20/08/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWDestFormObject.h"

@interface IWFileDescriptionWithTabletInfo : IWDestFormObject {
    
    NSString *UserName;
    NSString *PassWord;
    NSString *TabletId;
    NSString *Filename;
    NSString *Filedata;
    
}

@property NSString *UserName;
@property NSString *PassWord;
@property NSString *TabletId;
@property NSString *Filename;
@property NSString *Filedata;

- (id) initWithNamespace:(NSString *)aNameSpace;
- (NSDictionary *)getFields;
- (NSArray *)getFieldOrder;

@end
