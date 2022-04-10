//
//  IWDecimalFieldView.h
//  Inkworks
//
//  Created by Jamie Duggan on 20/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWIsoFieldView.h"

@interface IWDecimalFieldView : IWIsoFieldView {
    NSString *listArray;
    NSArray *textLabels;
    BOOL calcErrored;
    double rawValue;
}

@property NSString *listArray;
@property NSArray *textLabels;
@property BOOL calcErrored;
@property double rawValue;

- (id) initWithFrame:(CGRect)frame descriptor: (IWIsoFieldDescriptor *) desc andRects:(NSArray *)aRects andStrokeColor:(UIColor *)stroke andTextLabels: (NSArray *) labels delegate: (id<UITextFieldDelegate>)del;

@end
