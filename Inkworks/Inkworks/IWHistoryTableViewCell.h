//
//  IWHistoryTableViewCell.h
//  Inkworks
//
//  Created by Jamie Duggan on 14/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IWHistoryTableViewCell : UITableViewCell{
    __weak IBOutlet UILabel *formNameLabel;
    __weak IBOutlet UILabel *formStartedLabel;
    __weak IBOutlet UILabel *formSavedLabel;
    __weak IBOutlet UILabel *formSentLabel;
    __weak IBOutlet UILabel *formStatusLabel;
    __weak IBOutlet UIView *statusIconView;
    __weak IBOutlet UIImageView *statusIcon;
    __weak IBOutlet UILabel *formPrepopNameLabel;
}

@property (weak) IBOutlet UILabel *formNameLabel;
@property (weak) IBOutlet UILabel *formStartedLabel;
@property (weak) IBOutlet UILabel *formSavedLabel;
@property (weak) IBOutlet UILabel *formSentLabel;
@property (weak) IBOutlet UILabel *formStatusLabel;
@property (weak) IBOutlet UIView *statusIconView;
@property (weak) IBOutlet UILabel *formPrepopNameLabel;
@property (weak) IBOutlet UIImageView *statusIcon;

@end
