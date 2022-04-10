//
//  IWFilePacketWithTabletInfo.m
//  Inkworks
//
//  Created by Paul Gowing on 21/08/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWFilePacketWithTabletInfo.h"

@implementation IWFilePacketWithTabletInfo
@synthesize Username, Password, TabletId, PacketIndex, FilePacketdata;

-(id)initWithNamespace:(NSString *)aNameSpace {
    
    self=[super initWithNamespace:aNameSpace];
    if(self) {
        
        self.name = @"FilePacketWithTabletInfo";
    }
    
    return self;
}

- (NSArray *)getFieldOrder {
    return @[@"Username", @"Password", @"TabletId", @"PacketIndex", @"FilePacketdata"];
}

-(NSDictionary *)getFields {
    NSMutableDictionary *fields = [NSMutableDictionary dictionary];
    [fields setObject:Username forKey:@"Username"];
    [fields setObject:Password forKey:@"Password"];
    [fields setObject:TabletId forKey:@"TabletId"];
    [fields setObject:PacketIndex forKey:@"PacketIndex"];
    [fields setObject:FilePacketdata forKey:@"FilePacketdata"];
    
    return [NSDictionary dictionaryWithDictionary:fields];
}

@end
