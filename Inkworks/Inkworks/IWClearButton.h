//
//  IWClearButton.h
//  Inkworks
//
//  Created by Jamie Duggan on 29/08/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IWDrawingField.h"

@interface IWClearButton : UIButton {
    IWDrawingField *drawingField;
    
}

@property IWDrawingField *drawingField;

@end
