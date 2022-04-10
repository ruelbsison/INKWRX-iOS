//
//  IWButtonData.h
//  Inkworks
//
//  Created by Paul Gowing on 21/11/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IWDynamicPanel.h"
#import "IWPageDescriptor.h"
#import "CSLinearLayoutView.h"


@interface IWButtonData : NSObject

@property int panelId;
@property IWDynamicPanel *panel;
@property IWPageDescriptor  *page;
@property UIView *parentPanel;
@property int panelLeft;
@property CSLinearLayoutView *panelledV;



@end
