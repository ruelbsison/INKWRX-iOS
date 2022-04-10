//
//  IWGPSUnit.h
//  Inkworks
//
//  Created by Jamie Duggan on 28/08/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IWGPSUnit : NSObject {
    NSNumber *longitude;
    NSNumber *latitude;
    NSNumber *altitude;
    NSDate *dateStamp;
    NSString *accuracy;
}

@property NSNumber *longitude;
@property NSNumber *latitude;
@property NSNumber *altitude;
@property NSDate *dateStamp;
@property NSString *accuracy;

@end
