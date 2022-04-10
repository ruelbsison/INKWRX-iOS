//
//  IWNotesView.h
//  Inkworks
//
//  Created by Jamie Duggan on 19/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IWNoteFieldDescriptor;

@interface IWNotesView : UITextView <UIGestureRecognizerDelegate, UITextViewDelegate> {
    UIColor *strokeColor;
    NSNumber *limitPerLine;
    NSNumber *numberOfLines;
    id<UITextViewDelegate> mainDelegate;
    IWNoteFieldDescriptor *descriptor;
    BOOL scanned;
    BOOL scannerOpen;
}

@property UIColor *strokeColor;
@property NSNumber *limitPerLine;
@property NSNumber *numberOfLines;
@property IWNoteFieldDescriptor *descriptor;
@property id<UITextViewDelegate> mainDelegate;
@property BOOL scanned;
@property BOOL scannerOpen;

- (void) setPrepop;
- (id) initWithFrame:(CGRect)frame andStrokeColor: (UIColor *) stroke descriptor: (IWNoteFieldDescriptor *)desc;
- (void) longPressBox:(UIGestureRecognizer *)sender;
@end
