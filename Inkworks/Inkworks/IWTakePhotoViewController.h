//
//  IWTakePhotoViewController.h
//  Inkworks
//
//  Created by Jamie Duggan on 09/06/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "IWFormProcessor.h"

@interface IWTakePhotoViewController : UIViewController {
    __weak IBOutlet UIView *photoPreview;
    __weak IBOutlet UIButton *takePhotoButton;
    __weak IBOutlet UIButton *goBackButton;
    __weak IBOutlet UIImageView *previewImageView;
    __weak IBOutlet UISwitch *saveToGallerySwitch;
    __weak IBOutlet UILabel *saveToGalleryLabel;
    
    AVCaptureStillImageOutput *stillImageOutput;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
    
    BOOL haveImage;
    IWFormProcessor *formProcessor;
}

@property (weak) IBOutlet UIView *photoPreview;
@property AVCaptureStillImageOutput *stillImageOutput;
@property AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (weak) IBOutlet UIButton *takePhotoButton;
@property (weak) IBOutlet UIButton *goBackButton;
@property (weak) IBOutlet UIImageView *previewImageView;
@property (weak) IBOutlet UISwitch *saveToGallerySwitch;
@property (weak) IBOutlet UILabel *saveToGalleryLabel;
@property BOOL haveImage;

@property IWFormProcessor *formProcessor;

- (IBAction)takePhoto;
- (IBAction)goBack;
- (void)saveLabelPressed;
- (IBAction)switchChanged:(UISwitch *) saveSwitch;

@end
