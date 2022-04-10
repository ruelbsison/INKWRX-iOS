//
//  IWPageServer.m
//  Inkworks
//
//  Created by Jamie Duggan on 06/11/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWPageServer.h"
#import "IWInkworksService.h"
#import "IWPageDescriptor.h"
#import "IWFormViewController.h"

@implementation IWPageServer
@synthesize pages;
@synthesize servedPages;


-(id)initWithArray: (NSMutableArray *) pageArray {
    self = [super init];
    if (self) {
        pages = [NSMutableDictionary dictionary];
        servedPages = [NSMutableArray array];
        for (IWPageDescriptor *page in pageArray) {
            [pages setObject:page forKey:[NSNumber numberWithInteger:pages.count]];
            if (page.visible) {
                [servedPages addObject:page];
                
            }
        }
    }
    
    return self;
}

-(void)triggerField: (NSString *) fieldName with:(BOOL) triggerOn {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        BOOL triggered = NO;
        IWPageDescriptor *currentPage = nil;
        NSArray *served = [[IWInkworksService getInstance].currentRenderer.pageServer.servedPages copy];
        for (IWPageDescriptor *p in served) {
            
            if ([[IWInkworksService getInstance].currentRenderer.pageServer getModdedPageNumber:p.pageNumber - 1] == [IWInkworksService getInstance].currentRenderer.pageToRender) {
                currentPage = p;
                break;
            }
        }
        
        for (NSNumber *i in pages.keyEnumerator) {
            if (((IWPageDescriptor *)pages[i]).pageTriggers[fieldName]) {
                ((IWPageDescriptor *)pages[i]).pageTriggers[fieldName] = triggerOn ? @1: @0;
                triggered = YES;
                NSArray *svd = [servedPages copy];
                if (((IWPageDescriptor *)pages[i]).shouldShow) {
                    if (![svd containsObject:pages[i]]) {
                        [servedPages addObject:pages[i]];
                        if ([i intValue] < currentPage.pageNumber - 1) {
                            [IWInkworksService getInstance].currentRenderer.pageToRender++;
                        }
                    }
                } else {
                    if ([svd containsObject:pages[i]]) {
                        [servedPages removeObject:pages[i]];
                        if ([i intValue] < currentPage.pageNumber - 1) {
                            [IWInkworksService getInstance].currentRenderer.pageToRender--;
                        }
                    }
                    
                }
            }
        }
        
        if (triggered) {
            IWPageDescriptor *page = nil;
            NSArray *testPages = [[IWInkworksService getInstance].currentRenderer.pageServer.servedPages copy];
            for (IWPageDescriptor *pg in testPages) {
                if ([[IWInkworksService getInstance].currentRenderer.pageServer getModdedPageNumber:pg.pageNumber - 1] == [IWInkworksService getInstance].currentRenderer.pageToRender) {
                    page = pg;
                    break;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{

                //dispatch_async(dispatch_get_main_queue(), ^{
                    [[IWInkworksService getInstance].formViewController.pageIndicator setTitle:[NSString stringWithFormat:@"Page %i \u25BC", [IWInkworksService getInstance].currentRenderer.pageToRender + 1]];
                    [[IWInkworksService getInstance].formViewController.ofIndicator setTitle:[NSString stringWithFormat:@"of %lu", (unsigned long)[IWInkworksService getInstance].currentRenderer.pageServer.servedPages.count]];
                    [[IWInkworksService getInstance].formViewController setPopoverSize];
                    if ([self canGoBackFrom:page.pageNumber - 1] == -1) {
                        [[IWInkworksService getInstance].formViewController.backButton setEnabled:NO];
                    } else {
                        
                        [[IWInkworksService getInstance].formViewController.backButton setEnabled:YES];
                    }
                    
                    if ([self canGoForwardFrom:page.pageNumber - 1]== -1) {
                        [[IWInkworksService getInstance].formViewController.forwardButton setEnabled:NO];
                    } else {
                        
                        [[IWInkworksService getInstance].formViewController.forwardButton setEnabled:YES];
                    }

                //});
            });
        }
    });
}


-(int)getModdedPageNumber:(int) page {
    NSNumber *pageNo = [NSNumber numberWithInt:page];
    IWPageDescriptor *pageDesc = pages[pageNo];
    NSMutableArray *orderedList = [NSMutableArray array];
    for (int i = 0; i < pages.count; i++) {
        NSNumber *num = [NSNumber numberWithInt:i];
        NSArray *svd = [servedPages copy];
        if ([svd containsObject:pages[num]]) {
            [orderedList addObject:pages[num]];
        }
        
    }
    
    return [orderedList indexOfObject:pageDesc];
    
}


-(int)getLastPageNumber {
    for (int i =pages.count -1; i >=0; i --) {
        NSNumber *pageNum = [NSNumber numberWithInt:i];
        NSArray *svd = [servedPages copy];
        if ([svd containsObject:pages[pageNum]]) {
            return i;
        }
    }
    
    return 0;
    
}


-(int)getFirstPageNumber {
    for (int i = 0; i < pages.count; i++) {
        NSNumber *pageNum = [NSNumber numberWithInt:i];
        NSArray *svd = [servedPages copy];
        if ([svd containsObject:pages[pageNum]]) {
            return i;
        }
    
        
    }
    
    return 0;
    
}


-(int)canGoBackFrom:(int) page {
    if (page == [self getFirstPageNumber]) return -1;
    for (int pageNum = page -1; pageNum >=0; pageNum--) {
        NSArray *svd = [servedPages copy];
        if ([svd containsObject:pages[[NSNumber numberWithInt:pageNum]]]) {
            return pageNum;
        }
    }
    
    return -1;
    
}


-(int)canGoForwardFrom:(int) page {
    if (page == [self getLastPageNumber]) return -1;
    for (int pageNum = page + 1; pageNum < pages.count; pageNum++) {
        NSArray *svd = [servedPages copy];
        if ([svd containsObject:pages[[NSNumber numberWithInt:pageNum]]]) {
            return pageNum;
        }
    }
        
    
    return -1;
    
    
    
}










@end
