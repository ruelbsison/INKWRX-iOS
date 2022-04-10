//
//  IWDropdownView.h
//  Inkworks
//
//  Created by Jamie Duggan on 16/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IWDropdownView : UIPickerView <UIPickerViewDataSource, UIPickerViewDelegate> {
    NSArray *items;
}

@property NSArray *items;

@end
