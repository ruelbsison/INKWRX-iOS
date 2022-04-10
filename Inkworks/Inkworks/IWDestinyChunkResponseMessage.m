//
//  IWDestinyChunkResponseMessage.m
//  Inkworks
//
//  Created by Jamie Duggan on 11/08/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWDestinyChunkResponseMessage.h"

@implementation IWDestinyChunkResponseMessage

@synthesize Errorcode, Message, NextExpectedChunk, Restart;

- (id)initWithNamespace:(NSString *)aNameSpace {
    self = [super initWithNamespace:aNameSpace];
    if (self) {
        self.name = @"DestinyChunkResponseMessage";
    }
    return self;
    
}

- (id)initWithNamespace:(NSString *)aNameSpace andXml:(TBXMLElement *)xml {
    self = [self initWithNamespace:aNameSpace];
    if (self) {
        
        TBXMLElement *destChild = xml->firstChild;
        while (destChild) {
            NSString *elemname = [TBXML elementName:destChild];
            NSString *val = [NSString stringWithUTF8String:destChild->text];
            
            if ([elemname isEqualToString:@"Errorcode"]) {
                if (![val isEqualToString:@""]) {
                    self.Errorcode = [NSNumber numberWithInt: [val intValue]];
                }
            } else if ([elemname isEqualToString:@"Message"]) {
                self.Message = val;
            } else if ([elemname isEqualToString:@"Restart"]) {
                self.Restart = [val isEqualToString:@"true"] ? @1 : @0;
            } else if ([elemname isEqualToString:@"NextExpectedPacketId"]) {
                if (![val isEqualToString:@""]) {
                    self.NextExpectedChunk = [NSNumber numberWithInt:[val intValue]];
                }
            }
            destChild = destChild -> nextSibling;
        }
    }
    return self;
}

- (NSArray *)getFieldOrder {
    NSArray *array = @[@"Errorcode", @"Message", @"NextExpectedPacketId", @"Restart"];
    return array;
}

- (NSDictionary *)getFields {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    
    [ret setObject:Errorcode forKey:@"Errorcode"];
    [ret setObject:Message forKey:@"Message"];
    [ret setObject:NextExpectedChunk forKey:@"NextExpectedPacketId"];
    [ret setObject:Restart forKey:@"Restart"];
    
    return [NSDictionary dictionaryWithDictionary:ret];
}

@end
