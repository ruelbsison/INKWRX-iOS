//
//  IWInkworksScrollView.m
//  Inkworks
//
//  Created by Jamie Duggan on 16/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWInkworksScrollView.h"

@implementation IWInkworksScrollView

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

-(BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view {
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.nextResponder touchesBegan:touches withEvent:event];
}

- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event
{
    // If not dragging, send event to next responder
    if (!self.dragging)
        [self.nextResponder touchesEnded: touches withEvent:event];
    
    [super touchesEnded: touches withEvent: event];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]){
        return NO;
    }
    return YES;
}

#pragma mark scrolling fix
//TODO: disable this when needed
- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated {
    CGRect scrollViewRect = self.frame;
    if (rect.size.width < scrollViewRect.size.width) {
        [super scrollRectToVisible:rect animated:animated];
        return;
    }
    
    CGRect newRect = CGRectMake(rect.origin.x, rect.origin.y, 100, 100);
    [super scrollRectToVisible:newRect animated:animated];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // center the image as it becomes smaller than the size of the screen
    if ([self.subviews count] == 0) return;
    
    UIView *sub = [self.subviews objectAtIndex:0];
    
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = sub.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    sub.frame = frameToCenter;
}
@end
