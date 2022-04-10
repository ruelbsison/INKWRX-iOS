//
//  IWFormsListController.m
//  Inkworks
//
//  Created by Jamie Duggan on 13/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWFormsListController.h"
#import "IWFormListItem.h"
#import "IWMainController.h"
#import <QuartzCore/QuartzCore.h>
#import "IWFileSystem.h"
#import "IWDestinyConstants.h"
#import "IWDataChangeHandler.h"
#import "Inkworks-Swift.h"

@interface IWFormsListController ()

@end

@implementation IWFormsListController

@synthesize forms, formList, selectedRow, imageCache, refreshDelegate, selPath, hideSelectorTimer,
            currentFolder, currentFolderId,folders, viewSwitcher;

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
        self.windowTitle = @"Forms";
        self.viewName = FORM_LIST_CONTENT_NAME;
        self.currentFolderId = -1;
    }
    
    return self;
}

- (void)viewIndexChanged:(id)sender {
    [self refreshItems];
}

- (void)refreshItems {
    IWMainController *main = (IWMainController *)[IWInkworksService getInstance].mainInstance;
    [main.removeFolderButton setHidden:YES];
    selPath = nil;
    selectedRow = -1;
    NSMutableArray *arr = [[[IWInkworksService dbHelper] getForms:[IWInkworksService getInstance].loggedInUser inFolder:currentFolderId] mutableCopy];
    forms = arr;
    folders = [[IWInkworksService dbHelper] getFoldersForUser:[IWInkworksService getInstance].loggedInUser parentFolder:currentFolderId];
    [self.formList reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    imageCache = [NSMutableDictionary dictionary];
    selectedRow = -1;
    
    
    [IWInkworksService getInstance].currentPrepopItem = nil;
    [IWInkworksService getInstance].currentItemForPrepop = nil;
    [IWInkworksService getInstance].currentViewedTransaction = nil;
    [IWInkworksService getInstance].currentViewedForm = nil;
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [IWInkworksService getInstance].formListInstance = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IWInkworksService getInstance].formListInstance = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) hideSelectorView {
    IWFormListItem *cell = hideSelectorTimer.userInfo;
    if (cell != nil) {
        [cell.selectorView setHidden:YES];
    }
    hideSelectorTimer = nil;
}

- (void)refreshForm {
    if (selectedRow == -1) {
        
    } else {
        IWDestFormService *svc = [[IWDestFormService alloc] initWithUrl:SecureServiceURL];
        [svc getEFormsSecure];
        IWInkworksListItem *item = [forms objectAtIndex:selectedRow];
        [IWInkworksService getInstance].isRefreshing = YES;
        IWFormListItem *cell = (IWFormListItem *)[formList cellForItemAtIndexPath:selPath];
        [cell.selectorView setHidden:NO];
        refreshDelegate = [[IWZipFormDownloaderDelegate alloc] initWithFormId:item.FormId];
        refreshDelegate.completeDelegate = self;
        [refreshDelegate start];
        if (hideSelectorTimer != nil) {
            [hideSelectorTimer invalidate];
            [((IWFormListItem *)hideSelectorTimer.userInfo) setHidden:YES];
            hideSelectorTimer = nil;
        }
        hideSelectorTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(hideSelectorView) userInfo:cell repeats:NO];
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

#pragma mark Collection View methods

- (int) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            switch (viewSwitcher.selectedSegmentIndex) {
                case 0:
                case 2:
                    return viewSwitcher.selectedSegmentIndex == 0 && folders.count == 0
                    ? [forms count]
                    : [folders count];
                default:
                    return [forms count];
            }
            break;
        default:
            return [forms count];
            break;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    switch (viewSwitcher.selectedSegmentIndex) {
        case 0:
            return folders.count > 0 ? 2 : 1;
        default:
            return 1;
    }
}

- (IWInkworksListItem *)getSelectedListItem {
    if (selPath.section == 0 && viewSwitcher.selectedSegmentIndex != 1) {
        return nil; // folder selected
    }
    IWInkworksListItem *item = [forms objectAtIndex:selectedRow];
    return item;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    IWInkworksListItem *item = nil;
    IWFolder *folder = nil;
    
    switch (indexPath.section) {
        case 0:
            switch (viewSwitcher.selectedSegmentIndex) {
                case 0:
                    if (folders.count > 0) {
                        folder = [folders objectAtIndex:indexPath.row];
                    } else {
                        item = [forms objectAtIndex:indexPath.row];
                    }
                    break;
                case 2:
                    folder = [folders objectAtIndex:indexPath.row];
                    break;
                default:
                    item = [forms objectAtIndex:indexPath.row];
                    break;
            }
            break;
        default:
            item = [forms objectAtIndex:indexPath.row];
            break;
    }
    
    IWFormListItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FormListItem" forIndexPath:indexPath];
    
    [cell.formNameLabel setText:item == nil ? folder.Name : item.FormName];
    UIImage *img = nil;
    if (folder) {
        img = [UIImage imageNamed:@"iw_app_ios_icon_folder"];
    } else { // load form preview
        if ([imageCache objectForKey:[NSNumber numberWithLong:item.FormId]] == nil){
            NSString *imgPath = [IWFileSystem getPreviewImagePathWithId:item.FormId];
            NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
            if (imgData != nil) {
                img = [UIImage imageWithData:imgData];
                //[imageCache setObject:img forKey:[NSNumber numberWithLong:item.formId]];
            } else {
                //check old versions
                imgPath = [imgPath stringByReplacingOccurrencesOfString:@".jpg" withString:@".png"];
                imgData = [NSData dataWithContentsOfFile:imgPath];
                if (imgData != nil){
                    img = [UIImage imageWithData:imgData];
                }
            }
        } else {
            img = [imageCache objectForKey:[NSNumber numberWithLong:item.FormId]];
        }
    }
    if (img != nil) {
        [cell.preview setImage:img];
    } else {
        [cell.preview setImage:[UIImage imageNamed:@"form_large_icon_03"]];
    }
    [cell.selectorView setHidden:YES];
    if (indexPath.row == selectedRow && selPath && indexPath.section == selPath.section){
        //cell.formNameLabel.backgroundColor = [UIColor greenColor];
        [cell.switchView setOn:YES animated:YES];
        //cell.selectorView.layer.borderColor = [[UIColor greenColor] CGColor];
        //cell.selectorView.layer.borderWidth = 10;
    } else {
        //cell.formNameLabel.backgroundColor = [UIColor blackColor];
        [cell.switchView setOn:NO animated:YES];
        //cell.selectorView.layer.borderWidth = 0;
    }
    if ([cell.gestureRecognizers count] == 0){
        UITapGestureRecognizer *doubleTapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        [doubleTapRecogniser setDelegate:self];
        [doubleTapRecogniser setNumberOfTapsRequired:2];
        [cell addGestureRecognizer:doubleTapRecogniser];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    selectedRow = indexPath.row;
    selPath = indexPath;
    IWMainController *main = (IWMainController *)[IWInkworksService getInstance].mainInstance;
    if (indexPath.section == 0 && viewSwitcher.selectedSegmentIndex != 1) {
        if (folders.count > 0) {
            [main.removeFolderButton setHidden:NO];
        } else {
            [main.removeFolderButton setHidden:YES];
        }
    } else {
        [main.removeFolderButton setHidden:YES];
    }
    [collectionView reloadItemsAtIndexPaths:[collectionView indexPathsForVisibleItems]];
    
}

- (void) doubleTap: (UIGestureRecognizer *)doubleTapRecogniser{
    IWFormListItem *cell = (IWFormListItem *)[doubleTapRecogniser view];
    NSIndexPath *path = [formList indexPathForCell:cell];
    
    if (path.section == 0 && viewSwitcher.selectedSegmentIndex != 1 && (viewSwitcher.selectedSegmentIndex != 0 || folders.count > 0)) {
        //folder
        IWFolder *folder = [folders objectAtIndex:path.row];
        currentFolderId  = folder.ColumnIndex;
        selPath = nil;
        selectedRow = -1;
        [self refreshItems];
        IWMainController *main = (IWMainController *)[IWInkworksService getInstance].mainInstance;
        [main setWindowTitle:[NSString stringWithFormat:@"FORMS [%@]", folder.Name]];
    } else {
        //form
        [cell.loadLabel setText:@"Loading Form"];
        [cell.selectorView setHidden:NO];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            IWInkworksListItem *item = [forms objectAtIndex:path.row];
            [IWInkworksService getInstance].currentViewedForm = item;
            IWMainController *main = (IWMainController *)[IWInkworksService getInstance].mainInstance;
            [IWInkworksService getInstance].currentViewedTransaction = nil;
            [IWInkworksService getInstance].fromHistory = NO;
            [IWDataChangeHandler getInstance].openedFromAutosave = NO;
            [main performSegueWithIdentifier:@"FormViewSegue" sender:self];
        });
    }
    

    
    
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)completeZip {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        IWFormListItem *cell = (IWFormListItem *)[formList cellForItemAtIndexPath:selPath];
        [cell.selectorView setHidden:YES];
        [hideSelectorTimer invalidate];
        hideSelectorTimer = nil;
        [formList reloadItemsAtIndexPaths:@[selPath]];
        [IWInkworksService getInstance].isRefreshing = NO;
        [(IWMainController *)[IWInkworksService getInstance].mainInstance resetButtons];
    });
}

- (void)formSendingComplete:(IWTransaction *)transaction completion:(IWDestinyResponse *)response {
    
}

- (void)formSendingError:(IWTransaction *)transaction error:(NSString *)error {
    
}

- (void)getZipFormSecureDownloaded:(NSObject *)info completion:(IWDestinyResponse *)response {
    
}

- (void)getEformsDownloaded:(NSObject *)info completion:(IWDestinyResponse *)response {
    
}


-(void)loginComplete:(NSObject *)info completion:(IWDestinyResponse *)response status:(int)status {
    
}

@end
