//
//  IWIsoFieldView.m
//  Inkworks
//
//  Created by Jamie Duggan on 16/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWIsoFieldView.h"
#import "IWInkworksService.h"
#import "IWFieldDescriptor.h"
#import "IWDataChangeHandler.h"
#import "IWRectElement.h"
#import "IWFormRenderer.h"
#import <QuartzCore/QuartzCore.h>
#import "Inkworks-Swift.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation IWIsoFieldView

@synthesize rects, hintLetters, strokeColor, isDecimal, descriptor, boxes, mainDelegate, previousValue;
@synthesize allowsLower, allowsNumber, allowsText, mandatory, textEntryField, textColor, recFillColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
    }
    return self;
}


- (id) initWithFrame:(CGRect)frame descriptor:(IWIsoFieldDescriptor *)desc andRects:(NSArray *)aRects andStrokeColor:(UIColor *)stroke delegate:(id<UITextFieldDelegate>)del{
    self = [super initWithFrame:frame];
    if (self){
        [self setOpaque:NO];
        self.rects = aRects;
        self.descriptor = desc;
        self.previousValue = @"";
        self.textColor = [UIColor blackColor];
        self.recFillColor = [UIColor whiteColor];
        NSString *fdtFormat = [desc.fdtFormat lowercaseString];;
        UIKeyboardType keyboardType;
        BOOL capsOnly = NO;
        if ([fdtFormat rangeOfString:@"alpha"].location != NSNotFound){
            allowsText = YES;
            if ([fdtFormat rangeOfString:@"num"].location != NSNotFound){
                keyboardType = UIKeyboardTypeDefault;
                allowsNumber = YES;
            } else {
                keyboardType = UIKeyboardTypeAlphabet;
                allowsNumber = NO;
            }
            if ([fdtFormat rangeOfString:@"uppercase"].location != NSNotFound){
                if ([fdtFormat rangeOfString:@"lowercase"].location == NSNotFound){
                    capsOnly = YES;
                } else {
                    allowsLower = YES;
                }
            }
        } else {
            allowsNumber = YES;
            keyboardType = UIKeyboardTypeNumberPad;
            
        }
        
        self.strokeColor = stroke;
        self.boxes = [NSMutableArray array];
        if (!self.strokeColor) self.strokeColor = [UIColor blackColor];
        mainDelegate = del;
        for (IWRectElement *rec in rects){
//            CGRect bframe = CGRectMake(rec.x - frame.origin.x, rec.y - frame.origin.y, rec.width, rec.height);
//            IWISOLabel *newBox = [[IWISOLabel alloc] initWithFrame:bframe];
//            newBox.backgroundColor = [UIColor clearColor];
//            newBox.layer.borderWidth = 1.5;
//            newBox.layer.borderColor = [self.strokeColor CGColor];
//            newBox.layer.backgroundColor = [[UIColor whiteColor] CGColor];
            //newBox.keyboardType = keyboardType;
//            newBox.autocorrectionType = UITextAutocorrectionTypeNo;
//            
//            newBox.myDelegate = self;
//            [newBox setDelegate:self];
//            newBox.textAlignment = NSTextAlignmentCenter;
            
            //UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressBox:)];
            
            //[newBox addGestureRecognizer:longPress];
//            [newBox addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
//            
            
            //UITapGestureRecognizer *recog = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(fieldTapped:)];
            //[recog setDelegate:self];
            //[newBox setGestureRecognizers:@[recog]];
            /*
             case 13:
             case 14:
             case 20:
             case 21:
             case 22:
             case 23:
             case 15:
             */
//            UITapGestureRecognizer *tapField = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showEntry)];
//            switch (desc.lexiconId) {
//                case 13:
//                case 14:
//                case 20:
//                case 21:
//                case 22:
//                case 23:
//                case 15:
//                    break;
//                default:
//                    [newBox addGestureRecognizer:tapField];
//                    break;
//            }
            
            
//            newBox.userInteractionEnabled = YES;
            
            [boxes addObject:@""];
            //[self addSubview:newBox];
            
        }
        
        UITapGestureRecognizer *tapField = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showEntry)];
        switch (desc.lexiconId) {
            case 13:
            case 14:
            case 20:
            case 21:
            case 22:
            case 23:
            case 15:
                break;
            default:
                [self addGestureRecognizer:tapField];
                break;
        }
        
        
        self.userInteractionEnabled = YES;
        
        IWRectElement *firstRect = [rects firstObject];
        IWRectElement *lastRect = [rects lastObject];
        
        CGRect bframe = CGRectMake(firstRect.x - frame.origin.x, firstRect.y - frame.origin.y, lastRect.x + lastRect.width - firstRect.x, firstRect.height);
        IWIsoSubField *newBox = [[IWIsoSubField alloc] initWithFrame:bframe];
        
        newBox.backgroundColor = [UIColor clearColor];
        newBox.layer.borderWidth = 1.5;
        newBox.layer.borderColor = [self.strokeColor CGColor];
        newBox.layer.backgroundColor = [[UIColor whiteColor] CGColor];
        newBox.keyboardType = keyboardType;
        newBox.autocorrectionType = UITextAutocorrectionTypeNo;
        
        newBox.myDelegate = self;
        [newBox setDelegate:self];
        newBox.textAlignment = NSTextAlignmentLeft;
        [newBox addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
        
        
        
        //UITapGestureRecognizer *recog = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(fieldTapped:)];
        //[recog setDelegate:self];
        //[newBox setGestureRecognizers:@[recog]];
        newBox.userInteractionEnabled = YES;
        [newBox addTarget:self action:@selector(hideKeyboard:) forControlEvents:UIControlEventEditingDidEnd];
        [newBox setHidden:YES];
        textEntryField = newBox;
        [self addSubview:newBox];
        
    }
    return self;
}
BOOL loadingFromTap = NO;
-(void) showEntry {
    loadingFromTap = YES;
    [textEntryField setHidden:NO];
    textEntryField.text = [self getValue: true];
    [textEntryField becomeFirstResponder];
    loadingFromTap = NO;
}

- (void) hideKeyboard: (IWIsoSubField *) field {
    [self setValue:field.text];
    [field setHidden:YES];
    [self setNeedsDisplay];
}

- (void) keyPressed: (UITextField *) field {
    
}

- (void) setMand:(BOOL)mand {
    self.mandatory = mand;
    if (mandatory) {
        //for (IWIsoSubField *box in boxes) {
            self.recFillColor = [UIColor colorWithRed:248.0/255.0 green:158.0/255.0 blue:163.0/255.0 alpha:1];
        //}
    }
}

BOOL recasing = NO;

- (void) textChanged: (UITextField *) field{
    
    if (!recasing) {
    
        NSString *clearVal = [[[[[[textEntryField.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"/" withString:@""] stringByReplacingOccurrencesOfString:@":" withString:@""];
        
        if ([clearVal isEqualToString:@""]) {
            
            
            [[IWInkworksService getInstance].currentRenderer triggerPanelField:descriptor.fdtFieldName value:NO];
            
            
        } else {
            
            [[IWInkworksService getInstance].currentRenderer triggerPanelField:descriptor.fdtFieldName value:YES];
            
        }
        
        recasing = YES;
        NSString *fdtFormat = [descriptor.fdtFormat lowercaseString];
        if ([fdtFormat rangeOfString:@"alpha"].location != NSNotFound){
            
            if ([fdtFormat rangeOfString:@"uppercase"].location != NSNotFound){
                if ([fdtFormat rangeOfString:@"lowercase"].location == NSNotFound){
                    textEntryField.text = [textEntryField.text uppercaseString];
                }
            }
        }
        recasing = NO;
    } else {
        recasing = NO;
    }
    
}

- (void) textFieldDidDelete:(UITextField *)field {

}



- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (loadingFromTap) return YES;
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
//
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    if (returnKey) {
        [self.textEntryField resignFirstResponder];
    }
//    NSString *numbers = @"0,1,2,3,4,5,6,7,8,9,0,.";
//    NSArray *nums = [numbers componentsSeparatedByString:@","];
//    
//    NSString * chars = @"+ = _ : ; # ? / | \\ ! \" £ $ % ^ & * ( )";
//    NSArray *cArray = [chars componentsSeparatedByString:@" "];
    
    NSString *fdtFormat = [descriptor.fdtFormat lowercaseString];
    if ([fdtFormat rangeOfString:@"alpha"].location != NSNotFound){
        
        if ([fdtFormat rangeOfString:@"uppercase"].location != NSNotFound){
            if ([fdtFormat rangeOfString:@"lowercase"].location == NSNotFound){
                string = [string uppercaseString];
            }
        }
    }
    
    if (!allowsNumber && [string length]>0) {
        NSCharacterSet *numset = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        BOOL allow = [string rangeOfCharacterFromSet:numset].location == NSNotFound;
        if (!allow) return NO;
//        for (NSString *s in nums){
//            if ([[string substringFromIndex:string.length -1] rangeOfString:s ].location != NSNotFound){
//                
//                if (![s isEqualToString:@"."]){
//                    return NO;
//                }
//            }
//        }
    }
    
    if (!allowsText && [string length]>0) {
        
        NSCharacterSet *numset2 = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
        BOOL allow = [string rangeOfCharacterFromSet:numset2].location == NSNotFound;
        if (!allow) return NO;
//        BOOL isAllowed = NO;
//        for (NSString *s in nums){
//            if ([[string substringFromIndex:string.length -1] rangeOfString:s ].location != NSNotFound){
//                isAllowed = YES;
//            }
//        }
//        if (!isAllowed) return NO;
    }
    
    if ([fdtFormat rangeOfString:@"sym"].location == NSNotFound && [string length] > 0) {
        
        NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"+=_:;#?/|\\!\"£$%^&*()"];
        BOOL allow = [string rangeOfCharacterFromSet:charSet].location == NSNotFound;
        if (!allow) return NO;
//        BOOL isAllowed = YES;
//        for (NSString *c in cArray) {
//            if ([[string substringFromIndex:string.length -1] rangeOfString:c ].location != NSNotFound){
//                isAllowed = NO;
//            }
//        }
//        if (!isAllowed) return NO;
    }
    
//    if (newLength > 1 && !returnKey){
//        int ind = [boxes indexOfObject:textField];
//        if (ind < [boxes count] - 1){
//            IWIsoSubField *next = [boxes objectAtIndex:ind+1];
//            [next becomeFirstResponder];
//            next.text = string;
//        }
//    }
   
    
    [IWDataChangeHandler getInstance].dataChanged = YES;
    return newLength <= self.boxes.count || returnKey;
    
}



- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void) fieldTapped: (UITapGestureRecognizer *) gestureRecognizer{
    //UITextField *v = (UITextField *)gestureRecognizer.view;
    
}

- (NSString *) getValue {
    if (!self.textEntryField.isHidden) {
        return self.textEntryField.text;
    }
    return [self getValue:false];
}

- (NSString *) getValue: (BOOL) internal {
    NSString *val = @"";
    
    for (NSString *tf in self.boxes){
        val = [val stringByAppendingString:(tf == nil ? @"" : tf)];
    }
    return [val stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (void) clear {
    for (int i = 0; i < boxes.count; i++) {
        boxes[i] = @"";
    }
}

- (void) setValue:(NSString *)value {
    self.previousValue = [self getValue];
    [self clear];
    if ([value isEqualToString:@""]){
        return;
    }
    for (int i = 0; i < [boxes count]; i++){
        NSString *boxVal = @"";
        if (i < [value length]){
            boxVal = [value substringWithRange:NSMakeRange(i, 1)];
        }
        boxes[i] = boxVal;
        //NSString *box = [boxes objectAtIndex:i];
        //[box setTextValue: boxVal];
    }
    [self setNeedsDisplay];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (mainDelegate != nil) {
        [mainDelegate textFieldDidBeginEditing:textField];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (mainDelegate != nil) {
        [mainDelegate textFieldDidEndEditing:textField];
    }
}

- (void)setPrepop {
    //for (IWISOLabel *box in boxes) {
        self.textColor = [UIColor colorWithRed:40.0/255.0 green:98.0/255.0 blue:142.0/255.0 alpha:255.0/255.0];
        [self removeGestureRecognizer:self.gestureRecognizers.firstObject];
        
    //}
}

- (void) setCalc {
    //for (IWISOLabel *box in boxes) {
        self.recFillColor = [UIColor colorWithRed:109.0f/255.0f green:205.0f/255.0f blue:177.0f/255.0f alpha:1.0f];
        [self removeGestureRecognizer:self.gestureRecognizers.firstObject];
        
    //}
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef ref = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ref, 0.0f, 0.0f, 0.0f, 0.0f);
    CGContextFillRect(ref, self.bounds);
    if (self.textEntryField == nil || self.textEntryField.hidden){
        
        for (int i = 0; i < rects.count; i++) {
            IWRectElement *re = rects[i];
            CGRect rec = CGRectMake(re.x - self.descriptor.x, re.y - self.descriptor.y, re.width, re.height);
            
            CGContextSetLineWidth(ref, 1.5);
            CGContextSetFillColorWithColor(ref, [self.recFillColor CGColor]);
            CGContextSetStrokeColorWithColor(ref, [self.strokeColor CGColor]);
            CGContextFillRect(ref, rec);
            CGContextStrokeRect(ref, rec);
            
            UIFont* font = [UIFont fontWithName:@"Arial" size:16];
            NSDictionary* stringAttrs = @{ NSFontAttributeName : font, NSForegroundColorAttributeName : textColor };
            
            NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:boxes[i] attributes:stringAttrs];
            CGRect textSize = [attrStr boundingRectWithSize:rec.size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
            [attrStr drawAtPoint:CGPointMake(rec.origin.x + (rec.size.width / 2.0) - (textSize.size.width / 2.0), rec.origin.y + (rec.size.height / 2.0) - (textSize.size.height / 2.0))];
            
        }
    }
}


@end
