//
//  IWRadioButton.h
//  Inkworks
//
//  Created by Jamie Duggan on 19/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IWRadioButtonDescriptor.h"

@protocol IWRadioButtonDelegate <NSObject>

- (void) buttonClicked: (UIButton *) button;

@end

@interface IWRadioButton : UIButton <UIGestureRecognizerDelegate> {
    BOOL isTicked;
    UIColor *strokeColor;
    UIView *selector;
    
    id <IWRadioButtonDelegate> myDelegate;
    
    IWRadioButtonDescriptor *descriptor;
}

@property BOOL isTicked;
@property (strong) UIColor *strokeColor;
@property (strong, retain) UIView  *selector;
@property (retain) id<IWRadioButtonDelegate> myDelegate;

@property IWRadioButtonDescriptor *descriptor;
- (id) initWithFrame:(CGRect)frame andStrokeColor: (UIColor *) stroke descriptor: (IWRadioButtonDescriptor *)desc;

@end
