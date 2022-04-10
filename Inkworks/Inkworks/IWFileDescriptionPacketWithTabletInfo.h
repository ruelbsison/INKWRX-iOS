//
//  IWFileDescriptionPacketWithTabletInfo.h
//  Inkworks
//
//  Created by Paul Gowing on 21/08/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWDestFormObject.h"

@interface IWFileDescriptionPacketWithTabletInfo : IWDestFormObject {
    NSString *Username;
    NSString *Password;
    NSString *TabletId;
    NSNumber *MaxPacketCount;
    NSNumber *PacketSize;
    NSNumber *Filesize;
    NSString *Filename;
    
}

@property NSString *Username;
@property NSString *Password;
@property NSString *TabletId;
@property NSNumber *MaxPacketCount;
@property NSNumber *PacketSize;
@property NSNumber *Filesize;
@property NSString *Filename;

- (id) initWithNamespace:(NSString *)aNameSpace;
- (NSDictionary *)getFields;
- (NSArray *)getFieldOrder;
@end
