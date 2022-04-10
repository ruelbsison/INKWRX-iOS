//
//  IWDynamicPanel.m
//  Inkworks
//
//  Created by Paul Gowing on 17/10/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWDynamicPanel.h"
#import "IWFieldDescriptor.h"

@implementation IWDynamicPanel

@synthesize rectArea, panelTriggers, panelInitiallyVisible, fieldBelowPanel, panelsBelowPanel, repeatingPanel, fieldId, panelTriggersNegated, shouldMoveFieldsBelow, children, andTriggers;

-(id)init {
    self = [super init];
    if (self) {
        self.rectArea = nil;
        self.panelTriggers = [NSMutableDictionary dictionary];
        self.panelInitiallyVisible = NO;
        self.fieldBelowPanel = [NSMutableArray array];
        self.panelsBelowPanel = [NSMutableArray array];
        self.repeatingPanel = NO;
        self.fieldId = [NSString string];
        self.panelTriggersNegated = [NSMutableDictionary dictionary];
        self.shouldMoveFieldsBelow = YES;
        self.children = [NSMutableArray array];
        self.andTriggers = NO;
        
    
    }
    return self;
    
}

- (BOOL)fieldIsChild:(NSString *)fldId {
    NSString *fldIndex = fldId;
    while ([fldIndex rangeOfString:@"_"].location != NSNotFound) {
        fldIndex = [fldIndex substringFromIndex:[fldIndex rangeOfString:@"_"].location + 1];
    }
    NSScanner *intscan = [NSScanner scannerWithString:fldIndex];
    if ([intscan scanInt:nil]) {
        fldId = [fldId stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"_%@", fldIndex] withString:@""];
    }
    for (NSObject *o in self.children) {
        if ([o isKindOfClass:[IWDynamicPanel class]]) {
            IWDynamicPanel *chi = (IWDynamicPanel *)o;
            if ([chi fieldIsChild:fldId]){
                return true;
            }
        }
        if ([o isKindOfClass:[IWFieldDescriptor class]]) {
            IWFieldDescriptor *fd = (IWFieldDescriptor *)o;
            if ([fd.fieldId isEqualToString:fldId]) {
                return true;
            }
        }
        if ([o isKindOfClass:[NSString class]]) {
            if ([((NSString *)o) isEqualToString:fldId]) {
                return true;
            }
        }
    }
    return false;
}

- (BOOL)fieldIsVisible:(NSString *)fldId{
    
    for (NSObject *o in self.children) {
        if ([o isKindOfClass:[IWDynamicPanel class]]) {
            IWDynamicPanel *chi = (IWDynamicPanel *)o;
            if ([chi fieldIsVisible:fldId]){
                return true;
            }
        }
        if ([o isKindOfClass:[IWFieldDescriptor class]]) {
            IWFieldDescriptor *fd = (IWFieldDescriptor *)o;
            if ([fd.fieldId isEqualToString:fldId]) {
                return self.shouldShowPanel;
            }
        }
        if ([o isKindOfClass:[NSString class]]) {
            if ([((NSString *)o) isEqualToString:fldId]) {
                return self.shouldShowPanel;
            }
        }
    }
    return false;
}

-(void)setField:(NSString *)key negated:(BOOL)negated {
    if (panelTriggersNegated [key]) {
        [panelTriggersNegated setObject: negated? @1:@0 forKey: key];
    }
    
}

+(IWDynamicPanel *)panel {
    
    return [[IWDynamicPanel alloc] init];
}

-(BOOL) shouldShowPanel {
    if (self.panelTriggers.count == 0) {
        return panelInitiallyVisible;
        
    }
    
    if (self.andTriggers) {
        for (NSString *s in [panelTriggers copy]) {
            NSNumber *b = panelTriggers[s];
            NSNumber *negate = panelTriggersNegated[s];
            if ([negate isEqualToNumber:@1]) {
                return NO;
            }
            
            if ([b isEqualToNumber:@0] && [s rangeOfString:@"!"].location == NSNotFound) {
                return NO;
            }
            
            if ([b isEqualToNumber:@1] && [s rangeOfString:@"!"].location != NSNotFound) {
                return NO;
            }
            
        }
        
        return YES;
    }
    
    //Or Triggers
    BOOL show = NO;
    for (NSString *s in [panelTriggers copy]) {
        NSNumber *b = panelTriggers[s];
        NSNumber *negate = panelTriggersNegated[s];
        if ([b isEqualToNumber:@1] && [s rangeOfString:@"!"].location == NSNotFound && [negate isEqualToNumber:@0]) {
            show = YES;
        }
        
        if ([b isEqualToNumber:@0] && [s rangeOfString:@"!"].location != NSNotFound && [negate isEqualToNumber:@0]) {
            show = YES;
        }
        
        
    }
    
    return show;
    
    
}

@end
