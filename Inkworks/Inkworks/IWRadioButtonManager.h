//
//  IWRadioButtonManager.h
//  Inkworks
//
//  Created by Jamie Duggan on 19/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IWRadioButton.h"

@interface IWRadioButtonManager : NSObject <UIGestureRecognizerDelegate, IWRadioButtonDelegate>{
    NSMutableDictionary *radios;
}

@property NSMutableDictionary *radios;

- (void) buttonClicked: (IWRadioButton *) button;
- (void) addButton: (IWRadioButton *) button withId: (NSString *) fieldId;
- (BOOL) hasValue;
@end
