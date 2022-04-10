//
//  IWFileDescriptionWithTabletInfo.m
//  Inkworks
//
//  Created by Jamie Duggan on 20/08/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWFileDescriptionWithTabletInfo.h"

@implementation IWFileDescriptionWithTabletInfo
@synthesize UserName, PassWord, TabletId, Filename, Filedata;

-(id)initWithNamespace:(NSString *)aNameSpace {
    
    self=[super initWithNamespace:aNameSpace];
    if(self) {
        
        self.name = @"FileDescriptionWithTabletInfo";
    }
    
    return self;
}

- (NSArray *)getFieldOrder {
    return @[@"UserName", @"PassWord", @"TabletId", @"Filename", @"Filedata"];
}

-(NSDictionary *)getFields {
    NSMutableDictionary *fields = [NSMutableDictionary dictionary];
    [fields setObject:UserName forKey:@"UserName"];
    [fields setObject:PassWord forKey:@"PassWord"];
    [fields setObject:TabletId forKey:@"TabletId"];
    [fields setObject:Filename forKey:@"Filename"];
    [fields setObject:Filedata forKey:@"Filedata"];
    
    return [NSDictionary dictionaryWithDictionary:fields];
    
    
}
@end
