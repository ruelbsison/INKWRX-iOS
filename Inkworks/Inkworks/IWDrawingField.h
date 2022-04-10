//
//  IWDrawingField.h
//  Inkworks
//
//  Created by Jamie Duggan on 19/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IWDrawingFieldDescriptor.h"
#import "IWNoteFieldDescriptor.h"

@interface IWDrawingField : UIView <UIGestureRecognizerDelegate> {
    UIColor *strokeColor;
    NSMutableArray *paths;
    
    IWFieldDescriptor *descriptor;
    
    int notesLines;
}

@property UIColor *strokeColor;
@property NSMutableArray *paths;
@property IWFieldDescriptor *descriptor;
@property int notesLines;

@property CGPoint origin;

- (id) initWithFrame:(CGRect)frame andStrokeColor: (UIColor *) stroke descriptor: (IWDrawingFieldDescriptor *)desc;
- (id) initWithFrame:(CGRect)frame andStrokeColor: (UIColor *) stroke noteDescriptor: (IWNoteFieldDescriptor *)desc;

- (void) setNotesField: (int) lines;

@end
