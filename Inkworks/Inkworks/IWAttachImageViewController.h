//
//  IWAttachImageViewController.h
//  Inkworks
//
//  Created by Jamie Duggan on 13/06/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//
#import "IWInkworksService.h"
#import <UIKit/UIKit.h>

@interface IWAttachImageViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate> {
    __weak IBOutlet UICollectionView *galleryView;
    NSMutableArray *galleryImages;
    __weak NSMutableArray *formPhotos;
    
    __weak IBOutlet UIButton *backButton;
    
    __weak NSMutableArray *attachedGalleryImages;
    __weak NSMutableArray *attachedFormPhotos;
    
    __weak UIPopoverController *popController;
    
    __weak IBOutlet UILabel *headerLabel;
    NSTimer *updateTimer;
    long formId;
}

@property (weak) IBOutlet UICollectionView *galleryView;
@property NSMutableArray *galleryImages;
@property (weak) NSMutableArray *formPhotos;
@property (weak) UIPopoverController *popController;
@property (weak) IBOutlet UIButton *backButton;
@property (weak) IBOutlet UILabel *headerLabel;
@property NSTimer *updateTimer;

@property (weak) NSMutableArray *attachedGalleryImages;
@property (weak) NSMutableArray *attachedFormPhotos;
@property long formId;

@end
