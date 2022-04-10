//
//  IWDropDown.h
//  Inkworks
//
//  Created by Jamie Duggan on 19/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IWDropdownDescriptor.h"

@interface IWDropDown : UIView <UIGestureRecognizerDelegate, UIPopoverControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    NSArray *lexicon;
    NSMutableDictionary *values;
    UIColor *strokeColor;
    NSString *selectedValue;
    UIPopoverController *popController;
    UILabel *selLabel;
    UITextField *selText;
    NSMutableArray *shortLexicon;
    UITableView *table;
    
    IWDropdownDescriptor *descriptor;
}

@property NSArray *lexicon;
@property NSMutableDictionary *values;
@property UIColor *strokeColor;
@property NSString *selectedValue;
@property UIPopoverController *popController;
@property UILabel *selLabel;
@property IWDropdownDescriptor *descriptor;
@property UITextField *selText;
@property NSMutableArray *shortLexicon;
@property UITableView *table;

- (id) initWithFrame:(CGRect)frame andLexicon: (NSArray *) lex andStrokeColor: (UIColor *) stroke descriptor: (IWDropdownDescriptor *)desc;

- (NSString *)getVal;

@end
