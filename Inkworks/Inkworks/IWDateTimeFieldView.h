//
//  IWDateTimeFieldView.h
//  Inkworks
//
//  Created by Jamie Duggan on 20/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWIsoFieldView.h"

@interface IWDateTimeFieldView : IWIsoFieldView <UIPopoverControllerDelegate, UIPickerViewDelegate> {
    NSString *listArray;
    NSArray *textLabels;
    
    NSDate *dateTimeValue;
    
    NSString *day, *month, *year;
    NSString *hh, *mm;
    NSArray *hintArray;
    UIPopoverController *popController;
    UIDatePicker *datePicker;
    
}

@property NSString *listArray;
@property NSArray *textLabels;
@property NSDate *dateTimeValue;

@property NSString *day, *month, *year;
@property NSString *hh, *mm;
@property NSArray *hintArray;

@property (strong) UIDatePicker *datePicker;

@property UIPopoverController *popController;


- (id) initWithFrame:(CGRect)frame descriptor: (IWIsoFieldDescriptor *) desc andRects:(NSArray *)aRects andStrokeColor:(UIColor *)stroke andTextLabels: (NSArray *) labels delegate:(id<UITextFieldDelegate>)del;

- (void) setDateWithYear: (int) yy Month: (int) mon Day: (int) dd;
- (void) setTimeWithHour: (int) hour Minute: (int) minute;
- (void) fieldTapped: (UITapGestureRecognizer *) gestureRecognizer;

@end
