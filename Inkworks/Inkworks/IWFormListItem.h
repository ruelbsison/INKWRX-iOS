//
//  IWFormListItem.h
//  Inkworks
//
//  Created by Jamie Duggan on 15/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IWFormListItem : UICollectionViewCell {
    __weak IBOutlet UIImageView *preview;
    __weak IBOutlet UILabel *formNameLabel;
    __weak IBOutlet UIView *selectorView;
    __weak IBOutlet UISwitch *switchView;
    __weak IBOutlet UILabel *loadLabel;
    BOOL isRefreshing;
}

@property (weak) IBOutlet UIImageView *preview;
@property (weak) IBOutlet UILabel *formNameLabel;
@property (weak) IBOutlet UIView *selectorView;
@property (weak) IBOutlet UISwitch *switchView;
@property (weak) IBOutlet UILabel *loadLabel;
@property BOOL isRefreshing;

@end
