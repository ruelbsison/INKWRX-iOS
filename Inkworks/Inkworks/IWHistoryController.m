//
//  IWHistoryController.m
//  Inkworks
//
//  Created by Jamie Duggan on 13/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWHistoryController.h"
#import "IWMainController.h"
#import "IWHistoryItemViewableTableViewCell.h"
#import "IWHistoryItemNotViewableTableViewCell.h"
#import "IWDestinyConstants.h"
#import "Inkworks-Swift.h"

@interface IWHistoryController ()

@end

@implementation IWHistoryController

@synthesize historyItems, table, clickedCell, clickedTrans, autoSaveTrans, formSentHeaderLabel, formParkedHeaderLabel, formStartedHeaderLabel, hidePrepop, formPrepopNameLabel, prepopSearch;




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
        self.windowTitle = @"History";
        self.viewName = [IWInkworksService getInstance].currentHistoryScreen;
        
    }
    
    return self;
}

NSMutableDictionary *imgCache1;
NSDictionary *statusColours;
NSDictionary *statusImages;

- (void)viewDidLoad
{
    [super viewDidLoad];
    imgCache1 = [NSMutableDictionary dictionary];
    statusColours = @{
                      
                      STATUS_PARKED: [UIColor colorWithRed:77.0f/255.0f green:133.0f/255.0f blue:141.0f/255.0f alpha:1.0f],
                      STATUS_SENT: [UIColor colorWithRed:109.0f/255.0f green:205.0f/255.0f blue:177.0f/255.0f alpha:1.0f],
                      STATUS_SENDING: [UIColor colorWithRed:194.0f/255.0f green:70.0f/255.0f blue:40.0f/255.0f alpha:1.0f],
                      STATUS_AUTOSAVED: [UIColor colorWithRed:110.0f/255.0f green:175.0f/255.0f blue:204.0f/255.0f alpha:1.0f]
                      };
    statusImages = @{
                     STATUS_PARKED: @"history_status_icon_parked.png",
                     STATUS_SENDING: @"history_status_icon_pending.png",
                     STATUS_SENT: @"history_status_icon_sent.png",
                     STATUS_AUTOSAVED: @"status_icon_autosave.png"
                     };
    [IWInkworksService getInstance].currentPrepopItem = nil;
    [IWInkworksService getInstance].currentItemForPrepop = nil;
    [IWInkworksService getInstance].currentViewedTransaction = nil;
    [IWInkworksService getInstance].currentViewedForm = nil;
    // Do any additional setup after loading the view.
    //[IWInkworksService getInstance].historyInstance = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IWInkworksService getInstance].historyInstance = nil;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UITextField *searchFld = [self.prepopSearch valueForKey:@"_searchField"];
    searchFld.placeholder = [NSString stringWithFormat:@"%@                                                        ", searchFld.placeholder];
    [IWInkworksService getInstance].historyInstance = self;
    if ([[IWInkworksService getInstance].currentHistoryScreen isEqualToString:HISTORY_AUTOSAVED_CONTENT_NAME]) {
        formSentHeaderLabel.text = @"Form Autosaved";
    } else {
        formSentHeaderLabel.text = @"Form Sent";
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [historyItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.hidePrepop = YES;
    for (IWTransaction *t in historyItems) {
        if (t.PrepopId != -1) {
            self.hidePrepop = NO;
            break;
        }
    }
    [self.formPrepopNameLabel setHidden:self.hidePrepop];
    [self.prepopSearch setHidden:self.hidePrepop];
    
    IWTransaction *t = [historyItems objectAtIndex:indexPath.row];
    IWHistoryTableViewCell *cell;
    if ([t.Status isEqualToString:@"Parked"] || [t.Status isEqualToString:@"Sent"] || [t.Status isEqualToString:@"Autosaved"]){
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"ContentCell" forIndexPath:indexPath];
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NoContentCell" forIndexPath:indexPath];
        
    }
    [cell.formPrepopNameLabel setHidden:self.hidePrepop];
    if (t.PrepopId != -1) {
        IWSwiftDbHelper *swh = [IWInkworksService dbHelper];
        IWPrepopForm *ppf = [swh getPrepopForm:t.PrepopId];
        cell.formPrepopNameLabel.text = ppf.PrepopName;
        
    } else {
        
        cell.formPrepopNameLabel.text = @"";
    }
    NSDateFormatter *fmt = [NSDateFormatter new];
    fmt.dateFormat = @"dd/MM/yyyy HH:mm:ss";
    // Configure the cell...
    [cell.formNameLabel setText:t.FormName];
    [cell.formStartedLabel setText:[fmt stringFromDate:t.AddedDate]];
    [cell.formStatusLabel setText:t.Status];
    if (t.SavedDate){
        [cell.formSavedLabel setText:[fmt stringFromDate:t.SavedDate]];
    } else {
        [cell.formSavedLabel setText:@"N/A"];
    }
    if ([t.Status isEqualToString:@"Sent"]){
        [cell.formSentLabel setText:[fmt stringFromDate:t.SentDate]];
    } else {
        if ([t.Status isEqualToString:@"Sending"]){
            [cell.formSentLabel setText:@"<Sending Form>"];
        } else {
            [cell.formSentLabel setText:@"<Still Parked>"];
        }
        
    }
    if ([t.Status isEqualToString:STATUS_AUTOSAVED]) {
        [cell.formSentLabel setText:[fmt stringFromDate:t.AutoSavedDate]];
    }
    
    cell.statusIconView.backgroundColor = statusColours[t.Status];
    
    UIImage *img = imgCache1[t.Status];
    if (!img) {
        img = [UIImage imageNamed:statusImages[t.Status]];
        if (!img) {
            img = [UIImage imageNamed:@"history_status_icon_parked.png"];
        }
        imgCache1[t.Status] = img;
    }
    [cell.statusIcon setImage:img];
    
    return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IWTransaction *t = [historyItems objectAtIndex:indexPath.row];
    
    if (t.PrepopId != -1) {
        IWSwiftDbHelper *swift = [IWInkworksService dbHelper];
        IWPrepopForm *ppForm = [swift getPrepopForm:t.PrepopId];
        [IWInkworksService getInstance].currentPrepopItem = ppForm;
    }
    if ([t.Status isEqualToString:@"Parked"] || [t.Status isEqualToString:@"Sent"] || [t.Status isEqualToString:@"Autosaved"]){
        
        if (![t.Status isEqualToString:STATUS_AUTOSAVED]){
            NSArray *autosaves = [[IWInkworksService dbHelper] getAutosavedHistory:[IWInkworksService getInstance].loggedInUser search:nil];
            if (autosaves.count > 0) {
                IWTransaction *foundAuto = nil;
                for (IWTransaction *aut in autosaves) {
                    if (aut.ParentTransaction == NSNotFound || aut.ParentTransaction == -1) continue;
                    if (aut.ParentTransaction == t.ColumnIndex) {
                        foundAuto = aut;
                        break;
                    }
                }
                
                if (foundAuto != nil) {
                    clickedCell = (IWHistoryTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                    clickedTrans = t;
                    autoSaveTrans = foundAuto;
                    
                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                    UIAlertView *alert = [[UIAlertView alloc] init];
                    [alert setTitle:@"Recovered version found"];
                    [alert setMessage:@"An auto-saved version of the form has been recovered with newer data. Are you sure you wish to abandon the recovered form and open the older parked version?"];
                    [alert addButtonWithTitle:@"Yes"];
                    [alert addButtonWithTitle:@"No"];
                    [alert setCancelButtonIndex:1];
                    [alert setDelegate: self];
                    [alert show];
                    return;
                }
            }
        }
        
        if ([t.Status isEqualToString:STATUS_AUTOSAVED]) {
            if (t.ParentTransaction != NSNotFound && t.ParentTransaction != -1) {
                NSArray *all = [[IWInkworksService dbHelper] getAllHistory:[IWInkworksService getInstance].loggedInUser search:nil];
                IWTransaction *trans = nil;
                for (IWTransaction *test in all) {
                    if (test.ColumnIndex == t.ParentTransaction) {
                        trans = test;
                        break;
                    }
                }
                [IWInkworksService getInstance].currentViewedTransaction = trans;
                
            } else {
                [IWInkworksService getInstance].currentViewedTransaction = nil;
            }
            [IWInkworksService getInstance].currentAutoSavedTransaction = t;
            [IWDataChangeHandler getInstance].openedFromAutosave = YES;
        } else {
            [IWInkworksService getInstance].currentViewedTransaction = t;
            [IWDataChangeHandler getInstance].openedFromAutosave = NO;
        }
        IWInkworksListItem *item = [[IWInkworksService dbHelper] getForm:t.FormId user:[IWInkworksService getInstance].loggedInUser];
        if (item == nil) return;
        
        [IWInkworksService getInstance].currentViewedForm = item;
        IWHistoryTableViewCell *cell = (IWHistoryTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
        UIActivityIndicatorView *activ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activ startAnimating];
        cell.accessoryView = activ;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            IWMainController *main = (IWMainController *)[IWInkworksService getInstance].mainInstance;
            [IWInkworksService getInstance].fromHistory = YES;
            [main performSegueWithIdentifier:@"FormViewSegue" sender:cell];
        });
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqualToString:@"Recovered version found"]) {
        if (buttonIndex == 0) {
            [[IWInkworksService dbHelper] removeTransaction:self.autoSaveTrans clearPrepop:NO];
            [IWInkworksService getInstance].currentViewedTransaction = self.clickedTrans;
            IWInkworksListItem *item = [[IWInkworksService dbHelper] getForm:self.clickedTrans.FormId user:[IWInkworksService getInstance].loggedInUser];
            if (item == nil) return;
            
            [IWInkworksService getInstance].currentViewedForm = item;
            UIActivityIndicatorView *activ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            [activ startAnimating];
            clickedCell.accessoryView = activ;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                IWMainController *main = (IWMainController *)[IWInkworksService getInstance].mainInstance;
                [IWInkworksService getInstance].fromHistory = YES;
                [IWDataChangeHandler getInstance].openedFromAutosave = NO;
                [main performSegueWithIdentifier:@"FormViewSegue" sender:clickedCell];
            });

        }
    }
}

#pragma mark Search Bar methods

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSString *curr = [IWInkworksService getInstance].currentHistoryScreen;
    NSString *user = [IWInkworksService getInstance].loggedInUser;
    if ([curr isEqualToString:HISTORY_CONTENT_NAME]) {
        self.historyItems = [[IWInkworksService dbHelper] getAllHistory:user search:searchText];
    } else if ([curr isEqualToString:HISTORY_SENT_CONTENT_NAME]) {
        self.historyItems = [[IWInkworksService dbHelper] getSentHistory:user search:searchText];
    } else if ([curr isEqualToString:HISTORY_PARKED_CONTENT_NAME]) {
        self.historyItems = [[IWInkworksService dbHelper] getParkedHistory:user search:searchText];
    } else if ([curr isEqualToString:HISTORY_SENDING_CONTENT_NAME]) {
        self.historyItems = [[IWInkworksService dbHelper] getSendingHistory:user search:searchText];
    } else if ([curr isEqualToString:HISTORY_AUTOSAVED_CONTENT_NAME]) {
        self.historyItems = [[IWInkworksService dbHelper] getAutosavedHistory:user search:searchText];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.table reloadData];
    });
    
}

@end
