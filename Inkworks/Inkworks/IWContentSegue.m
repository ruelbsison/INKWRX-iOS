//
//  IWContentSegue.m
//  Inkworks
//
//  Created by Jamie Duggan on 13/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWContentSegue.h"
#import "IWMainController.h"
#import "IWContentController.h"

@implementation IWContentSegue

-(void) perform {
    IWMainController *src = (IWMainController *)self.sourceViewController;
    IWContentController *dst = (IWContentController *)self.destinationViewController;
    for (UIView *view in src.contentView.subviews){
        [view removeFromSuperview];
    }
    
    src.currentContent = dst;
    CGRect frameSize = CGRectMake(0, 0, src.contentView.frame.size.width, src.contentView.frame.size.height);
    [dst.view setFrame:frameSize];
    [src.contentView addSubview:dst.view];
    //[src applyWindowTitle:dst.windowTitle];
    [src resetButtons];
}


@end
