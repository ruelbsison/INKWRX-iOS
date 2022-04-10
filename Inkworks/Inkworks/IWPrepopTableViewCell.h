//
//  IWPrepopTableViewCell.h
//  Inkworks
//
//  Created by Paul Gowing on 25/01/2015.
//  Copyright (c) 2015 Destiny Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IWPrepopTableViewCell : UITableViewCell {
    __weak IBOutlet UILabel *formNameLabel;
    __weak IBOutlet UILabel *prepopIdLabel;
}
@property (weak) IBOutlet UILabel *formNameLabel;
@property (weak) IBOutlet UILabel *prepopIdLabel;
@end
