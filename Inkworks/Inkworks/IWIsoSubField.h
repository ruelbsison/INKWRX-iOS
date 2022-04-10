//
//  IWIsoSubField.h
//  Inkworks
//
//  Created by Jamie Duggan on 19/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol IWIsoSubFieldDelegate <NSObject>

@optional
- (void)textFieldDidDelete: (UITextField *) field;

@end


@interface IWIsoSubField : UITextField <UIKeyInput> {
    BOOL isDecimalRightBox;
    
}

@property (nonatomic, assign) id<IWIsoSubFieldDelegate> myDelegate;
@property BOOL isDecimalRightBox;


@end