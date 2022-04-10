//
//  IWRectangleView.h
//  Inkworks
//
//  Created by Jamie Duggan on 15/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IWRectangleView : UIView {
    UIColor *fillColor;
    UIColor *strokeColor;
    
    double cornerRadius;
    
    double strokeWidth;
}

@property UIColor *fillColor;
@property UIColor *strokeColor;

@property double cornerRadius;

@property double strokeWidth;

- (id) initWithFrame:(CGRect)frame fillColor:(UIColor *) fill stroke:(UIColor *) stroke strokeWidth:(double)strokeW;
- (id) initWithFrame:(CGRect)frame fillColor:(UIColor *)fill stroke:(UIColor *)stroke strokeWidth:(double) strokeW cornerRadius:(double) radius;

@end
