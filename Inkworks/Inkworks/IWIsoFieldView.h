//
//  IWIsoFieldView.h
//  Inkworks
//
//  Created by Jamie Duggan on 16/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IWIsoSubField.h"
@class IWIsoFieldDescriptor;
@class IWDataChangeHandler;

@interface IWIsoFieldView : UIView <UIGestureRecognizerDelegate, UITextFieldDelegate, IWIsoSubFieldDelegate>{
    NSArray *rects;
    NSString *hintLetters;
    UIColor *strokeColor;
    NSMutableArray *boxes;
    IWIsoFieldDescriptor *descriptor;
    id<UITextFieldDelegate> mainDelegate;
    UIColor *textColor;
    BOOL isDecimal;
    UIColor *recFillColor;
    IWIsoSubField *textEntryField;
    
    NSString *previousValue;
    
    BOOL allowsLower;
    BOOL allowsNumber;
    BOOL allowsText;
    
    BOOL mandatory;
}

@property NSArray *rects;
@property NSString *hintLetters;
@property UIColor *strokeColor;
@property BOOL isDecimal;
@property UIColor *recFillColor;
@property IWIsoFieldDescriptor *descriptor;
@property NSMutableArray *boxes;
@property id<UITextFieldDelegate> mainDelegate;
@property BOOL allowsLower;
@property IWIsoSubField *textEntryField;
@property BOOL allowsNumber;
@property BOOL allowsText;
@property NSString *previousValue;
@property UIColor *textColor;
@property (nonatomic) BOOL mandatory;

- (id) initWithFrame:(CGRect)frame descriptor: (IWIsoFieldDescriptor *) desc andRects: (NSArray *)aRects andStrokeColor: (UIColor *) stroke delegate: (id<UITextFieldDelegate>)del;
- (void) fieldTapped: (UITapGestureRecognizer *) gestureRecognizer;
- (NSString *) getValue;
- (void) setValue: (NSString *) value;
- (void) clear;
- (void) setPrepop;
- (void) setMand:(BOOL)mand;
- (void) setCalc;
-(void) showEntry;
-(void) hideKeyboard:(IWIsoSubField *)field;
@end
