//
//  IWDynamicPanel.h
//  Inkworks
//
//  Created by Paul Gowing on 17/10/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IWRectElement.h"

@interface IWDynamicPanel : NSObject {
    IWRectElement *rectArea;
    NSMutableDictionary *panelTriggers;
    BOOL panelInitiallyVisible;
    NSMutableArray *fieldBelowPanel;
    NSMutableArray *panelsBelowPanel;
    BOOL repeatingPanel;
    NSString *fieldId;
    NSMutableDictionary *panelTriggersNegated;
    BOOL shouldMoveFieldsBelow;
    NSMutableArray *children;
    BOOL andTriggers;
    
    
}

@property IWRectElement *rectArea;
@property NSMutableDictionary *panelTriggers;
@property BOOL panelInitiallyVisible;
@property NSMutableArray *fieldBelowPanel;
@property NSMutableArray *panelsBelowPanel;
@property BOOL repeatingPanel;
@property NSString *fieldId;
@property NSMutableDictionary *panelTriggersNegated;
@property BOOL shouldMoveFieldsBelow;
@property NSMutableArray *children;
@property BOOL andTriggers;

-(BOOL) fieldIsChild:(NSString *) fldId;
-(BOOL) fieldIsVisible:(NSString *) fldId;
-(void) setField: (NSString *) key negated: (BOOL)negated;
-(BOOL) shouldShowPanel;
-(id) init;
+(IWDynamicPanel *) panel;



@end
