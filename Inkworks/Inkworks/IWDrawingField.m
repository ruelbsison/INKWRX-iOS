//
//  IWDrawingField.m
//  Inkworks
//
//  Created by Jamie Duggan on 19/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWDrawingField.h"
#import "IWCustomPath.h"
#import "IWInkworksService.h"
#import "IWFormRenderer.h"
#import "IWDataChangeHandler.h"
#import <QuartzCore/QuartzCore.h>

@implementation IWDrawingField

@synthesize strokeColor, paths, descriptor, notesLines;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame andStrokeColor:(UIColor *)stroke descriptor:(IWDrawingFieldDescriptor *)desc {
    self = [super initWithFrame:frame];
    if (self) {
        self.notesLines = 0;
        self.origin = frame.origin;
        self.strokeColor = stroke;
        self.descriptor = desc;
        self.backgroundColor = [UIColor clearColor];
        self.layer.backgroundColor = [[UIColor clearColor] CGColor];
        self.layer.borderWidth = 1.5;
        self.layer.borderColor = [self.strokeColor CGColor];
        self.userInteractionEnabled = true;
        
        paths = [NSMutableArray array];
        UIPanGestureRecognizer *draw = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drawing:)];
        
        UILongPressGestureRecognizer *longPressDraw = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(drawing:)];
        longPressDraw.minimumPressDuration = 0.0;
        [longPressDraw setDelegate:self];
        
        draw.maximumNumberOfTouches = 1;
        draw.minimumNumberOfTouches = 1;
        [draw setDelegate:self];
        //[self addGestureRecognizer:draw];
        [self addGestureRecognizer:longPressDraw];
        
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame andStrokeColor:(UIColor *)stroke noteDescriptor:(IWDrawingFieldDescriptor *)desc {
    self = [super initWithFrame:frame];
    if (self) {
        self.notesLines = 0;
        self.origin = frame.origin;
        self.strokeColor = stroke;
        self.descriptor = desc;
        self.backgroundColor = [UIColor clearColor];
        self.layer.backgroundColor = [[UIColor clearColor] CGColor];
        self.layer.borderWidth = 1.5;
        self.layer.borderColor = [self.strokeColor CGColor];
        paths = [NSMutableArray array];
        UIPanGestureRecognizer *draw = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drawing:)];
        
        UILongPressGestureRecognizer *longPressDraw = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(drawing:)];
        longPressDraw.minimumPressDuration = 0.0;
        [longPressDraw setDelegate:self];
        
        draw.maximumNumberOfTouches = 1;
        draw.minimumNumberOfTouches = 1;
        [draw setDelegate:self];
        //[self addGestureRecognizer:draw];
        [self addGestureRecognizer:longPressDraw];
        [self setNotesField: ((IWNoteFieldDescriptor *)descriptor).rectElements.count];
    }
    return self;
}

BOOL mouseSwiped = NO;
//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [IWDataChangeHandler getInstance].dataChanged = YES;
//    UITouch *touch = touches.allObjects.firstObject;
//    p = [[IWCustomPath alloc] initWithOrigin:self.frame.origin];
//    [p moveTo:[touch locationInView:self]];
//    [paths addObject:p];
//    mouseSwiped = NO;
//    [[IWInkworksService getInstance].currentRenderer triggerPanelField:descriptor.fdtFieldName value:NO];
//    
//    [self setNeedsDisplay];
//    
//}
//
//- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = touches.allObjects.firstObject;
//    [p pathTo:[touch locationInView:self]];
//    mouseSwiped = YES;
//    [[IWInkworksService getInstance].currentRenderer triggerPanelField:descriptor.fdtFieldName value:NO];
//    
//    [self setNeedsDisplay];
//    
//}
//
//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    if (!mouseSwiped) {
//        [p pathTo:[touches.allObjects.firstObject locationInView:self]];
//    }
//    [[IWInkworksService getInstance].currentRenderer triggerPanelField:descriptor.fdtFieldName value:NO];
//    
//    [self setNeedsDisplay];
//    
//}

IWCustomPath *p;
- (void) setNotesField: (int) lines {
    self.notesLines = lines;
    for (UIView *v in self.subviews) {
        [v removeFromSuperview];
    }
    if (notesLines > 1) {
        NSMutableArray *boxes = [NSMutableArray array];
        int boxHeight = self.frame.size.height / notesLines;
        for (int i = 0; i < notesLines - 1; i++) {
            int boxTop = i * boxHeight;
            UIView *box = [[UIView alloc] initWithFrame:CGRectMake(0, boxTop, self.frame.size.width, boxHeight)];
            box.layer.borderWidth = 1;
            box.layer.borderColor = [self.strokeColor CGColor];
            box.backgroundColor = [UIColor clearColor];
            box.layer.backgroundColor = [[UIColor clearColor] CGColor];
            [boxes addObject:box];
        }
        for (UIView *box in boxes) {
            [self addSubview:box];
        }
    }
}

- (void) drawing: (UIPanGestureRecognizer *) gesture {

    //return;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [IWDataChangeHandler getInstance].dataChanged = YES;
        [self.superview endEditing:YES];
        p = [[IWCustomPath alloc] initWithOrigin:self.frame.origin];
        [p moveTo:[gesture locationInView:self]];
        [paths addObject:p];
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        
        [p pathTo:[gesture locationInView:self]];
    } else if (gesture.state == UIGestureRecognizerStateEnded){
        
    }
    
    
    [[IWInkworksService getInstance].currentRenderer triggerPanelField:descriptor.fdtFieldName value:NO];
    
    
    
    [self setNeedsDisplay];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    //if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
        return NO;
    //} else {
      //  return YES;
    //}
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
//    UIGraphicsBeginImageContext(self.bounds.size);
    [[UIColor blackColor] setStroke];
//    for (IWCustomPath *path in paths){
//        
//        CGContextBeginPath(UIGraphicsGetCurrentContext());
//        CGContextAddPath(UIGraphicsGetCurrentContext(), path.path);
//        CGContextStrokePath(UIGraphicsGetCurrentContext());
//    }
//    UIGraphicsEndImageContext();
    for (IWCustomPath *path in paths){
        
        [path.path stroke];
    }

}


@end
