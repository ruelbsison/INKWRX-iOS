//
//  IWNotesView.m
//  Inkworks
//
//  Created by Jamie Duggan on 19/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWNotesView.h"
#import "IWDataChangeHandler.h"
#import "IWInkworksService.h"
#import "Inkworks-Swift.h"
#import "IWFormRenderer.h"
#import "IWNoteFieldDescriptor.h"
#import <QuartzCore/QuartzCore.h>

@implementation IWNotesView

@synthesize strokeColor, limitPerLine, numberOfLines, descriptor, mainDelegate, scanned, scannerOpen;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame andStrokeColor:(UIColor *)stroke descriptor:(IWNoteFieldDescriptor *)desc{
    self = [super initWithFrame:frame];
    if (self) {
        self.strokeColor = stroke;
        self.descriptor = desc;
        self.backgroundColor = [UIColor clearColor];
        self.layer.backgroundColor = [[UIColor whiteColor] CGColor];
        self.layer.borderWidth = 1.5;
        self.scanned = NO;
        self.scannerOpen = NO;
        self.layer.borderColor = [strokeColor CGColor];
        self.font = [UIFont fontWithName:@"ArialMT" size:16];
        
        if (self.descriptor.isBarcode) {
            UIButton *barcodeButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - frame.size.height, 0, frame.size.height, frame.size.height)];
            
            [barcodeButton setBackgroundColor:[UIColor clearColor]];
//            [barcodeButton setTitle:@"Scan" forState:UIControlStateNormal];
//            [barcodeButton setTitle:@"Scan" forState:UIControlStateFocused];
//            [barcodeButton setTitle:@"Scan" forState:UIControlStateHighlighted];
//            [barcodeButton setTitle:@"Scan" forState:UIControlStateSelected];
//            
            UIImage *img = [UIImage imageNamed:@"barcode_icon"];
            [barcodeButton setImage:img forState:UIControlStateNormal];
            [barcodeButton setImage:img forState:UIControlStateFocused];
            [barcodeButton setImage:img forState:UIControlStateHighlighted];
            [barcodeButton setImage:img forState:UIControlStateSelected];
            
            barcodeButton.layer.borderColor = [strokeColor CGColor];
            barcodeButton.layer.borderWidth = 1;
            barcodeButton.layer.backgroundColor = [[UIColor clearColor] CGColor];
            
            [barcodeButton addTarget:self action:@selector(longPressBox:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:barcodeButton];
        }
        limitPerLine = [NSNumber numberWithInt: floor(frame.size.width / 9)];
        numberOfLines = [NSNumber numberWithInt:[desc.rectElements count]];
        [self setTextContainerInset:UIEdgeInsetsMake(2, 2, 2, 2)];
        
        [self setDelegate:self];
    }
    return self;
}
- (void) setPrepop {
    self.textColor = [UIColor colorWithRed:40.0/255.0 green:98.0/255.0 blue:142.0/255.0 alpha:255.0/255.0];
    [self setEditable:NO];
    
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    [IWDataChangeHandler getInstance].dataChanged = YES;
    NSUInteger oldLength = [textView.text length];
    NSUInteger replacementLength = [text length];
    NSUInteger rangeLength = range.length;
    
    if (replacementLength == 0) {
        return YES;
    }
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [text rangeOfString: @"\n"].location != NSNotFound;
    if (returnKey) {
        int numEntersAlready = (int)[textView.text length] - (int)[[textView.text stringByReplacingOccurrencesOfString:@"\n" withString:@""] length];
        
        NSArray *split = [textView.text componentsSeparatedByString:@"\n"];
        for (NSString *line in split) {
            int len = (int)line.length;
            while (len > [limitPerLine intValue]) {
                numEntersAlready += 1;
                len -= [limitPerLine intValue];
            }
        }
        
        if (numEntersAlready + 1 == [numberOfLines intValue]) {
            return NO;
        }
    } else {
        NSArray *split = [textView.text componentsSeparatedByString:@"\n"];
        int numLines = (int)split.count;
        for (NSString *line in split) {
            int lineLen = (int)line.length;
            while (lineLen > [limitPerLine intValue]) {
                numLines += 1;
                lineLen -= [limitPerLine intValue];
            }
        }
        if (numLines > [numberOfLines intValue]) {
            return NO;
        } else if (numLines == [numberOfLines intValue]) {
            int charCount = (numLines - 1) * [limitPerLine intValue];
            charCount += [[split lastObject] length];
            if (charCount >= [limitPerLine intValue] * [numberOfLines intValue]) {
                return NO;
            }
        }
    }
    
    return (newLength <= ([limitPerLine longValue ] * [numberOfLines longValue] * 0.85));// || returnKey;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    scanned = NO;
    self.textColor = [UIColor blackColor];
    if ([[[[[[[self.text  stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"/" withString:@""] stringByReplacingOccurrencesOfString:@":" withString:@""] isEqualToString:@""]) {
        [[IWInkworksService getInstance].currentRenderer triggerPanelField:descriptor.fdtFieldName value:NO];
    } else {
        [[IWInkworksService getInstance].currentRenderer triggerPanelField:descriptor.fdtFieldName value:YES];
    }
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:self.text];
    [attString addAttribute:NSKernAttributeName value:@1.5 range:NSMakeRange(0, self.text.length)];
    [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ArialMT" size:15] range:NSMakeRange(0, self.text.length)];
    [attString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, self.text.length)];
    self.attributedText = attString;
}

-(void) longPressBox:(UIGestureRecognizer *) sender {
    IWBarcodeScanViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"BarcodeScanner"];
    [vc view];
    [vc setDelegate:self];
    
    CGRect frame = vc.view.frame;
    frame.origin.x += 20;
    frame.origin.y += 20;
    frame.size.height -= 40;
    frame.size.height -= 40;
    vc.view.frame = frame;
    self.scannerOpen = true;
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [[[IWInkworksService getInstance] mainInstance] presentViewController:vc animated:YES completion:nil];
    
    
    //[presCon presentPopoverFromRect:CGRectMake(0, 0, 0, 0) inView:self.superview.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}


- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (mainDelegate != nil) {
        [mainDelegate textViewDidBeginEditing:textView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (mainDelegate != nil) {
        [mainDelegate textViewDidEndEditing:textView];
    }
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
