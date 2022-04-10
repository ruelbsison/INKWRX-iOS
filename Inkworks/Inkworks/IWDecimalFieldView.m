//
//  IWDecimalFieldView.m
//  Inkworks
//
//  Created by Jamie Duggan on 20/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWDecimalFieldView.h"
#import "Inkworks-Swift.h"
#import "IWDataChangeHandler.h"
@implementation IWDecimalFieldView

@synthesize listArray, textLabels, calcErrored, rawValue;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame descriptor:(IWIsoFieldDescriptor *)desc andRects:(NSArray *)aRects andStrokeColor:(UIColor *)stroke andTextLabels:(NSArray *)labels delegate:(id<UITextFieldDelegate>)del {
    self = [super initWithFrame:frame descriptor:desc andRects:aRects andStrokeColor:stroke delegate:del];
    
    if (self) {
        
        //self.boxes = [NSMutableArray array];
        self.textLabels = labels;
        self.isDecimal = YES;
        self.listArray = desc.fdtListArray;
        //NSArray *arrayList = [listArray componentsSeparatedByString:@"|"];
        //int left = [((NSString *)[arrayList objectAtIndex:0]) intValue];
        
        
        
        for (UILabel *l in self.textLabels) {
            [self addSubview:l];
        }
    }
    
    return self;
}

- (void) showEntry {
    [super showEntry];
    for (UILabel *l in self.textLabels) {
        [l setHidden:YES];
    }
}

- (void) hideKeyboard:(IWIsoSubField *)field {
    [super hideKeyboard:field];
    for (UILabel *l in self.textLabels) {
        [l setHidden: NO];
    }
}

- (NSString *) getValue {
    if (!self.textEntryField.isHidden) {
        return self.textEntryField.text;
    }
    return [self getValue:false];
}

- (NSString *)getValue : (BOOL) internal{
    
    NSMutableString *ret = [NSMutableString stringWithString:@""];
    NSArray *listSplit = [listArray componentsSeparatedByString:@"|"];
    
    int left = [[listSplit objectAtIndex:0] intValue];
    int right = 0;
    if (listSplit.count > 1) {
        right = [[listSplit objectAtIndex:1] intValue];
    }
    BOOL prependZeros = NO;
    for (int i = 0; i < left; i++){
        //IWISOLabel *box = [boxes objectAtIndex:i];
        NSString *s = boxes[i] == nil ? @"" : boxes[i];
        if (prependZeros) {
            [ret insertString:@"0" atIndex:0];
            continue;
        }
        if ([s isEqualToString:@""]){
            NSString *testString = [ret stringByReplacingOccurrencesOfString:@"0" withString:@""];
            if ([testString isEqualToString:@""]){
                [ret appendString:@"0"];
            } else {
                //found blank before decimal point, but boxes before are not blank...
                //should now add zeros to beginning of string instead of end...
                //ie " 5 _ _ " should be " 0 0 5 " - not " 5 0 0 "
                prependZeros = YES;
                [ret insertString:@"0" atIndex:0];
                
            }
        } else {
            [ret appendString:s];
        }
    }
    //Sanity check
    if ([ret length] != left){
        NSLog(@"left length of %i is the wrong length. should be %i", [ret length], left);
    }
    [ret appendString:@"."];
    NSMutableString *rString = [NSMutableString stringWithString:@""];
    for (int i = left; i < left + right; i++){
        //IWISOLabel *box = [boxes objectAtIndex:i];
        NSString *s = boxes[i] == nil ? @"" : boxes[i];
        if ([s isEqualToString:@""]){
            [rString appendString:@"0"];
        } else {
            [rString appendString:s];
        }
    }
    //Second sanity check
    if ([rString length] != right){
        NSLog(@"right length of %i is the wrong length. should be %i", [rString length], right);
    }
    [ret appendString:rString];
    
    NSString *testFinal = [[ret stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@"0" withString:@""];
    if ([testFinal isEqualToString:@""]) {
        return @"";
    }
    
    if (right == 0 && [ret rangeOfString:@"#"].location == NSNotFound) {
        return [NSString stringWithFormat:@"%i",[ret intValue]];
        
    }
    if (internal) {
        
        ret = [[[NSString stringWithFormat:@"%f",[ret doubleValue]] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"0"]] mutableCopy];
        if ([[ret substringToIndex:1] isEqualToString:@"."]) {
            [ret insertString:@"0" atIndex:0];
        }
        return [ret stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
    }
    return [ret stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
}

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@""]) {
        [IWDataChangeHandler getInstance].dataChanged = YES;
        return YES;
    }
    if ([string isEqualToString:@"."] && [textField.text rangeOfString:@"."].location != NSNotFound) {
        return NO; //can't have 2 .s!
    }
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    NSArray *arr = [self.listArray componentsSeparatedByString:@"|"];
    int leftNum = [[arr firstObject] intValue];
    int rightNum = arr.count == 1 ? 0 : [[arr lastObject] intValue];
    IWIsoSubField *s = (IWIsoSubField *)textField;
    if (isDecimal) {
        
        NSCharacterSet *numSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
        BOOL allowed = [string rangeOfCharacterFromSet:numSet].location != NSNotFound;
        if (!allowed) return NO;
        
        if ([textField.text rangeOfString:@"."].location == NSNotFound) {
            //still on left...
            if ([string isEqualToString: @"."]) {
                if (rightNum == 0) {
                    return NO;
                } else {
                    return YES;
                }
            }
            if (textField.text.length >= leftNum) return NO;
        } else {
            if (range.location <= [textField.text rangeOfString:@"."].location) {
                // dot found, but more text entered to the left of it
                return [textField.text rangeOfString:@"."].location != leftNum;
            } else {
                //dot found but text entered to the right of it
                int dotLocation = [textField.text rangeOfString:@"."].location;
                int stringLengthFromDot = textField.text.length - dotLocation - 1; //minus the dot itself
                if (stringLengthFromDot >= rightNum) {
                    return NO;
                }
            }
        }
    }
    
//    if (newLength > 1 && !returnKey){
//        int ind = [boxes indexOfObject:textField];
//        if (ind < [boxes count] - 1){
//            IWIsoSubField *next = [boxes objectAtIndex:ind+1];
//            [next becomeFirstResponder];
//            next.text = string;
//        }
//    }
    
    return newLength <= boxes.count + 1 || returnKey;
}

double roundToN(double num, int decimals)
{
    int tenpow = 1;
    for (; decimals; tenpow *= 10, decimals--);
    return round(tenpow * num) / tenpow;
}

- (void)setValue:(NSString *)value {
    BOOL numReached = NO;
    BOOL dotReached = NO;
    
    if ([value isEqualToString:@""]){
        [self clear];
        return;
    }
    
    NSArray *arr = [self.listArray componentsSeparatedByString:@"|"];
    int leftNum = [[arr firstObject] intValue];
    int rightNum = 0;
    if ([arr count] > 1){
        rightNum =[[arr lastObject] intValue];
    }
    
    if (rightNum != 0 && [value rangeOfString:@"#"].location == NSNotFound) {
        double val = [value doubleValue];
        val = roundToN(val, rightNum);
        value = [NSString stringWithFormat:@"%f", val];
    }
    
    //split string
    NSMutableArray *split = [[NSArray arrayWithObjects:value, nil] mutableCopy];
    if ([value rangeOfString:@"."].location != NSNotFound) {
        split = [[value componentsSeparatedByString:@"."] mutableCopy];
    }
    
    if (((NSString *)split[0]).length < leftNum) {
        
        NSString *repl = (NSString *)split[0];
        while (repl.length < leftNum) {
            repl = [@"0" stringByAppendingString:repl];
        }
        
        [split replaceObjectAtIndex:0 withObject:repl];
    }
    if (split.count == 1 || ((NSString *)split[1]).length < rightNum) {
        if (split.count == 1) {
            [split addObject:@"0"];
        }
        NSString *repl = (NSString *)split[1];
        while (repl.length < rightNum) {
            repl = [repl stringByAppendingString:@"0"];
        }
        [split replaceObjectAtIndex:1 withObject:repl];
    }
    
    NSString *newVal = [NSString stringWithFormat:@"%@.%@", split[0], split[1]];
    
    for (int i = 0; i < [boxes count]; i++){
        NSString *valAt = @"";
        if (i < [newVal length] - 1){
            valAt = [newVal substringWithRange:NSMakeRange(i + (dotReached ? 1 : 0), 1)];
        }
        if ([valAt isEqualToString:@"."]){
            
            dotReached = YES;
            valAt = [newVal substringWithRange:NSMakeRange(i + 1, 1)];
        }
        if ([valAt isEqualToString:@"0"]){
            if (!numReached){
                valAt = @"";
            }
        } else {
            numReached = YES;
        }
        //IWISOLabel *box = [boxes objectAtIndex:i];
        //[box setTextValue: valAt];
        boxes[i] = valAt;
    }
    [self setNeedsDisplay];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
