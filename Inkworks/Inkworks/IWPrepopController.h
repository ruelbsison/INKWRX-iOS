//
//  IWPrepopControllerViewController.h
//  Inkworks
//
//  Created by Paul Gowing on 25/01/2015.
//  Copyright (c) 2015 Destiny Wireless. All rights reserved.
//

#import "IWContentController.h"
#import "IWPrepopTableView.h"

@interface IWPrepopController : IWContentController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>{
    NSArray *prepopItems;
    __weak IBOutlet IWPrepopTableView *table;
    __weak IBOutlet UISearchBar *search;
}

@property NSArray *prepopItems;
@property (weak) IBOutlet IWPrepopTableView *table;
@property (weak) IBOutlet UISearchBar *search;

- (void) refreshPrepopItems;
- (void) prepopButtonPressed;
@end
