//
//  IWRadioButton.m
//  Inkworks
//
//  Created by Jamie Duggan on 19/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWRadioButton.h"
#import "IWInkworksService.h"
#import "IWDataChangeHandler.h"
#import "IWFormRenderer.h"
#import <QuartzCore/QuartzCore.h>

@implementation IWRadioButton

@synthesize isTicked, strokeColor, selector, myDelegate, descriptor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame andStrokeColor:(UIColor *)stroke descriptor:(IWRadioButtonDescriptor *)desc{
    self = [super initWithFrame:frame];
    if (self) {
        self.strokeColor = stroke;
        self.descriptor = desc;
        self.isTicked = NO;
        self.layer.cornerRadius = frame.size.width / 2;
        self.backgroundColor = [UIColor clearColor];
        self.layer.backgroundColor = [[UIColor whiteColor] CGColor];
        self.layer.borderColor = [self.strokeColor CGColor];
        self.layer.borderWidth = 1;
        CGRect smallFrame = CGRectMake(frame.size.width / 4, frame.size.height / 4, frame.size.width / 2, frame.size.height / 2);
        self.selector = [[UIView alloc] initWithFrame:smallFrame];
        self.selector.backgroundColor = [UIColor clearColor];
        self.selector.layer.backgroundColor = [self.strokeColor CGColor];
        self.selector.layer.cornerRadius = smallFrame.size.width / 2;
        [self addSubview:selector];
        [self.selector setHidden:YES];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggle)];
        [tap setDelegate:self];
        [self addGestureRecognizer:tap];
        
    }
    return self;
}

- (void) toggle{
    [self.superview endEditing:YES];
    [IWDataChangeHandler getInstance].dataChanged = YES;
    if (myDelegate) {
        [myDelegate buttonClicked:self];
    } else {
        self.isTicked = !self.isTicked;
        //self.selector = [self.subviews objectAtIndex:0];
        [self.selector setHidden:!self.isTicked];
        [self layoutSubviews];
    }
    if (!self.isTicked) {
        [[IWInkworksService getInstance].currentRenderer triggerPanelField:descriptor.fdtFieldName value:NO];
    }
//    else {
//        [[IWInkworksService getInstance].currentRenderer triggerPanelField:descriptor.fdtFieldName value:YES];
//    }
}

- (void) toggleFromSave{
    [self.superview endEditing:YES];
    [IWDataChangeHandler getInstance].dataChanged = YES;
    if (myDelegate) {
        [myDelegate buttonClicked:self];
    } else {
        self.isTicked = !self.isTicked;
        //self.selector = [self.subviews objectAtIndex:0];
        [self.selector setHidden:!self.isTicked];
        [self layoutSubviews];
    }
    if (!self.isTicked) {
        [[IWInkworksService getInstance].currentRenderer triggerPanelField:descriptor.fdtFieldName value:NO];
    }
    else {
        [[IWInkworksService getInstance].currentRenderer triggerPanelField:descriptor.fdtFieldName value:YES];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, rect);
    
}
*/

@end
