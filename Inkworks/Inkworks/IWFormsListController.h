//
//  IWFormsListController.h
//  Inkworks
//
//  Created by Jamie Duggan on 13/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWContentController.h"
#import "IWZipFormDownloaderDelegate.h"
@class IWFolder;
@class IWInkworksListItem;
@interface IWFormsListController : IWContentController <UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, ZipCompletedDelegate> {
    NSArray *forms;
    __weak IBOutlet UICollectionView *formList;
    int selectedRow;
    NSIndexPath *selPath;
    IWZipFormDownloaderDelegate *refreshDelegate;
    NSTimer *hideSelectorTimer;
    __weak IBOutlet UISegmentedControl *viewSwitcher;
    NSMutableDictionary *imageCache;
    NSArray *folders;
    IWFolder *currentFolder;
    long long currentFolderId;
}

@property NSArray *forms;
@property (weak) IBOutlet UICollectionView *formList;
@property int selectedRow;
@property IWZipFormDownloaderDelegate *refreshDelegate;
@property NSMutableDictionary *imageCache;
@property NSIndexPath *selPath;
@property NSTimer *hideSelectorTimer;
@property NSArray *folders;
@property (weak) IBOutlet UISegmentedControl *viewSwitcher;
@property IWFolder *currentFolder;
@property long long currentFolderId;

- (IBAction)viewIndexChanged:(id)sender;
- (void) refreshForm;
- (IWInkworksListItem *)getSelectedListItem;
- (void) refreshItems;
@end
