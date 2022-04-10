//
//  IWHistoryController.h
//  Inkworks
//
//  Created by Jamie Duggan on 13/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWContentController.h"
#import "IWHistoryItemTableView.h"
@class IWTransaction;
@class IWHistoryTableViewCell;

@interface IWHistoryController : IWContentController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UISearchBarDelegate> {
    NSArray *historyItems;
    __weak IBOutlet IWHistoryItemTableView *table;
    IWTransaction *clickedTrans;
    IWTransaction *autoSaveTrans;
    IWHistoryTableViewCell *clickedCell;
    
    __weak IBOutlet UILabel *formStartedHeaderLabel;
    __weak IBOutlet UILabel *formParkedHeaderLabel;
    __weak IBOutlet UILabel *formSentHeaderLabel;
    __weak IBOutlet UILabel *formPrepopNameLabel;
    __weak IBOutlet UISearchBar *prepopSearch;
    BOOL hidePrepop;
}

@property NSArray *historyItems;
@property (weak) IWHistoryItemTableView *table;
@property IWTransaction *clickedTrans;
@property IWTransaction *autoSaveTrans;
@property IWHistoryTableViewCell *clickedCell;
@property BOOL hidePrepop;

@property (weak) IBOutlet UILabel *formPrepopNameLabel;
@property (weak) IBOutlet UILabel *formStartedHeaderLabel;
@property (weak) IBOutlet UILabel *formParkedHeaderLabel;
@property (weak) IBOutlet UILabel *formSentHeaderLabel;
@property (weak) IBOutlet UISearchBar *prepopSearch;
@end
