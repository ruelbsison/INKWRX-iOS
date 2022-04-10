//
//  IWImageViewCell.h
//  Inkworks
//
//  Created by Jamie Duggan on 13/06/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IWAttachedPhoto;

@interface IWImageViewCell : UICollectionViewCell {
    __weak IBOutlet UIImageView *imageView;
    __weak IBOutlet UIImageView *imageTypeIcon;
    NSUUID *loadedImage;
    NSURL *loadedURL;
}

@property (weak) IBOutlet UIImageView *imageView;
@property (weak) IBOutlet UIImageView *imageTypeIcon;
@property NSUUID *loadedImage;
@property NSURL *loadedURL;

@end
