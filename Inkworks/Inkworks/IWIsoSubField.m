//
//  IWIsoSubField.m
//  Inkworks
//
//  Created by Jamie Duggan on 19/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWIsoSubField.h"
@implementation IWIsoSubField

@synthesize isDecimalRightBox;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void) deleteBackward {
    [super deleteBackward];
    
    if ([_myDelegate respondsToSelector:@selector(textFieldDidDelete:)]){
        [_myDelegate textFieldDidDelete:self];
    }
}

- (void)delete:(id)sender {
    UITextRange *selRange = self.selectedTextRange;
    if (selRange == nil) {
        self.text = @"";
    } else {
        if (selRange.empty) {
            self.text = @"";
        } else {
            UITextPosition *begining = self.beginningOfDocument;
            NSInteger start = [self offsetFromPosition:begining toPosition:selRange.start];
            NSInteger length = [self offsetFromPosition:selRange.start toPosition:selRange.end];
            NSRange range = NSMakeRange(start, length);
            self.text = [self.text stringByReplacingCharactersInRange:range withString:@""];
        }
    }
    if ([_myDelegate respondsToSelector:@selector(textFieldDidDelete:)]) {
        [_myDelegate textFieldDidDelete:self];
    }
}

- (BOOL) keyboardInputShouldDelete: (UITextField *) textField {
    BOOL shouldDelete = YES;
    
    if ([UITextField instancesRespondToSelector:_cmd]) {
        BOOL (*keyboardInputShouldDelete)(id, SEL, UITextField *) = (BOOL (*)(id, SEL, UITextField *))[UITextField instanceMethodForSelector:_cmd];
        
        if (keyboardInputShouldDelete) {
            shouldDelete = keyboardInputShouldDelete(self, _cmd, textField);
        }
    }
    
    if (![textField.text length] && [[[UIDevice currentDevice] systemVersion] intValue] >= 8) {
        [self deleteBackward];
    }
    
    return shouldDelete;
}



@end
