//
//  IWPageServer.h
//  Inkworks
//
//  Created by Jamie Duggan on 06/11/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IWPageServer : NSObject {
    NSMutableDictionary *pages;
    NSMutableArray *servedPages;
    
}

@property NSMutableDictionary *pages;
@property NSMutableArray *servedPages;



-(id)initWithArray: (NSMutableArray *) pageArray;
-(void)triggerField: (NSString *) fieldName with:(BOOL) triggerOn;
-(int)getModdedPageNumber:(int) page;
-(int)getLastPageNumber;
-(int)getFirstPageNumber;
-(int)canGoBackFrom:(int) page;
-(int)canGoForwardFrom:(int) page;



@end
