//
//  IWDataChangeHandler.h
//  Inkworks
//
//  Created by Jamie Duggan on 28/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IWDataChangeHandler : NSObject {
    BOOL dataChanged;
    BOOL openedFromAutosave;
}

@property BOOL dataChanged;
@property BOOL openedFromAutosave;

+ (IWDataChangeHandler *) getInstance;

@end
