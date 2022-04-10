//
//  IWRectangleView.m
//  Inkworks
//
//  Created by Jamie Duggan on 15/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWRectangleView.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

@implementation IWRectangleView

@synthesize fillColor, strokeColor;
@synthesize cornerRadius;
@synthesize strokeWidth;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame fillColor:(UIColor *)fill stroke:(UIColor *)stroke strokeWidth:(double)strokeW {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.fillColor = fill;
        self.strokeColor = stroke;
        self.strokeWidth = strokeW;
        
        self.layer.borderColor = [strokeColor CGColor];
        self.layer.borderWidth = strokeWidth;
        self.layer.backgroundColor = [fillColor CGColor];    }
    
    return self;
}

- (id) initWithFrame:(CGRect)frame fillColor:(UIColor *)fill stroke:(UIColor *)stroke strokeWidth:(double) strokeW cornerRadius:(double) radius{
    self = [super initWithFrame:frame];
    if (self){
        self.fillColor = fill;
        self.strokeColor = stroke;
        self.strokeWidth = strokeW;
        self.cornerRadius = radius;
        
        self.layer.cornerRadius = radius;
        self.layer.borderColor = [strokeColor CGColor];
        self.layer.borderWidth = strokeWidth;
        self.layer.backgroundColor = [fillColor CGColor];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [self.strokeColor setStroke];
    [self.fillColor setFill];
    if (rounded){
    
        UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, strokeWidth/2, strokeWidth/2) cornerRadius:xRadius];
        [path fill];
    
        path.lineWidth = strokeWidth;
        
        [path stroke];
        
    } else {
        CGRect inset = CGRectInset(self.bounds, strokeWidth/2, strokeWidth/2);
        
        [inset fill];
        
        inset.lineWidth = strokeWidth;
        
        [inset stroke];    }
}
*/

@end
