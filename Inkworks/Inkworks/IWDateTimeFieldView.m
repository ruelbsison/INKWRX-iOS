//
//  IWDateTimeFieldView.m
//  Inkworks
//
//  Created by Jamie Duggan on 20/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWDateTimeFieldView.h"
#import "IWDateTimeFieldDescriptor.h"
#import "IWFormRenderer.h"
#import "IWInkworksService.h"
#import "IWDataChangeHandler.h"
#import "Inkworks-Swift.h"

@implementation IWDateTimeFieldView

@synthesize textLabels, listArray, dateTimeValue;

@synthesize year, month, day;
@synthesize hh, mm;

@synthesize datePicker;

@synthesize popController, hintArray;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame descriptor:(IWIsoFieldDescriptor *)desc andRects:(NSArray *)aRects andStrokeColor:(UIColor *)stroke andTextLabels:(NSArray *)labels delegate:(id<UITextFieldDelegate>)del {
    self = [super initWithFrame:frame descriptor:desc andRects:aRects andStrokeColor:stroke delegate:del];
    if (self) {
        
        self.textLabels = labels;
        IWDateTimeFieldDescriptor *desc = (IWDateTimeFieldDescriptor *)self.descriptor;
        NSString *hintChars = desc.hintChars;
        hintArray = [hintChars componentsSeparatedByString:@","];
        
//        for (IWISOLabel *s in self.boxes){
//            //[s setEnabled:NO];
//            int index = [self.boxes indexOfObject:s];
//            NSString *hintAtI = [hintArray objectAtIndex:index];
//            [s setPlaceholder:hintAtI];
//            //[s setDelegate:self];
//        }
        UITapGestureRecognizer *tapBox = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDateBox)];
        [self addGestureRecognizer:tapBox];
        
        for (UILabel *l in self.textLabels) {
            [self addSubview:l];
        }
        
        [self clearFields];
        
         datePicker = [[UIDatePicker alloc] init];
        [datePicker setDatePickerMode:UIDatePickerModeDate];
        
        
        if (descriptor.lexiconId == 15){
            [datePicker setDatePickerMode:UIDatePickerModeTime];
        }
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, datePicker.frame.size.width, 108 + 44)];
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 44)];
        [toolbar setBarStyle:UIBarStyleBlack];
        UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)];
        UIBarButtonItem *clear = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearPressed)];
        UIBarButtonItem *today = [[UIBarButtonItem alloc] initWithTitle:@"Now" style:UIBarButtonItemStylePlain target:self action:@selector(todayPressed)];
        UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSArray *items = [NSArray arrayWithObjects: flexibleItem, clear, today, done, nil];
        toolbar.items = items;
        
        //NSLog(@"%fu", datePicker.frame.size.height);
        
        
        datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y + 44, 0, 0)];
        [datePicker setDatePickerMode:UIDatePickerModeDate];
        [datePicker addTarget:self action:@selector(dateTimeChanged:) forControlEvents:UIControlEventValueChanged];
        
        if (descriptor.lexiconId == 15){
            [datePicker setDatePickerMode:UIDatePickerModeTime];
        }
        [view addSubview:toolbar];
        [view addSubview:datePicker];
        UIViewController *vc = [[UIViewController alloc] init];
        vc.view = view;
        [vc.view setFrame:CGRectMake(0, 0, 320, 216 + 44)];
        popController = [[UIPopoverController alloc] initWithContentViewController:vc];
        [popController setPopoverContentSize:view.frame.size];
        [self setNeedsDisplay];
        
    }
    return self;
}


- (void) showDateBox {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [popController presentPopoverFromRect:self.frame inView:self.superview permittedArrowDirections:UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown animated:YES];
    });
}

- (void) donePressed{
    [popController dismissPopoverAnimated:YES];
}

- (void) clearPressed {
    [self setValueWithArray:nil];
    [IWDataChangeHandler getInstance].dataChanged = YES;
}

- (void) todayPressed {
    [IWDataChangeHandler getInstance].dataChanged = YES;
    [datePicker setDate:[NSDate date] animated:YES];
    datePicker.date = [NSDate date];
    self.dateTimeValue = [NSDate date];
    
    NSDate *date = datePicker.date;
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    if (descriptor.lexiconId == 15) {
        //time
        NSDateComponents *timeComponents = [cal components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:date];
        [self setTimeWithHour:timeComponents.hour Minute:timeComponents.minute];
    } else {
        //date...
        NSDateComponents *dateComponents = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
        [self setDateWithYear:dateComponents.year Month:dateComponents.month Day:dateComponents.day];
    }
    
}

- (void) dateTimeChanged: (UIDatePicker *) picker {
    [IWDataChangeHandler getInstance].dataChanged = YES;
    NSDate *date = picker.date;
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    if (descriptor.lexiconId == 15) {
        //time
        NSDateComponents *timeComponents = [cal components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:date];
        [self setTimeWithHour:timeComponents.hour Minute:timeComponents.minute];
    } else {
        //date...
        NSDateComponents *dateComponents = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
        [self setDateWithYear:dateComponents.year Month:dateComponents.month Day:dateComponents.day];
    }
    
    self.dateTimeValue = date;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [popController presentPopoverFromRect:self.frame inView:self.superview permittedArrowDirections:UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown animated:YES];
    });
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (NSString *)getValue {
    IWDateTimeFieldDescriptor *desc = (IWDateTimeFieldDescriptor *)descriptor;
    NSString *delimiter = desc.fdtDelimiter;
    if (!delimiter){
        delimiter = @"";
    }
    NSString *blankDate;
    switch (desc.lexiconId) {
        case 13:
        case 14:
        case 20:
        case 21:
        case 22:
        case 23:
            //Date
            
            blankDate = [[[[[[[[desc.fdtFormat stringByReplacingOccurrencesOfString:@"Numerical - " withString:@""] stringByReplacingOccurrencesOfString:@"YM" withString:[NSString stringWithFormat:@"Y%@M",delimiter]] stringByReplacingOccurrencesOfString:@"MD" withString:[NSString stringWithFormat:@"M%@D", delimiter]] stringByReplacingOccurrencesOfString:@"DM" withString:[NSString stringWithFormat:@"D%@M", delimiter]] stringByReplacingOccurrencesOfString:@"MY" withString:[NSString stringWithFormat:@"M%@Y", delimiter]] stringByReplacingOccurrencesOfString:@"DY" withString:[NSString stringWithFormat:@"D%@Y", delimiter]] stringByReplacingOccurrencesOfString:@"YD" withString:[NSString stringWithFormat:@"Y%@D", delimiter]] stringByReplacingOccurrencesOfString:@"YYYY" withString:@"YY"];
            
            blankDate = [[[blankDate stringByReplacingOccurrencesOfString:@"YY" withString:year] stringByReplacingOccurrencesOfString:@"MM" withString:month] stringByReplacingOccurrencesOfString:@"DD" withString:day];
            
            if ([[blankDate stringByReplacingOccurrencesOfString:delimiter withString:@""]isEqualToString:@""]) {
                return @"";
            }
            return blankDate;
            
        case 15:
            //Time
            blankDate = [[[desc.fdtFormat stringByReplacingOccurrencesOfString:@"Numerical - " withString:@""] stringByReplacingOccurrencesOfString:@"HM" withString:[NSString stringWithFormat:@"H%@M", delimiter]] stringByReplacingOccurrencesOfString:@"MH" withString:[NSString stringWithFormat:@"M%@H", delimiter]];
            blankDate = [blankDate stringByReplacingOccurrencesOfString:@"HH" withString:hh];
            blankDate = [blankDate stringByReplacingOccurrencesOfString:@"MM" withString:mm];
            
            if ([[blankDate stringByReplacingOccurrencesOfString:delimiter withString:@""] isEqualToString:@""]){
                return @"";
            }
            return blankDate;
            
    }
    return @"";
    
}

- (void) clearFields {
    year = @"";
    month = @"";
    day = @"";
    hh = @"";
    mm = @"";
    
        [[IWInkworksService getInstance].currentRenderer triggerPanelField:descriptor.fdtFieldName value:NO];
    
}

- (void) setValueWithArray: (NSArray *) strings{
    if ([strings count] == 0 || [[strings objectAtIndex:0] isEqualToString:@""]){
        [self clearFields];
    }
    if (boxes){
        int size = [boxes count];
        for (int i = 0; i < size; i++){
            
            if (i < [strings count]){
                boxes[i] = [strings objectAtIndex:i];
            } else {
                boxes[i] = @"";
            }
        }
    }
    
    if ([[[[[[[[self getValue] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"/" withString:@""] stringByReplacingOccurrencesOfString:@":" withString:@""] isEqualToString:@""]) {
        [[IWInkworksService getInstance].currentRenderer triggerPanelField:descriptor.fdtFieldName value:NO];
    } else {
        [[IWInkworksService getInstance].currentRenderer triggerPanelField:descriptor.fdtFieldName value:YES];
    }
    [self setNeedsDisplay];
}

- (void)setDateWithYear:(int)yy Month:(int)mon Day:(int)dd {
    NSString *yearString = @"";
    NSString *monthString = @"";
    NSString *dayString = @"";
    
    NSString *fdtFormat = [[[[descriptor.fdtFormat lowercaseString] stringByReplacingOccurrencesOfString:@"numerical - " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"/" withString:@""];
    IWDateTimeFieldDescriptor *desc = (IWDateTimeFieldDescriptor *)descriptor;
    if (desc.fdtDelimiter != nil && ![desc.fdtDelimiter isEqualToString:@""]){
        fdtFormat = [fdtFormat stringByReplacingOccurrencesOfString:desc.fdtDelimiter withString:@""];
    }
    
    NSString *yearFormat;
    if ([fdtFormat rangeOfString:@"yyyy"].location != NSNotFound){
        yearFormat = @"yyyy";
    } else {
        yearFormat = @"yy";
    }
    yearString = [NSString stringWithFormat:@"%i", yy];
    if ([yearFormat isEqualToString:@"yy"]){
        yearString = [yearString substringFromIndex:2];
    }
    if (mon < 10) {
        monthString = [NSString stringWithFormat:@"0%i", mon];
    } else {
        monthString = [NSString stringWithFormat:@"%i", mon];
    }
    if (dd < 10) {
        dayString = [NSString stringWithFormat:@"0%i", dd];
    } else {
        dayString = [NSString stringWithFormat:@"%i", dd];
    }
    
    year = yearString;
    month = monthString;
    day = dayString;
    
    NSString *formatBlank = [fdtFormat copy];
    formatBlank = [[[formatBlank stringByReplacingOccurrencesOfString:yearFormat withString:yearString] stringByReplacingOccurrencesOfString:@"mm" withString:monthString] stringByReplacingOccurrencesOfString:@"dd" withString:dayString];
    
    NSMutableArray *chars = [NSMutableArray array];
    for (int i = 0; i < [formatBlank length]; i++){
        [chars addObject:[formatBlank substringWithRange:NSMakeRange(i, 1)]];
    }
    
    [self setValueWithArray:chars];
    
}

- (void)setTimeWithHour:(int)hour Minute:(int)minute{
    NSString *hourString = [NSString stringWithFormat:@"%i", hour];
    NSString *minString = [NSString stringWithFormat:@"%i", minute];
    
    if ([hourString length] == 1){
        hourString = [@"0" stringByAppendingString:hourString];
    }
    if ([minString length] == 1) {
        minString = [@"0" stringByAppendingString:minString];
    }
    mm = minString;
    hh = hourString;
    NSArray *timeChars = [NSArray arrayWithObjects:[hourString substringWithRange:NSMakeRange(0, 1)],[hourString substringFromIndex:1], [minString substringWithRange:NSMakeRange(0, 1)], [minString substringFromIndex:1], nil];
    [self setValueWithArray:timeChars];
}

- (void) fieldTapped: (UITapGestureRecognizer *) gestureRecognizer {
    
    
    
}

- (void)dismissKeyboard
{
    UITextField *tempTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    tempTextField.enabled = NO;
    [self addSubview:tempTextField];
    [tempTextField becomeFirstResponder];
    [tempTextField resignFirstResponder];
    [tempTextField removeFromSuperview];
    [self setNeedsDisplay];
}

- (void) setValue:(NSString *)value {
    IWDateTimeFieldDescriptor *desc = (IWDateTimeFieldDescriptor *)descriptor;
    NSString *delimiter = desc.fdtDelimiter;
    if (!delimiter){
        delimiter = @"";
    }
    if (value == nil || [value isEqualToString:@""]){
        
    } else {
        if (self.descriptor.lexiconId == 15){
            //time
            NSString *blankDate = [[[desc.fdtFormat stringByReplacingOccurrencesOfString:@"Numerical - " withString:@""] stringByReplacingOccurrencesOfString:@"HM" withString:[NSString stringWithFormat:@"H%@M", delimiter]] stringByReplacingOccurrencesOfString:@"MH" withString:[NSString stringWithFormat:@"M%@H", delimiter]];
            NSRange hourRange = [blankDate rangeOfString:@"HH"];
            NSRange minuteRange = [blankDate rangeOfString:@"MM"];
            
            mm = [value substringWithRange:minuteRange];
            hh = [value substringWithRange:hourRange];
        } else {
            //date
            NSString *blankDate = [[[[[[[desc.fdtFormat stringByReplacingOccurrencesOfString:@"Numerical - " withString:@""] stringByReplacingOccurrencesOfString:@"YM" withString:[NSString stringWithFormat:@"Y%@M",delimiter]] stringByReplacingOccurrencesOfString:@"MD" withString:[NSString stringWithFormat:@"M%@D", delimiter]] stringByReplacingOccurrencesOfString:@"DM" withString:[NSString stringWithFormat:@"D%@M", delimiter]] stringByReplacingOccurrencesOfString:@"MY" withString:[NSString stringWithFormat:@"M%@Y", delimiter]] stringByReplacingOccurrencesOfString:@"DY" withString:[NSString stringWithFormat:@"D%@Y", delimiter]] stringByReplacingOccurrencesOfString:@"YD" withString:[NSString stringWithFormat:@"Y%@D", delimiter]];
            NSRange yearRange = [blankDate rangeOfString:@"YYYY"];
            if (yearRange.location == NSNotFound){
                yearRange = [blankDate rangeOfString:@"YY"];
            }
            if (yearRange.location != NSNotFound){
                year = [value substringWithRange:yearRange];
            }
            
            NSRange monthRange = [blankDate rangeOfString:@"MM"];
            if (monthRange.location != NSNotFound){
                month = [value substringWithRange:monthRange];
            }
            
            NSRange dayRange = [blankDate rangeOfString:@"DD"];
            if (dayRange.location != NSNotFound){
                day = [value substringWithRange:dayRange];
            }
            
        }
    }
    value = [[[value stringByReplacingOccurrencesOfString:@"/" withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@":" withString:@""];
    [super setValue:value];
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if ([self.boxes[0] isEqualToString:@""]) {
        for (int i = 0; i < rects.count; i++) {
            if (i > hintArray.count - 1) {
                continue;
            }
            IWRectElement *re = rects[i];
            CGRect rec = CGRectMake(re.x - self.descriptor.x, re.y - self.descriptor.y, re.width, re.height);
            
            UIFont* font = [UIFont fontWithName:@"Arial" size:16];
            NSDictionary* stringAttrs = @{ NSFontAttributeName : font, NSForegroundColorAttributeName : [UIColor lightGrayColor] };
            
            NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:hintArray[i] attributes:stringAttrs];
            CGRect textSize = [attrStr boundingRectWithSize:rec.size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
            [attrStr drawAtPoint:CGPointMake(rec.origin.x + (rec.size.width / 2.0) - (textSize.size.width / 2.0), rec.origin.y + (rec.size.height / 2.0) - (textSize.size.height / 2.0))];
            
        }
    }
}


@end
