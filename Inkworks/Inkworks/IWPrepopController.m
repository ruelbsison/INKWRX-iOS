//
//  IWPrepopControllerViewController.m
//  Inkworks
//
//  Created by Paul Gowing on 25/01/2015.
//  Copyright (c) 2015 Destiny Wireless. All rights reserved.
//

#import "IWPrepopController.h"
#import "IWPrepopViewableTableViewCell.h"
#import "IWPrepopNotViewableTableViewCell.h"
#import "Inkworks-Swift.h"
#import "IWMainController.h"

@interface IWPrepopController ()

@end

@implementation IWPrepopController

@synthesize prepopItems, table, search;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) init{
    self = [super init];
    
    if (self) {
        self.windowTitle = @"Prepopulated Forms";
        self.viewName = @"PREPOP";
    }
    
    return self;
}

NSArray *userForms = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    [IWInkworksService getInstance].currentPrepopItem = nil;
    [IWInkworksService getInstance].currentViewedTransaction = nil;
    [IWInkworksService getInstance].currentViewedForm = nil;
    
    UITextField *searchFld = [search valueForKey:@"_searchField"];
    searchFld.placeholder = [NSString stringWithFormat:@"%@                                                        ", searchFld.placeholder];
    
    IWSwiftDbHelper *dbh = [IWInkworksService dbHelper];
    userForms = [dbh getFormsList:[IWInkworksService getInstance].loggedInUser];
    if ([IWInkworksService getInstance].currentItemForPrepop) {
        showingAllForms = NO;
    } else {
        showingAllForms = YES;
    }
    [self refreshPrepopItems];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

BOOL showingAllForms = true;

- (void) refreshPrepopItems {
    NSString *searchText = search.text;
    
    if ([IWInkworksService getInstance].currentItemForPrepop == nil || showingAllForms) {
        //show all
        IWSwiftDbHelper *swift = [IWInkworksService dbHelper];
        if ([searchText isEqualToString:@""]) {
            prepopItems = [swift getPrepopForms:[IWInkworksService getInstance].loggedInUser];
        } else {
            prepopItems = [swift getPrepopForms:[IWInkworksService getInstance].loggedInUser search:searchText];
        }
        self.windowTitle = @"PREPOP FORMS";
        IWMainController *main = (IWMainController *)[IWInkworksService getInstance].mainInstance;
        [main applyWindowTitle:self.windowTitle];
        [main setPrepopButtonActive:NO];
    } else {
        //show specific forms
        IWSwiftDbHelper *swift = [IWInkworksService dbHelper];
        if ([searchText isEqualToString:@""]) {
            prepopItems = [swift getPrepopForms:[IWInkworksService getInstance].currentItemForPrepop.FormId user:[IWInkworksService getInstance].loggedInUser];
        } else {
            prepopItems = [swift getPrepopForms:[IWInkworksService getInstance].currentItemForPrepop.FormId user:[IWInkworksService getInstance].loggedInUser search:searchText];
        }
        self.windowTitle = [NSString stringWithFormat:@"PREPOP FORMS [%@]", [IWInkworksService getInstance].currentItemForPrepop.FormName];
        
        IWMainController *main = (IWMainController *)[IWInkworksService getInstance].mainInstance;
        [main applyWindowTitle:self.windowTitle];
        [main setPrepopButtonActive:YES];
    }
    [table reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [prepopItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IWPrepopForm *pf = [prepopItems objectAtIndex:indexPath.row];
    IWPrepopTableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"PrepopContentCell" forIndexPath:indexPath];
    
    
    NSDateFormatter *fmt = [NSDateFormatter new];
    fmt.dateFormat = @"dd/MM/yyyy HH:mm:ss";
    // Configure the cell...
    BOOL named = false;
    for (IWInkworksListItem *item in userForms) {
        if (item.FormId == pf.FormId) {
            [cell.formNameLabel setText:item.FormName];
            named = true;
            break;
        }
    }
    
    if (!named) {
        [cell.formNameLabel setText:@"<Unavailable Form>"];
    }
    
    [cell.prepopIdLabel setText:pf.PrepopName];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IWPrepopForm *pf = [prepopItems objectAtIndex:indexPath.row];
    
    
        [IWInkworksService getInstance].currentPrepopItem = pf;
        IWInkworksListItem *item = [[IWInkworksService dbHelper] getForm:pf.FormId user:[IWInkworksService getInstance].loggedInUser];
        if (item == nil) return;
        [IWInkworksService getInstance].currentViewedForm = item;
        IWPrepopTableViewCell *cell = (IWPrepopTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
        UIActivityIndicatorView *activ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activ startAnimating];
        cell.accessoryView = activ;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            IWMainController *main = (IWMainController *)[IWInkworksService getInstance].mainInstance;
            [IWInkworksService getInstance].fromHistory = NO;
            [IWDataChangeHandler getInstance].openedFromAutosave = NO;
            [main performSegueWithIdentifier:@"FormViewSegue" sender:cell];
        });
    
}
- (void)prepopButtonPressed {
    if ([IWInkworksService getInstance].currentItemForPrepop) {
        showingAllForms = !showingAllForms;
        [self refreshPrepopItems];
    } else {
        return;
    }
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self refreshPrepopItems];
}

@end
