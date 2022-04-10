//
//  IWConfirmationViewController.m
//  Inkworks
//
//  Created by Jamie Duggan on 23/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWConfirmationViewController.h"

@interface IWConfirmationViewController ()

@end

@implementation IWConfirmationViewController

@synthesize doNotShowButton, detailsLabel, okButton, cancelButton;

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)doNotShowPressed {
    [doNotShowButton setSelected:!doNotShowButton.selected];
}
@end