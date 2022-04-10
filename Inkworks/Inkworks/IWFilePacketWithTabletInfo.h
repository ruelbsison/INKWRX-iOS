//
//  IWFilePacketWithTabletInfo.h
//  Inkworks
//
//  Created by Paul Gowing on 21/08/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWDestFormObject.h"

@interface IWFilePacketWithTabletInfo : IWDestFormObject {
    NSString *Username;
    NSString *Password;
    NSString *TabletId;
    NSNumber *PacketIndex;
    NSString *FilePacketdata;
    
}

@property NSString *Username;
@property NSString *Password;
@property NSString *TabletId;
@property NSNumber *PacketIndex;
@property NSString *FilePacketdata;

- (id) initWithNamespace:(NSString *)aNameSpace;
- (NSDictionary *)getFields;
- (NSArray *)getFieldOrder;

@end
