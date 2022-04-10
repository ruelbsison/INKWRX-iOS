//
//  IWFileDescriptionPacketWithTabletInfo.m
//  Inkworks
//
//  Created by Paul Gowing on 21/08/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWFileDescriptionPacketWithTabletInfo.h"

@implementation IWFileDescriptionPacketWithTabletInfo
@synthesize Username, Password, TabletId, MaxPacketCount, PacketSize, Filesize, Filename;


-(id)initWithNamespace:(NSString *)aNameSpace {

self=[super initWithNamespace:aNameSpace];
if(self) {
    
    self.name = @"FileDescriptionPacketWithTabletInfo";
}

return self;



}

-(NSArray *)getFieldOrder {
    NSArray *array = @[@"Username", @"Password", @"TabletId", @"MaxPacketCount", @"PacketSize", @"Filesize", @"Filename"];
    return array;
}


-(NSDictionary *)getFields {
    NSMutableDictionary *fields = [NSMutableDictionary dictionary];
    [fields setObject:Username forKey:@"Username"];
    [fields setObject:Password forKey:@"Password"];
    [fields setObject:TabletId forKey:@"TabletId"];
    [fields setObject:MaxPacketCount forKey:@"MaxPacketCount"];
    [fields setObject:PacketSize forKey:@"PacketSize"];
    [fields setObject:Filesize forKey:@"Filesize"];
    [fields setObject:Filename forKey:@"Filename"];
    
    return [NSDictionary dictionaryWithDictionary:fields];
}

@end

