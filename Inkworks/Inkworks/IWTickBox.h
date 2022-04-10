//
//  IWTickBox.h
//  Inkworks
//
//  Created by Jamie Duggan on 19/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IWTickBoxDescriptor.h"

@interface IWTickBox : UIButton <UIGestureRecognizerDelegate>{
    UIColor *strokeColor;
    BOOL isTicked;
    
    IWTickBoxDescriptor *descriptor;
}

@property UIColor *strokeColor;
@property BOOL isTicked;
@property IWTickBoxDescriptor *descriptor;

- (void) toggle;
- (void) toggleOnOnly;
- (id) initWithFrame:(CGRect)frame andStrokeColor: (UIColor *) stroke descriptor: (IWTickBoxDescriptor *) desc;

@end
