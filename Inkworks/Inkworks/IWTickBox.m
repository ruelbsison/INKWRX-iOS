//
//  IWTickBox.m
//  Inkworks
//
//  Created by Jamie Duggan on 19/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWTickBox.h"
#import "IWDataChangeHandler.h"
#import "IWInkworksService.h"
#import "IWFormRenderer.h"

@implementation IWTickBox

@synthesize strokeColor, isTicked, descriptor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame andStrokeColor:(UIColor *)stroke descriptor:(IWTickBoxDescriptor *)desc {
    self = [super initWithFrame:frame];
    if (self) {
        self.isTicked = NO;
        self.descriptor = desc;
        self.strokeColor = stroke;
        self.backgroundColor = [UIColor clearColor];
        int fontSize = 17;
        switch (self.descriptor.tickBoxSize) {
            case SMALL:
                fontSize = 11;
                break;
            case LARGE:
                fontSize = 24;
                break;
            default:
                fontSize = 17;
                break;
        }
        NSMutableAttributedString *tickOff = [[NSMutableAttributedString alloc] initWithString:@"\u2610"];
        NSMutableAttributedString *tickOn = [[NSMutableAttributedString alloc] initWithString:@"\u2611"];
        [tickOff addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:fontSize] range:NSMakeRange(0,1)];
        [tickOn addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:fontSize] range:NSMakeRange(0,1)];
        [tickOn addAttribute:NSForegroundColorAttributeName value:self.strokeColor range:NSMakeRange(0,1)];
        [tickOff addAttribute:NSForegroundColorAttributeName value:self.strokeColor range:NSMakeRange(0,1)];
        
        [self setAttributedTitle:tickOff forState:UIControlStateNormal];
        [self setAttributedTitle:tickOff forState:UIControlStateHighlighted];
        [self setAttributedTitle:tickOn forState:UIControlStateSelected];
//        [self setTitleColor:self.strokeColor forState:UIControlStateNormal];
//        [self setTitleColor:self.strokeColor forState:UIControlStateSelected];
//        [self setTitleColor:self.strokeColor forState:UIControlStateHighlighted];
//        
        //[self addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggle)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
        
    }
    return self;
}

- (void) toggle {
    [IWDataChangeHandler getInstance].dataChanged = YES;
    [self.superview endEditing:YES];
    self.isTicked = !self.isTicked;
    [self setSelected:self.isTicked];
    
    if (!self.isTicked) {
        [[IWInkworksService getInstance].currentRenderer triggerPanelField:descriptor.fdtFieldName value:NO];
    } else {
        [[IWInkworksService getInstance].currentRenderer triggerPanelField:descriptor.fdtFieldName value:YES];
    }
    
}

- (void) toggleOnOnly {
    [IWDataChangeHandler getInstance].dataChanged = YES;
    [self.superview endEditing:YES];
    self.isTicked = YES;
    [self setSelected:self.isTicked];
    
    if (!self.isTicked) {
        [[IWInkworksService getInstance].currentRenderer triggerPanelField:descriptor.fdtFieldName value:NO];
    }
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
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
