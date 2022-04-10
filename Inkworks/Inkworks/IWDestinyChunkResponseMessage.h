//
//  IWDestinyChunkResponseMessage.h
//  Inkworks
//
//  Created by Jamie Duggan on 11/08/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "IWDestFormObject.h"

/*
 public DestinyChunkResponseMessage()
 {
 this.Errorcode = 0;
 this.Message = string.Empty;
 this.nextexpectedchunk = 0;
 this.Restart = false;
 }
 */

@interface IWDestinyChunkResponseMessage : IWDestFormObject {
    NSNumber *Errorcode;
    NSString *Message;
    NSNumber *NextExpectedChunk;
    
    //This is a boolean really...
    NSNumber *Restart;
}

@property NSNumber *Errorcode;
@property NSString *Message;
@property NSNumber *NextExpectedChunk;
@property NSNumber *Restart;

- (id)initWithNamespace:(NSString *)aNameSpace;
- (id)initWithNamespace:(NSString *)aNameSpace andXml: (TBXMLElement *) xml;
- (NSDictionary *) getFields;
- (NSArray *)getFieldOrder;

@end
