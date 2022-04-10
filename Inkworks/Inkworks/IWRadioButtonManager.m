//
//  IWRadioButtonManager.m
//  Inkworks
//
//  Created by Jamie Duggan on 19/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWRadioButtonManager.h"
#import "IWInkworksService.h"
#import "IWFormRenderer.h"

@implementation IWRadioButtonManager

@synthesize radios;

- (id) init {
    self = [super init];
    
    if (self) {
        radios = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)buttonClicked:(UIButton *)button {
    for (NSString *b in radios){
        IWRadioButton *clicked = (IWRadioButton *)button;
        IWRadioButton *rb = [radios objectForKey:b];
        if (![rb.descriptor.fieldId isEqualToString:clicked.descriptor.fieldId]) {
            [[IWInkworksService getInstance].currentRenderer triggerPanelField:rb.descriptor.fdtFieldName value:NO];
            rb.isTicked = NO;
            [rb.selector setHidden:YES];
        }
    }
    IWRadioButton *rb = (IWRadioButton *)button;
    if (!rb.isTicked) {
        [[IWInkworksService getInstance].currentRenderer triggerPanelField:rb.descriptor.fdtFieldName value:YES];
    
        rb.isTicked = YES;

        [rb.selector setHidden:NO];
    }
}

- (void)addButton:(IWRadioButton *)button withId:(NSString *)fieldId {
    //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    //[button addGestureRecognizer:tap];
    //[button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.myDelegate = self;
    [radios setObject:button forKey:fieldId];
}

- (BOOL)hasValue {
    for (NSString *rad in radios.keyEnumerator) {
        IWRadioButton *radio = radios[rad];
        if (radio.isTicked) return YES;
    }
    return NO;
}
@end
