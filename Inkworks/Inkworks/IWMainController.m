//
//  IWMainController.m
//  Inkworks
//
//  Created by Jamie Duggan on 13/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWMainController.h"
#import "IWDestinyConstants.h"
#import "IWDataChangeHandler.h"
#import "IWPrepopController.h"
#import "IWInkworksService.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "Inkworks-Swift.h"
#import "Bugsee/Bugsee.h"
@import Photos;


@interface IWMainController ()

@end

@implementation IWMainController

@synthesize formButtons, formViewButtons, formListButtons, historyButtons, toolbar;
@synthesize inkworksButton, homeButton, backButton, logoutButton;
@synthesize historyButton, historyParkedButton, historySendingButton, historySentButton, historyAutosavedButton;
@synthesize formsButton, attachButton, refreshButton, clearButton, sendButton, parkButton, titleLabel, titleImage, prepopButton, prepopButton2, windowTitle, titleHistoryLabel, autoSaveButton, addFolderButton, removeFolderButton;
@synthesize contentView, currentContent, currentView;
@synthesize controller, vc, attachPopController, attachVC, attachImageVC, attachImagePopController, spinner;

NSDictionary *imageNames;
NSDictionary *screenColours;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.navigationController) {
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    }
    [self setNeedsStatusBarAppearanceUpdate];
    
    //IWBarcodeReader *rdr = [[IWBarcodeReader alloc] init];
    NSExpression *exp = [NSExpression expressionWithFormat:@"777.77-123.45"];
    NSLog(@"math is %@", [exp expressionValueWithObject:nil context:nil]);
    /*
    NSString *date = @"09112015 160327";
    NSString *data = @"jTSEXNzPAsuRw35ZjZBQSGB1vKWxHJ2Qm+AtV79QazUi7O9niUq8aQ==";
    
    NSString *key = [IWInkworksService getCryptoKey:date];
    NSString *decrypt = [IWInkworksService decrypt:data withKey:key];
    */
    
#pragma mark Image Names
    imageNames = @{
                     HOME_CONTENT_NAME: @"bar_icon_home.png",
                     HISTORY_CONTENT_NAME : @"bar_icon_history.png",
                     HISTORY_PARKED_CONTENT_NAME: @"bar_icon_parked.png",
                     HISTORY_SENDING_CONTENT_NAME: @"bar_icon_pending.png",
                     HISTORY_SENT_CONTENT_NAME: @"bar_icon_sent.png",
                     HISTORY_AUTOSAVED_CONTENT_NAME: @"bar_icon_autosave.png",
                     FORM_VIEW_CONTENT_NAME: @"bar_icon_form.png",
                     FORM_LIST_CONTENT_NAME : @"bar_icon_form.png",
                     @"PREPOP" : @"bar_icon_prepop.png"
                 };
    
    screenColours =
        @{
            HOME_CONTENT_NAME: [UIColor blackColor],
            HISTORY_CONTENT_NAME: [UIColor colorWithRed:0.0f green:61.0f/255.0f blue:81.0f/255.0f alpha:1.0f],
            HISTORY_PARKED_CONTENT_NAME: [UIColor colorWithRed:77.0f/255.0f green:133.0f/255.0f blue:141.0f/255.0f alpha:1.0f],
            HISTORY_SENT_CONTENT_NAME: [UIColor colorWithRed:109.0f/255.0f green:205.0f/255.0f blue:177.0f/255.0f alpha:1.0f],
            HISTORY_SENDING_CONTENT_NAME: [UIColor colorWithRed:194.0f/255.0f green:70.0f/255.0f blue:40.0f/255.0f alpha:1.0f],
            HISTORY_AUTOSAVED_CONTENT_NAME:[UIColor colorWithRed:110.0f/255.0f green:175.0f/255.0f blue:204.0f/255.0f alpha:1.0f],
            FORM_LIST_CONTENT_NAME: [UIColor colorWithRed:245.0f/255.0f green:189.0f/255.0f blue:71.0f/255.0f alpha:1.0f],
            FORM_VIEW_CONTENT_NAME: [UIColor colorWithRed:245.0f/255.0f green:189.0f/255.0f blue:71.0f/255.0f alpha:1.0f],
            @"PREPOP": [UIColor colorWithRed:245.0f/255.0f green:189.0f/255.0f blue:71.0f/255.0f alpha:1.0f]
        };
    
    //[IWInkworksService getInstance].mainInstance = self;
    // Do any additional setup after loading the view.
    self.currentView = HOME_CONTENT_NAME;
    [self performSegueWithIdentifier:@"HomeSegue" sender:self];
    [self applyWindowTitle:@"HOME"];
    [autoSaveButton setHidden:YES];
    
    /*
     let options : PHFetchOptions = PHFetchOptions();
     options.includeAssetSourceTypes = [.TypeCloudShared, .TypeUserLibrary];
     
     let assets = PHAsset.fetchAssetsWithMediaType(.Image, options: options);
     */
    
    PHFetchOptions *opts = [[PHFetchOptions alloc] init];
    opts.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary | PHAssetSourceTypeCloudShared;
    PHFetchResult *assets = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:opts];
    
    [self.view.window setFrame: [[UIScreen mainScreen] bounds]];
    spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.frame = CGRectMake(100.0, 510.0, 50.0, 50.0);
    //spinner.center = self.view.center;
    [self.view addSubview:spinner];
    [spinner bringSubviewToFront:self.view];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [spinner startAnimating];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGRect frame = contentView.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        currentContent.view.frame = frame;
    });
}

NSArray *leftButtonConstraints;
NSArray *rightButtonConstraints;


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void) viewDidAppear:(BOOL)animated {
    [IWInkworksService getInstance].mainInstance = self;
    [self setNeedsStatusBarAppearanceUpdate];
    if (![IWInkworksService getInstance].isRefreshing) {
        [spinner stopAnimating];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    [IWInkworksService getInstance].galleryImages = [NSMutableArray array];
//    __strong NSMutableArray* assetURLDictionaries = [[NSMutableArray alloc] init];
//    __strong NSMutableArray *assetsp = [[NSMutableArray alloc] init];
//    __strong NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
//    
//    __strong ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//    
//    void (^assetEnumerator)( ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
//        if(result != nil) {
//            if([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
//                [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
//                
//                //NSLog(@"result is:%@",result);
//                //NSLog(@"asset URLDictionary is:%@",assetURLDictionaries);
//                NSURL *url= (NSURL*) [[result defaultRepresentation]url];
//                
//                [library assetForURL:url
//                         resultBlock:^(ALAsset *asset) {
//                             @try {
//                             if (asset && assetsp) {
//                                 [assetsp addObject:asset];
//                                 [[IWInkworksService getInstance].galleryImages addObject:[asset.defaultRepresentation url] ];
//                             }
//                             } @catch (NSException *ex) {
//                                 NSLog(@"Error at Main viewDidAppear");
//                             }
//                             
//                         }
//                        failureBlock:^(NSError *error){ NSLog(@"test:Fail"); } ];
//            }
//        }
//    };
//    
//    
//    void (^ assetGroupEnumerator) ( ALAssetsGroup *, BOOL *)= ^(ALAssetsGroup *group, BOOL *stop){
//        //NSLog(@"hi");
//        if(group != nil) {
//            [group enumerateAssetsUsingBlock:assetEnumerator];
//            [assetGroups addObject:group];
//            
//            NSLog(@"Number of assets in group :%d",[group numberOfAssets]);
////            for (ALAsset *asset in assetsp) {
////                //NSLog(@"%@", asset.description);
////            }
//        }
//    };
//    
//    
//    [library enumerateGroupsWithTypes:ALAssetsGroupAll
//                           usingBlock:assetGroupEnumerator
//                         failureBlock:^(NSError *error) {NSLog(@"A problem occurred");}];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001)), dispatch_get_main_queue(), ^{
        CGRect frame = contentView.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        currentContent.view.frame = frame;
    });
    
    /*src.currentContent = dst;
    CGRect frameSize = CGRectMake(0, 0, src.contentView.frame.size.width, src.contentView.frame.size.height);
    [dst.view setFrame:frameSize];
    [src.contentView addSubview:dst.view];
    //[src applyWindowTitle:dst.windowTitle];
    [src resetButtons];
    */
}

- (void) viewWillDisappear:(BOOL)animated {
    [IWInkworksService getInstance].mainInstance = nil;
}


NSMutableDictionary *imageCache;

- (void) applyWindowTitle:(NSString *)title{
    if (!imageCache) {
        imageCache = [NSMutableDictionary dictionary];
    }
    self.windowTitle = title;
    [self.titleLabel setText:title];
    [self.titleLabel sizeToFit];
    
    UIImage *img = [self findTitleImage];
    
    [titleImage setImage:img];
    [toolbar setBackgroundColor:screenColours[currentView]];
}

- (UIImage *) findTitleImage {
    UIImage *img = imageCache[currentView];
    if (!img) {
        img = [UIImage imageNamed:imageNames[currentView]];
        if (!img) {
            img = [UIImage imageNamed:@"bar_icon_eraser.png"];
        }
        imageCache[currentView] = img;
    }
    return img;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IWFormProcessor *)formProcessor {
    if ([currentView isEqualToString:FORM_VIEW_CONTENT_NAME]){
        return ((IWFormViewController *)currentContent).processor;
    } else {
        return nil;
    }
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    IWSwiftDbHelper *helper = [IWInkworksService dbHelper];
    NSString *user = [IWInkworksService getInstance].loggedInUser;
    if ([segue.identifier isEqualToString:@"HomeSegue"]){
        self.currentView = HOME_CONTENT_NAME;
    }
    if ([segue.identifier isEqualToString:@"FormsListSegue"]){
        
        IWFormsListController *flc = (IWFormsListController *)segue.destinationViewController;
        IWSwiftDbHelper *swift = [IWInkworksService dbHelper];
        NSArray *folders = [swift getFoldersForUser:user parentFolder:-1];
        flc.folders = folders;
        NSArray *formList = [helper getForms:user inFolder:-1];  //[helper getFormsListWithUser:user];
        flc.forms = formList;
        flc.currentFolderId = -1;
        [IWInkworksService getInstance].fromHistory = NO;
        [IWInkworksService getInstance].currentViewedForm = nil;
        self.currentView = FORM_LIST_CONTENT_NAME;
    }
    if ([segue.identifier isEqualToString:@"PrepopSegue"]) {
        self.currentView = @"PREPOP";
        if ([IWInkworksService getInstance].currentItemForPrepop) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self setPrepopButtonActive:YES];
                
            });
        } else {
            [self setPrepopButtonActive:NO];
        }
    }
    if ([segue.identifier rangeOfString:@"History"].location != NSNotFound){
        IWHistoryController *historyController = (IWHistoryController *)segue.destinationViewController;
        if ([segue.identifier isEqualToString:@"AllHistorySegue"]){
            self.currentView = HISTORY_CONTENT_NAME;
            
            NSArray *allHist = [[IWInkworksService dbHelper] getAllHistory:user search:nil];
            historyController.historyItems = allHist;
            
            [IWInkworksService getInstance].currentHistoryScreen = HISTORY_CONTENT_NAME;
        } else if ([segue.identifier isEqualToString:@"ParkedHistorySegue"]){
            self.currentView = HISTORY_PARKED_CONTENT_NAME;
            NSArray *parkedHist = [[IWInkworksService dbHelper] getParkedHistory:user search:nil];
            historyController.historyItems = parkedHist;
            [IWInkworksService getInstance].currentHistoryScreen = HISTORY_PARKED_CONTENT_NAME;
        } else if ([segue.identifier isEqualToString:@"SendingHistorySegue"]){
            self.currentView = HISTORY_SENDING_CONTENT_NAME;
            NSArray *sendingHist = [[IWInkworksService dbHelper] getSendingHistory:user search:nil];
            historyController.historyItems = sendingHist;
            [IWInkworksService getInstance].currentHistoryScreen = HISTORY_SENDING_CONTENT_NAME;
        } else if ([segue.identifier isEqualToString:@"SentHistorySegue"]){
            self.currentView = HISTORY_SENT_CONTENT_NAME;
            NSArray *sentHist = [[IWInkworksService dbHelper] getSentHistory:user search:nil];
            historyController.historyItems = sentHist;
            [IWInkworksService getInstance].currentHistoryScreen = HISTORY_SENT_CONTENT_NAME;
        } else if ([segue.identifier isEqualToString:@"AutoSavedHistorySegue"]) {
            self.currentView = HISTORY_AUTOSAVED_CONTENT_NAME;
            NSArray *autoSavedHist = [[IWInkworksService dbHelper] getAutosavedHistory:user search: nil];
            historyController.historyItems = autoSavedHist;
            [IWInkworksService getInstance].currentHistoryScreen = HISTORY_AUTOSAVED_CONTENT_NAME;
        }
    }
    if ([segue.identifier isEqualToString:@"FormViewSegue"]){
        self.currentView = FORM_VIEW_CONTENT_NAME;
    }
    if ([segue.identifier isEqualToString:@"LogoutSegue"]){
        [IWInkworksService getInstance].loggedInPassword = @"";
        [IWInkworksService getInstance].loggedInUser = @"";
        return;
    }
    [self resetButtons];
}

- (void) resetButtons{
    [titleHistoryLabel setText:@""];
    [inkworksButton setSelected:[IWInkworksService getInstance].webserviceError];
    [homeButton setHidden:[self.currentView isEqualToString:HOME_CONTENT_NAME]];
    [backButton setHidden:[self.currentView isEqualToString:HOME_CONTENT_NAME]];
    [logoutButton setHidden:![self.currentView isEqualToString:HOME_CONTENT_NAME]];
    
    [historyAutosavedButton setHidden:YES];
    [self.refreshButton setHidden:YES];
    if ([self.currentView isEqualToString:HOME_CONTENT_NAME]){
        [self applyWindowTitle:@"HOME"];
        //[self.toolbar setHidden:YES];
    }
    
    [formsButton setSelected:NO];
    for (UIButton *button in formViewButtons.subviews){
        [button setSelected:NO];
    }
    for (UIButton *button in formListButtons.subviews){
        [button setSelected:NO];
    }
    
    [historyButton setSelected:NO];
    for (UIButton *button in historyButtons.subviews[0].subviews){
        [button setSelected:NO];
    }
    
    [formViewButtons setHidden: YES];
    [formListButtons setHidden: YES];
    [formButtons setHidden: YES];
    [historyButtons setHidden: YES];
    
    if ([self.currentView isEqualToString:FORM_LIST_CONTENT_NAME] || [self.currentView isEqualToString:@"PREPOP"]){
        [formButtons setHidden:NO];
        [refreshButton setSelected:[IWInkworksService getInstance].isRefreshing];
        [formListButtons setHidden:NO];
        [formsButton setSelected:![self.currentView isEqualToString:@"PREPOP"]];
        if (![self.currentView isEqualToString:@"PREPOP"]) {
            [self applyWindowTitle:@"FORMS"];
            [self.refreshButton setHidden:NO];
        }
    }
    
    if ([self.currentView isEqualToString:FORM_LIST_CONTENT_NAME]) {
        [addFolderButton setHidden:NO];
        [removeFolderButton setHidden:YES];
    }
    
    if ([self.currentView isEqualToString:FORM_VIEW_CONTENT_NAME] ){
        [formButtons setHidden:NO];
        [formViewButtons setHidden:NO];
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown) {
            UIInterfaceOrientation iorientation = [UIApplication sharedApplication].statusBarOrientation;
            if (iorientation == UIInterfaceOrientationLandscapeLeft || iorientation == UIInterfaceOrientationLandscapeRight) {
                [self applyWindowTitle:[NSString stringWithFormat:@"FORM [%@]", [IWInkworksService getInstance].currentViewedForm.FormName]];
            } else {
                if ([IWInkworksService getInstance].currentViewedForm.FormName.length > 20) {
                    NSString *shortName =[NSString stringWithFormat:@"%@...", [[IWInkworksService getInstance].currentViewedForm.FormName substringToIndex:17]];
                    [self applyWindowTitle:[NSString stringWithFormat:@"FORM [%@]", shortName]];
                    
                } else {
                    [self applyWindowTitle:[NSString stringWithFormat:@"FORM [%@]", [IWInkworksService getInstance].currentViewedForm.FormName]];
                }
            }
        } else if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
            [self applyWindowTitle:[NSString stringWithFormat:@"FORM [%@]", [IWInkworksService getInstance].currentViewedForm.FormName]];
        } else {
            if ([IWInkworksService getInstance].currentViewedForm.FormName.length > 20) {
                NSString *shortName =[NSString stringWithFormat:@"%@...", [[IWInkworksService getInstance].currentViewedForm.FormName substringToIndex:17]];
                [self applyWindowTitle:[NSString stringWithFormat:@"FORM [%@]", shortName]];
                
            } else {
                [self applyWindowTitle:[NSString stringWithFormat:@"FORM [%@]", [IWInkworksService getInstance].currentViewedForm.FormName]];
            }
        }
        
    }
    
    if ([self.currentView rangeOfString:@"HISTORY"].location != NSNotFound){
        [historyButtons setHidden:NO];
        int autosavedCount = [[IWInkworksService dbHelper] getAutosavedHistory:[IWInkworksService getInstance].loggedInUser search: nil].count;
        if (autosavedCount > 0) {
            [historyAutosavedButton setHidden:NO];
        }
        NSDate *date = [NSDate date];
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *components = [cal components:NSCalendarUnitDay fromDate:date];
//        NSString *day = [NSString stringWithFormat:@"%ld", (long)[components day]];
//        NSMutableAttributedString *string = [[historyButton attributedTitleForState:UIControlStateNormal] mutableCopy];
//        [[string mutableString] setString:day];
//        [historyButton setAttributedTitle:string forState:UIControlStateNormal];
//        [historyButton setAttributedTitle:string forState:UIControlStateHighlighted];
//        [historyButton setAttributedTitle:string forState:UIControlStateSelected];
        
        [historyButton setTitle:[NSString stringWithFormat:@"%ld", (long)[components day]] forState:UIControlStateNormal];
        [historyButton setTitle:[NSString stringWithFormat:@"%ld", (long)[components day]] forState:UIControlStateHighlighted];
        [historyButton setTitle:[NSString stringWithFormat:@"%ld", (long)[components day]] forState:UIControlStateSelected];
        
        if ([self.currentView isEqualToString:HISTORY_CONTENT_NAME]){
            [historyButton setSelected:YES];
            [titleHistoryLabel setText:[NSString stringWithFormat:@"%ld", (long)[components day]]];
            [self applyWindowTitle:@"HISTORY"];
        } else if ([self.currentView isEqualToString:HISTORY_SENT_CONTENT_NAME]){
            [historySentButton setSelected:YES];
            [self applyWindowTitle:@"SENT"];
        } else if ([self.currentView isEqualToString:HISTORY_SENDING_CONTENT_NAME]){
            [historySendingButton setSelected:YES];
            [self applyWindowTitle:@"PENDING"];
        } else if ([self.currentView isEqualToString:HISTORY_PARKED_CONTENT_NAME]){
            [historyParkedButton setSelected:YES];
            [self applyWindowTitle:@"PARKED"];
        } else if ([self.currentView isEqualToString:HISTORY_AUTOSAVED_CONTENT_NAME]) {
            [historyAutosavedButton setSelected:YES];
            [self applyWindowTitle:@"AUTO SAVE"];
        }
    }
    
}

#pragma mark IBActions

- (IBAction)addFolderPressed {
    IWFormsListController *fvc = (IWFormsListController *)currentContent;
    
    BOOL addFolder = YES;
    //1 is an item selected?
    if (fvc.selPath) {
        //2 if we're not in root folder
        if (fvc.currentFolderId != -1) {
            addFolder = NO;
        }
        //3 if the selected item is a folder
        if (fvc.selPath.section == 0 && fvc.viewSwitcher.selectedSegmentIndex != 1 && fvc.folders > 0) {
            // and it's not the only folder
            if (fvc.folders.count> 1) {
                addFolder = NO;
            }
        } else {
        //4 selected item is a form
            //and there are folders
            if (fvc.folders.count > 0) {
                addFolder = NO;
            }
        }
    }
    
     
    //see logic details above...
    if (!addFolder) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Action" message:@"What would you like to do?" preferredStyle:UIAlertControllerStyleActionSheet];
        alert.popoverPresentationController.sourceView = formListButtons;
        alert.popoverPresentationController.sourceRect = addFolderButton.frame;
        UIAlertAction *addFolder = [UIAlertAction actionWithTitle:@"Create a Folder" style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
            [self addFolder:fvc];
        }];
        
        UIAlertAction *moveToFolder = [UIAlertAction actionWithTitle:@"Move to Folder" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self moveToFolder:fvc];
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:addFolder];
        [alert addAction:moveToFolder];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        [self addFolder:fvc];
    }
}

- (void) moveToFolder:(IWFormsListController *)flc {
    if (flc.selPath.section == 0 && flc.viewSwitcher.selectedSegmentIndex != 1 && (flc.viewSwitcher.selectedSegmentIndex != 0 || flc.folders.count > 0)) {
        //folder
        IWFolder *folderToMove = [flc.folders objectAtIndex:flc.selPath.row];
        [self moveToFolder:flc folder:folderToMove form:nil];
    } else {
        //form
        IWInkworksListItem *formToMove = [flc.forms objectAtIndex:flc.selPath.row];
        [self moveToFolder:flc folder:nil form:formToMove];
    }
}

- (void) moveToFolder:(IWFormsListController *) flc folder:(IWFolder *)folder form:(IWInkworksListItem *)form {
    IWSwiftDbHelper *swift = [IWInkworksService dbHelper];
    UIAlertController *moveToFolder = [UIAlertController alertControllerWithTitle:@"Move to" message:[NSString stringWithFormat:@"Please select a folder to which you would like to move %@", folder == nil ? form.FormName : folder.Name] preferredStyle:UIAlertControllerStyleActionSheet];
    moveToFolder.popoverPresentationController.sourceView = formListButtons;
    moveToFolder.popoverPresentationController.sourceRect = addFolderButton.frame;
    if (flc.currentFolderId != -1) {
        UIAlertAction *moveUp = [UIAlertAction actionWithTitle:@"Move Up" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            IWFolder *currentFolder = [swift getFolderById:flc.currentFolderId];
            if (folder) {
                folder.ParentFolder = currentFolder.ParentFolder;
                [swift addOrUpdateFolder:folder];
            } else {
                form.ParentFolder = currentFolder.ParentFolder;
                [swift addOrUpdateForm:form];
            }
            [flc refreshItems];
        }];
        [moveToFolder addAction:moveUp];
    }
    for (IWFolder *flder in flc.folders) {
        if (folder && folder.ColumnIndex == flder.ColumnIndex) {
            continue;
        }
        UIAlertAction *subFolder = [UIAlertAction actionWithTitle:flder.Name style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if (folder) {
                folder.ParentFolder = flder.ColumnIndex;
                [swift addOrUpdateFolder:folder];
            } else {
                form.ParentFolder = flder.ColumnIndex;
                [swift addOrUpdateForm:form];
            }
            [flc refreshItems];
        }];
        [moveToFolder addAction:subFolder];
    }
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [moveToFolder addAction:cancel];
    
    [self presentViewController:moveToFolder animated:YES completion:nil];
}

- (void) addFolder:(IWFormsListController *) flc {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add Folder" message:@"Choose a name for the new folder" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
       textField.placeholder = @"Folder name";
    }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        IWSwiftDbHelper *swift = [IWInkworksService dbHelper];
        NSArray *folders = [swift getFoldersForUser:[[IWInkworksService getInstance].loggedInUser lowercaseString] parentFolder:flc.currentFolderId];
        NSString *newName = [alert textFields].firstObject.text;
        BOOL exists = NO;
        for (IWFolder *fld in folders) {
            if ([fld.Name isEqualToString:newName]) {
                exists = YES;
                break;
            }
        }
        if (exists) {
            UIAlertController *existing = [UIAlertController alertControllerWithTitle:@"Folder Exists" message:[NSString stringWithFormat:@"A folder named %@ already exists", newName] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
            [existing addAction:ok];
            [self presentViewController:existing animated:YES completion:nil];
            return;
        }
        
        IWFolder *folder = [[IWFolder alloc] init];
        folder.Name = newName;
        folder.User = [[IWInkworksService getInstance].loggedInUser lowercaseString];
        folder.ParentFolder = flc.currentFolderId;
        [swift addOrUpdateFolder:folder];
        [flc refreshItems];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)removeFolderPressed {
    IWFormsListController *fvc = (IWFormsListController *)currentContent;
    if (!fvc.selPath || fvc.selPath.section != 0 || fvc.viewSwitcher.selectedSegmentIndex == 1) {
        return;
    }
    IWFolder *folder = [fvc.folders objectAtIndex:fvc.selPath.row];
    
    UIAlertController *confirm = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:[NSString stringWithFormat:@"Are you sure you wish to delete the folder named \"%@\"?", folder.Name] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [[IWInkworksService dbHelper] deleteFolder:folder];
        [fvc refreshItems];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];
    
    [confirm addAction:ok];
    [confirm addAction:cancel];
    [self presentViewController:confirm animated:YES completion:nil];
    
}

- (IBAction) historyButtonPressed:(id)sender{
    UIButton *button = (UIButton *)sender;
    switch (button.tag){
        case SENT_BUTTON_TAG:
            
            break;
        case SENDING_BUTTON_TAG:
            
            break;
        case PARKED_BUTTON_TAG:
            
            break;
        default:
            break;
    }
}

- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

- (IBAction)homeButtonPressed{
    if (![currentView isEqualToString:HOME_CONTENT_NAME]){
        if ([currentView isEqualToString:FORM_VIEW_CONTENT_NAME]){
            //Check if saved data...
            if ([IWDataChangeHandler getInstance].openedFromAutosave) {
                UIAlertView *alert = [[UIAlertView alloc] init];
                [alert setTitle:@"Return to home screen?"];
                [alert setMessage:@"Are you sure you wish to discard this Auto-Saved form?"];
                [alert addButtonWithTitle:@"Ok"];
                [alert addButtonWithTitle:@"Cancel"];
                [alert setCancelButtonIndex:1];
                [alert setDelegate: self];
                [alert show];
            } else if ([IWDataChangeHandler getInstance].dataChanged) {
                UIAlertView *alert = [[UIAlertView alloc] init];
                [alert setTitle:@"Return to home screen?"];
                [alert setMessage:@"Any unsaved data will be lost. Are you sure?"];
                [alert addButtonWithTitle:@"Ok"];
                [alert addButtonWithTitle:@"Cancel"];
                [alert setCancelButtonIndex:1];
                [alert setDelegate: self];
                [alert show];
            } else {
                IWFormViewController *fvc = (IWFormViewController *)currentContent;
                [fvc.autoSaveTimer invalidate];
                if (fvc.processor.autoSavedTransaction != nil) {
                    IWTransaction *ast = (IWTransaction *)fvc.processor.autoSavedTransaction;
                    if (ast.ColumnIndex != NSNotFound && ast.ColumnIndex != -1) {
                        [[IWInkworksService dbHelper] removeTransaction:ast clearPrepop:NO];
                    }
                }
                [self performSegueWithIdentifier:@"HomeSegue" sender:self];
            }
        } else {
            [self performSegueWithIdentifier:@"HomeSegue" sender:self];
        }
    }
}

UIAlertView *logoutAlert;

- (IBAction)backButtonPressed{
    if ([currentView isEqualToString:HOME_CONTENT_NAME]){
        logoutAlert = [UIAlertView new];
        [logoutAlert setTitle:@"Are you sure?"];
        [logoutAlert setMessage:@"This will log you out."];
        [logoutAlert addButtonWithTitle:@"Logout"];
        [logoutAlert addButtonWithTitle:@"Cancel"];
        [logoutAlert setDelegate:self];
        [logoutAlert show];
        return;
    } else {
        //not home...
        [self goBack];
        
    }
}

- (void) goBack{
    if ([currentView isEqualToString:FORM_VIEW_CONTENT_NAME]){
        //in a form... is it saved?
        
        if ([IWDataChangeHandler getInstance].openedFromAutosave) {
            UIAlertView *alert = [[UIAlertView alloc] init];
            [alert setTitle:@"Return to previous screen?"];
            [alert setMessage:@"Are you sure you wish to discard this Auto-Saved form?"];
            [alert addButtonWithTitle:@"Yes"];
            [alert addButtonWithTitle:@"No"];
            [alert setCancelButtonIndex:1];
            [alert setDelegate: self];
            [alert show];
        } else if ([IWDataChangeHandler getInstance].dataChanged) {
            UIAlertView *alert = [[UIAlertView alloc] init];
            [alert setTitle:@"Return to previous screen?"];
            [alert setMessage:@"Any unsaved data will be lost. Are you sure?"];
            [alert addButtonWithTitle:@"Ok"];
            [alert addButtonWithTitle:@"Cancel"];
            [alert setCancelButtonIndex:1];
            [alert setDelegate: self];
            [alert show];
        } else {
            IWFormViewController *fvc = (IWFormViewController *)currentContent;
            [fvc.autoSaveTimer invalidate];
            if (fvc.processor.autoSavedTransaction != nil) {
                IWTransaction *ast = (IWTransaction *)fvc.processor.autoSavedTransaction;
                if (ast.ColumnIndex != NSNotFound && ast.ColumnIndex != -1) {
                    [[IWInkworksService dbHelper] removeTransaction:ast clearPrepop:NO];
                }
            }
            if ([IWInkworksService getInstance].fromHistory ){
                if ([[IWInkworksService getInstance].currentHistoryScreen isEqualToString:HISTORY_CONTENT_NAME]){
                    [self performSegueWithIdentifier:@"AllHistorySegue" sender:historyButton];
                } else if ([[IWInkworksService getInstance].currentHistoryScreen isEqualToString:HISTORY_PARKED_CONTENT_NAME]){
                    [self performSegueWithIdentifier:@"ParkedHistorySegue" sender:historyParkedButton];
                } else if ([[IWInkworksService getInstance].currentHistoryScreen isEqualToString:HISTORY_SENDING_CONTENT_NAME]){
                    [self performSegueWithIdentifier:@"SendingHistorySegue" sender:historySendingButton];
                } else if ([[IWInkworksService getInstance].currentHistoryScreen isEqualToString:HISTORY_SENT_CONTENT_NAME]){
                    [self performSegueWithIdentifier:@"SentHistorySegue" sender:historySentButton];
                } else if ([[IWInkworksService getInstance].currentHistoryScreen isEqualToString:HISTORY_AUTOSAVED_CONTENT_NAME]) {
                    [self performSegueWithIdentifier:@"HomeSegue" sender:self];
                }
            } else {
                if ([IWInkworksService getInstance].currentPrepopItem) {
                    [self performSegueWithIdentifier:@"PrepopSegue" sender:self];
                } else {
                    [self performSegueWithIdentifier:@"FormsListSegue" sender:self];
                }
            }

        }
        
        
        return;
    } else if ([currentView isEqualToString:FORM_LIST_CONTENT_NAME]) {
        IWFormsListController *flc = (IWFormsListController *)currentContent;
        if (flc.currentFolderId == -1) {
            [self performSegueWithIdentifier:@"HomeSegue" sender:self];
        } else {
            IWSwiftDbHelper *swift = [IWInkworksService dbHelper];
            IWFolder *currentFolder = [swift getFolderById:flc.currentFolderId];
            flc.currentFolderId = currentFolder.ParentFolder;
            if (flc.currentFolderId == -1) {
                [self setWindowTitle:@"FORMS"];
            } else {
                IWFolder *parentFolder = [swift getFolderById:flc.currentFolderId];
                [self setWindowTitle:[NSString stringWithFormat:@"FORMS [%@]", parentFolder.Name]];
            }
            [flc refreshItems];
        }
    } else {
        if ([currentView isEqualToString:@"PREPOP"]) {
            if ([IWInkworksService getInstance].currentItemForPrepop) {
                [self performSegueWithIdentifier:@"FormsListSegue" sender:self];
            } else {
                [self performSegueWithIdentifier:@"HomeSegue" sender:self];
            }
        } else {
            [self performSegueWithIdentifier:@"HomeSegue" sender:self];
        }
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.title isEqualToString:@"Are you sure?"]){
        //0 = logout, 1 = cancel
        if (buttonIndex == 0){
            [self performSegueWithIdentifier:@"LogoutSegue" sender:self];
        } else {
            [alertView dismissWithClickedButtonIndex:1 animated:YES];
        }
    } else if ([alertView.title isEqualToString:@"Return to previous screen?"]){
        // back button...
        if (buttonIndex == 0){
            [IWDataChangeHandler getInstance].openedFromAutosave = NO;
            IWFormViewController *fvc = (IWFormViewController *)currentContent;
            [fvc.autoSaveTimer invalidate];
            if (fvc.processor.autoSavedTransaction != nil) {
                IWTransaction *ast = (IWTransaction *)fvc.processor.autoSavedTransaction;
                if (ast.ColumnIndex != NSNotFound && ast.ColumnIndex != -1) {
                    [[IWInkworksService dbHelper] removeTransaction:ast clearPrepop:NO];
                }
            }
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
            if ([IWInkworksService getInstance].fromHistory ){
                if ([[IWInkworksService getInstance].currentHistoryScreen isEqualToString:HISTORY_CONTENT_NAME]){
                    [self performSegueWithIdentifier:@"AllHistorySegue" sender:historyButton];
                } else if ([[IWInkworksService getInstance].currentHistoryScreen isEqualToString:HISTORY_PARKED_CONTENT_NAME]){
                    [self performSegueWithIdentifier:@"ParkedHistorySegue" sender:historyParkedButton];
                } else if ([[IWInkworksService getInstance].currentHistoryScreen isEqualToString:HISTORY_SENDING_CONTENT_NAME]){
                    [self performSegueWithIdentifier:@"SendingHistorySegue" sender:historySendingButton];
                } else if ([[IWInkworksService getInstance].currentHistoryScreen isEqualToString:HISTORY_SENT_CONTENT_NAME]){
                    [self performSegueWithIdentifier:@"SentHistorySegue" sender:historySentButton];
                } else if ([[IWInkworksService getInstance].currentHistoryScreen isEqualToString:HISTORY_AUTOSAVED_CONTENT_NAME] ) {
                    [self performSegueWithIdentifier:@"HomeSegue" sender:historyAutosavedButton];
                }
            } else {
                if ([IWInkworksService getInstance].currentPrepopItem) {
                    [self performSegueWithIdentifier:@"PrepopSegue" sender:self];
                } else {
                    [self performSegueWithIdentifier:@"FormsListSegue" sender:self];
                }
            }

        }
    } else if ([alertView.title isEqualToString:@"Return to form list screen?"]) {
        if (buttonIndex == 0) {
            [IWDataChangeHandler getInstance].openedFromAutosave = NO;
            IWFormViewController *fvc = (IWFormViewController *)currentContent;
            [fvc.autoSaveTimer invalidate];
            if (fvc.processor.autoSavedTransaction != nil) {
                IWTransaction *ast = (IWTransaction *)fvc.processor.autoSavedTransaction;
                if (ast.ColumnIndex != NSNotFound && ast.ColumnIndex != -1) {
                    [[IWInkworksService dbHelper] removeTransaction:ast clearPrepop:NO];
                }
            }
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
            [self performSegueWithIdentifier:@"FormsListSegue" sender:self];
            
        }
    } else if ([alertView.title isEqualToString:@"Return to home screen?"]) {
        if (buttonIndex == 0) {
            IWFormViewController *fvc = (IWFormViewController *)currentContent;
            [fvc.autoSaveTimer invalidate];
            if (fvc.processor.autoSavedTransaction != nil) {
                IWTransaction *ast = (IWTransaction *)fvc.processor.autoSavedTransaction;
                if (ast.ColumnIndex != NSNotFound && ast.ColumnIndex != -1) {
                    [[IWInkworksService dbHelper] removeTransaction:ast clearPrepop:NO];
                }
            }
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
            [self performSegueWithIdentifier:@"HomeSegue" sender:self];
            
        }
    }
    
}

- (IBAction)formButtonPressed{
    if ([currentContent isKindOfClass:[IWFormViewController class]]){
        if ([IWDataChangeHandler getInstance].openedFromAutosave) {
            UIAlertView *alert = [[UIAlertView alloc] init];
            [alert setTitle:@"Return to form list screen?"];
            [alert setMessage:@"Are you sure you wish to discard this Auto-Saved form?"];
            [alert addButtonWithTitle:@"Yes"];
            [alert addButtonWithTitle:@"No"];
            [alert setCancelButtonIndex:1];
            [alert setDelegate: self];
            [alert show];
        } else if ([IWDataChangeHandler getInstance].dataChanged) {
            UIAlertView *alert = [[UIAlertView alloc] init];
            [alert setTitle:@"Return to form list screen?"];
            [alert setMessage:@"Any unsaved data will be lost. Are you sure?"];
            [alert addButtonWithTitle:@"Ok"];
            [alert addButtonWithTitle:@"Cancel"];
            [alert setCancelButtonIndex:1];
            [alert setDelegate: self];
            [alert show];
        } else {
            IWFormViewController *fvc = (IWFormViewController *)currentContent;
            [fvc.autoSaveTimer invalidate];
            if (fvc.processor.autoSavedTransaction != nil) {
                IWTransaction *ast = (IWTransaction *)fvc.processor.autoSavedTransaction;
                if (ast.ColumnIndex != NSNotFound && ast.ColumnIndex != -1) {
                    [[IWInkworksService dbHelper] removeTransaction:ast clearPrepop:NO];
                }
            }
            [self performSegueWithIdentifier:@"FormsListSegue" sender:self];
        }
    } else if ([currentContent isKindOfClass:[IWPrepopController class]]) {
        
        [self performSegueWithIdentifier:@"FormsListSegue" sender:self];
    }
}



- (IBAction)sendButtonPressed{
    [self.view endEditing:YES];
    [[UIApplication sharedApplication] resignFirstResponder];
    if ([currentContent isKindOfClass:[IWFormViewController class]]){
        
        BOOL showDialog = YES;
        
        [sendButton setSelected:YES];
        //here we will confirm form sending etc
        NSString *settingName = [NSString stringWithFormat:@"%@_%@", [IWInkworksService getInstance].loggedInUser, HIDE_SEND_NOTIFICATION];
        
        IWSavedSettings *confSave = [[IWInkworksService dbHelper] getSetting:settingName];
        if (confSave != nil && [confSave.SettingValue isEqualToString:@"TRUE"]){
            showDialog = NO;
        }
        if (showDialog) {
            vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"confirmationViewController"];
            [vc view];
            vc.view.backgroundColor = [UIColor colorWithRed:245.0f/255.0f green:189.0f/255.0f blue:71.0f/255.0f alpha:1.0f];
            controller = [[UIPopoverController alloc] initWithContentViewController:vc];
            [vc.okButton setAction:@selector(confirmSend)];
            [vc.okButton setTarget:self];
            [vc.cancelButton setAction:@selector(cancelSend)];
            [vc.cancelButton setTarget:self];
            NSString *text = @"This will complete and send the form.\n\nYou will no longer be able to edit this form, and the device will attempt to send it immediately.\nAre you sure this is what you want to do?";
            vc.detailsLabel.text = text;
            CGRect target = sendButton.frame;
            target.origin.x += sendButton.superview.frame.origin.x;
            target.origin.x += sendButton.superview.superview.frame.origin.x;
            target.origin.y += 50;
            controller.backgroundColor = [UIColor colorWithRed:245.0f/255.0f green:189.0f/255.0f blue:71.0f/255.0f alpha:1.0f];
            [controller presentPopoverFromRect:target inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        } else {
            IWFormViewController *fvc = (IWFormViewController *)currentContent;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [fvc sendForm];
                [sendButton setSelected:NO];
            });
        }
        
    }
}

- (void)showAutoSaveButton:(BOOL)show {
    [autoSaveButton setHidden:!show];
}


- (void) confirmSend {
    BOOL hideConfirm = vc.doNotShowButton.selected;
    
    NSString *hideConfirmString = hideConfirm ? @"TRUE" : @"FALSE";
    IWFormViewController *fvc = (IWFormViewController *)currentContent;
    [fvc sendForm];
    NSString *settingName = [NSString stringWithFormat:@"%@_%@", [IWInkworksService getInstance].loggedInUser, HIDE_SEND_NOTIFICATION];
    [[IWInkworksService dbHelper] saveSetting:settingName value:hideConfirmString];
    [controller dismissPopoverAnimated:YES];
    [sendButton setSelected:NO];
    
}
- (void) cancelSend {
    [controller dismissPopoverAnimated:YES];
    controller = nil;
    [sendButton setSelected:NO];
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [attachButton setSelected:NO];
}

- (void) takePhotoPressed {
    //[attachVC.takePhotoButton setSelected:YES];
    
    [attachPopController dismissPopoverAnimated:YES];
    [self performSegueWithIdentifier:@"takePhotoSegue" sender:self];
}
/*
 -(void) longPressBox:(UIGestureRecognizer *) sender {
 IWBarcodeScanViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"BarcodeScanner"];
 [vc view];
 [vc setDelegate:self];
 
 CGRect frame = vc.view.frame;
 frame.origin.x += 20;
 frame.origin.y += 20;
 frame.size.height -= 40;
 frame.size.height -= 40;
 vc.view.frame = frame;
 self.scannerOpen = true;
 vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
 [[[IWInkworksService getInstance] mainInstance] presentViewController:vc animated:YES completion:nil];
 
 
 //[presCon presentPopoverFromRect:CGRectMake(0, 0, 0, 0) inView:self.superview.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
 
 }
 */
- (void) attachImagePressed {
    [attachVC.attachImageButton setSelected:NO];
    [attachPopController dismissPopoverAnimated:NO];
    [attachButton setSelected:NO];
    attachImageVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"AttachImageViewController"];
    [attachImageVC view];
    CGRect frame = attachImageVC.view.frame;
    frame.origin.x += 20;
    frame.origin.y += 20;
    frame.size.height -= 40;
    frame.size.width -= 40;
    attachImageVC.view.frame = frame;
    attachImageVC.modalPresentationStyle = UIModalPresentationPopover;
    
    CGRect target = attachButton.frame;
    target.origin.x = 0;
    target.origin.y = 0;
//    target.origin.x += attachButton.superview.frame.origin.x;
//    target.origin.x += attachButton.superview.superview.frame.origin.x;
    //target.origin.y += 8;
    attachImageVC.popoverPresentationController.backgroundColor = [UIColor colorWithRed:245.0f/255.0f green:189.0f/255.0f blue:71.0f/255.0f alpha:1.0f];
    attachImageVC.popoverPresentationController.sourceRect = target;
    attachImageVC.popoverPresentationController.sourceView = attachButton;
    [self presentViewController:attachImageVC animated:YES completion:nil];
}

// deprecated 11/11/15
//- (void) attachImagePressed {
//    [attachVC.attachImageButton setSelected:NO];
//    [attachPopController dismissPopoverAnimated:NO];
//    [attachButton setSelected:NO];
//    [attachPopController setDelegate: self];
//    attachImageVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"AttachImageViewController"];
//    [attachImageVC view];
//    CGRect rect = attachImageVC.view.frame;
//    rect.origin.x += 20;
//    rect.origin.y += 20;
//    rect.size.width -= 40;
//    rect.size.height -= 40;
//    [attachImageVC.view setFrame:rect];
//    attachImagePopController = [[UIPopoverController alloc] initWithContentViewController:attachImageVC];
//    CGRect target = attachButton.frame;
//    target.origin.x += attachButton.superview.frame.origin.x;
//    target.origin.x += attachButton.superview.superview.frame.origin.x;
//    target.origin.y += 50;
//    attachImagePopController.backgroundColor = ;
//    [attachImagePopController presentPopoverFromRect:target inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:NO];
//    attachImageVC.popController = attachImagePopController;
//    
//}


- (IBAction)attachButtonPressed{
    [attachButton setSelected:YES];
    attachVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"attachViewController"];
    [attachVC view];
    attachVC.view.backgroundColor = [UIColor colorWithRed:245.0f/255.0f green:189.0f/255.0f blue:71.0f/255.0f alpha:1.0f];
    attachPopController = [[UIPopoverController alloc] initWithContentViewController:attachVC];
    [attachPopController setDelegate:self];
    attachPopController.backgroundColor = [UIColor colorWithRed:245.0f/255.0f green:189.0f/255.0f blue:71.0f/255.0f alpha:1.0f];
    [attachVC.takePhotoButton addTarget:self action:@selector(takePhotoPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [attachVC.attachImageButton addTarget:self action:@selector(attachImagePressed) forControlEvents:UIControlEventTouchUpInside];
    CGRect target = attachButton.frame;
    target.origin.x += attachButton.superview.frame.origin.x;
    target.origin.x += attachButton.superview.superview.frame.origin.x;
    target.origin.y += 50;
    [attachPopController presentPopoverFromRect:target inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
    
}

- (IBAction)parkButtonPressed{
    [self.view endEditing:YES];
    [[UIApplication sharedApplication] resignFirstResponder];
    if ([currentContent isKindOfClass:[IWFormViewController class]]){
        
        BOOL showDialog = YES;
        
        [parkButton setSelected:YES];
        //here we will confirm form sending etc
        NSString *settingName = [NSString stringWithFormat:@"%@_%@", [IWInkworksService getInstance].loggedInUser, HIDE_PARK_NOTIFICATION];
        
        IWSavedSettings *confSave = [[IWInkworksService dbHelper] getSetting:settingName];
        if (confSave != nil && [confSave.SettingValue isEqualToString:@"TRUE"]){
            showDialog = NO;
        }
        if (showDialog) {
            vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"confirmationViewController"];
            [vc view];
            vc.view.backgroundColor = [UIColor colorWithRed:245.0f/255.0f green:189.0f/255.0f blue:71.0f/255.0f alpha:1.0f];
            controller = [[UIPopoverController alloc] initWithContentViewController:vc];
            [vc.okButton setAction:@selector(confirmPark)];
            [vc.okButton setTarget:self];
            [vc.cancelButton setAction:@selector(cancelPark)];
            [vc.cancelButton setTarget:self];
            NSString *text = @"This will park (save) the form.\n\nYou will be able to return to this form later from the history section. Are you sure this is what you want to do?";
            vc.detailsLabel.text = text;
            CGRect target = parkButton.frame;
            target.origin.x += parkButton.superview.frame.origin.x;
            target.origin.x += parkButton.superview.superview.frame.origin.x;
            target.origin.y += 50;
            controller.backgroundColor = [UIColor colorWithRed:245.0f/255.0f green:189.0f/255.0f blue:71.0f/255.0f alpha:1.0f];
            [controller presentPopoverFromRect:target inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        } else {
            
            IWFormViewController *fvc = (IWFormViewController *)currentContent;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [fvc parkForm];
                [parkButton setSelected:NO];
            });
            
        }
    }
}
- (void) confirmPark {
    BOOL hideConfirm = vc.doNotShowButton.selected;
    
    NSString *hideConfirmString = hideConfirm ? @"TRUE" : @"FALSE";
    IWFormViewController *fvc = (IWFormViewController *)currentContent;
    [fvc parkForm];
    NSString *settingName = [NSString stringWithFormat:@"%@_%@", [IWInkworksService getInstance].loggedInUser, HIDE_PARK_NOTIFICATION];
    [[IWInkworksService dbHelper] saveSetting:settingName value:hideConfirmString];
    [controller dismissPopoverAnimated:YES];
    [parkButton setSelected:NO];
}
- (void) cancelPark {
    [controller dismissPopoverAnimated:YES];
    controller = nil;
    [parkButton setSelected:NO];
}


- (void) setConnectionIndicatorOn:(BOOL) connOn {
    if (self.inkworksButton != nil) {
        //selected = red
        //not selected = green
        [self.inkworksButton setSelected:!connOn];
    }
}

- (IBAction)prepopButtonPressed:(id)sender {
    if ([currentContent isKindOfClass:[IWFormsListController class]]) {
        IWFormsListController *flc = (IWFormsListController *)currentContent;
        if (flc.selectedRow != -1) {
            IWInkworksListItem *item = [((IWFormsListController *)currentContent) getSelectedListItem];
            [IWInkworksService getInstance].currentItemForPrepop = item;
            [self performSegueWithIdentifier:@"PrepopSegue" sender:self];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] init];
            [alert setTitle:@"Please select a form"];
            [alert setMessage:@"Please select a form to view pre-populated items"];
            [alert addButtonWithTitle:@"Ok"];
            [alert setCancelButtonIndex:0];
            [alert show];
        }
    } else if ([currentContent isKindOfClass:[IWPrepopController class]]){
        [((IWPrepopController *)currentContent) prepopButtonPressed];
    }
}

- (IBAction)clearButtonPressed{
    if ([currentContent isKindOfClass:[IWFormViewController class]]){
        [clearButton setSelected:YES];
        [clearButton setNeedsDisplay];
        IWFormViewController *fvc = (IWFormViewController *)currentContent;
        
        //here we will confirm form clearing etc
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [fvc clearForm];
            
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [clearButton setSelected:NO];
        });
    }
}

- (IBAction)refreshButtonPressed{
    if ([currentContent isKindOfClass:[IWFormsListController class]]){
        
        // BUGSEE INKWRX-3143 - App was crashing when the user hit the button really quickly. Added this
        // to ensure that this button only sends a refresh request once the first one is done.
        // Whilst the "selected" state is not visible on this UI, the app can still "see" it and so the button
        // will not send another request until the first one is returned.
        if (!refreshButton.selected) {
            [refreshButton setSelected:YES];
            IWFormsListController *flc = (IWFormsListController *)currentContent;
            if (flc.selectedRow != -1) {
                IWInkworksListItem *item = [flc.forms objectAtIndex:flc.selectedRow];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)),     dispatch_get_main_queue(), ^{
                    [flc refreshForm];
                    UIAlertView *alert = [[UIAlertView alloc] init];
                    [alert setTitle:@"Form refreshed"];
                    [alert setMessage:[NSString stringWithFormat:@"Form %@ has been refreshed", item.FormName]];
                    [alert addButtonWithTitle:@"Ok"];
                    [alert setCancelButtonIndex:0];
                    //[alert show];
                });
            } else {
                UIAlertView *alert = [[UIAlertView alloc] init];
                [alert setTitle:@"Please select a form"];
                [alert setMessage:@"Please select a form to manually refresh"];
                [alert addButtonWithTitle:@"Ok"];
                [alert setCancelButtonIndex:0];
                [alert show];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [refreshButton setSelected:NO];
                });
            }
        }
    }
}

- (void)setPrepopButtonActive:(BOOL)active {
    [prepopButton setSelected:active];
    [prepopButton2 setSelected:active];
}
@end
