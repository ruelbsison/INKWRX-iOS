//
//  IWJsonForm.h
//  Inkworks
//
//  Created by Jamie Duggan on 15/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IWJsonForm : NSObject {
    NSString *name;
    NSNumber *formId;
    NSDate *amended;
}

@property NSString *name;
@property NSNumber *formId;
@property NSDate *amended;

- (id) initWithName: (NSString *) formName andFormId: (NSNumber *)aId andAmended: (NSDate *) date;

@end
