//
//  IWTakePhotoViewController.m
//  Inkworks
//
//  Created by Jamie Duggan on 09/06/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWTakePhotoViewController.h"
#import <math.h>
#import "IWMainController.h"
#import "IWDestinyConstants.h"
#import "IWInkworksService.h"
#import "Inkworks-Swift.h"
@import Photos;
#define DegreesToRadians(angle) ((angle) / 180.0 * M_PI)

@interface IWTakePhotoViewController ()

@end

@implementation IWTakePhotoViewController

@synthesize photoPreview, stillImageOutput, captureVideoPreviewLayer, formProcessor;
@synthesize takePhotoButton, goBackButton, previewImageView, haveImage, saveToGalleryLabel, saveToGallerySwitch;

- (void) initializeCamera {
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
	session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    
    CGRect frame = self.photoPreview.layer.bounds;
    [self.photoPreview setFrame: frame];
    
    captureVideoPreviewLayer.frame = photoPreview.layer.bounds;
	[self.photoPreview.layer addSublayer:captureVideoPreviewLayer];
    UIView *view = [self photoPreview];
    CALayer *viewLayer = [view layer];
    [viewLayer setMasksToBounds:YES];
    
    CGRect bounds = [view bounds];
    [captureVideoPreviewLayer setFrame:bounds];
    
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    for (AVCaptureDevice *device in devices) {
        
        NSLog(@"Device name: %@", [device localizedName]);
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
                NSLog(@"Device position : back");
                backCamera = device;
            }
            else {
                NSLog(@"Device position : front");
                frontCamera = device;
            }
        }
    }

    if (backCamera) {
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
        [session addInput:input];
    }
    
//    if (!frontCamera) {
//        NSError *error = nil;
//        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
//        if (!input) {
//            NSLog(@"ERROR: trying to open camera: %@", error);
//        }
//        [session addInput:input];
//    }
//    
//    if (frontCamera) {
//        NSError *error = nil;
//        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
//        if (!input) {
//            NSLog(@"ERROR: trying to open camera: %@", error);
//        }
//        [session addInput:input];
//    }
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    
    [session addOutput:stillImageOutput];
    
	[session startRunning];
}

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
    formProcessor = ((IWMainController *)[IWInkworksService getInstance].mainInstance).formProcessor;
    NSString *settingName = [NSString stringWithFormat:@"%@_%@", [IWInkworksService getInstance].loggedInUser, SAVE_TO_GALLERY];
    
    NSString *save = [[IWInkworksService dbHelper] getSetting:settingName].SettingValue;
    
    if ([save isEqualToString:@"true"]) {
        [self.saveToGallerySwitch setOn:YES animated:NO];
        
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        switch (status) {
            case PHAuthorizationStatusAuthorized:
                [[IWInkworksService dbHelper] saveSetting:settingName value:@"true"];
                break;
            case PHAuthorizationStatusDenied:
            case PHAuthorizationStatusRestricted:
                [[IWInkworksService dbHelper] saveSetting:settingName value:@"false"];
                [saveToGallerySwitch setOn:NO animated:NO];
                break;
            case PHAuthorizationStatusNotDetermined:
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus stat) {
                    switch (stat) {
                        case PHAuthorizationStatusAuthorized:
                            [[IWInkworksService dbHelper] saveSetting:settingName value:@"true"];
                            break;
                        case PHAuthorizationStatusDenied:
                        case PHAuthorizationStatusRestricted:
                            [[IWInkworksService dbHelper] saveSetting:settingName value:@"false"];
                            [saveToGallerySwitch setOn:NO animated:NO];
                            break;
                        case PHAuthorizationStatusNotDetermined:
                            [[IWInkworksService dbHelper] saveSetting:settingName value:@"false"];
                            [saveToGallerySwitch setOn:NO animated:NO];
                            break;
                    }
                }];
                break;
        }

    } else {
        [self.saveToGallerySwitch setOn:NO animated:NO];
    }
    
    [self initializeCamera];
    AVCaptureConnection *previewLayerConnection= captureVideoPreviewLayer.connection;
    
    UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if ([previewLayerConnection isVideoOrientationSupported])
    {
        switch (toInterfaceOrientation)
        {
            case UIInterfaceOrientationPortrait:
                [previewLayerConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
                break;
            case UIInterfaceOrientationLandscapeRight:
                [previewLayerConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight]; //home button on right. Refer to .h not doc
                break;
            case UIInterfaceOrientationLandscapeLeft:
                [previewLayerConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft]; //home button on left. Refer to .h not doc
                break;
            default:
                [previewLayerConnection setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown]; //for portrait upside down. Refer to .h not doc
                break;
        }
    }
    
}

-(void)saveLabelPressed {
    [self.saveToGallerySwitch setOn:!self.saveToGallerySwitch.on animated:YES];
}

- (IBAction)switchChanged:(UISwitch *) saveSwitch {
    NSString *settingName = [NSString stringWithFormat:@"%@_%@", [IWInkworksService getInstance].loggedInUser, SAVE_TO_GALLERY];
    if (saveSwitch.on) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        switch (status) {
            case PHAuthorizationStatusAuthorized:
                [[IWInkworksService dbHelper] saveSetting:settingName value:@"true"];
                break;
            case PHAuthorizationStatusDenied:
            case PHAuthorizationStatusRestricted:
                [[IWInkworksService dbHelper] saveSetting:settingName value:@"false"];
                [saveToGallerySwitch setOn:NO animated:NO];
                break;
            case PHAuthorizationStatusNotDetermined:
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus stat) {
                    switch (stat) {
                        case PHAuthorizationStatusAuthorized:
                            [[IWInkworksService dbHelper] saveSetting:settingName value:@"true"];
                            break;
                        case PHAuthorizationStatusDenied:
                        case PHAuthorizationStatusRestricted:
                            [[IWInkworksService dbHelper] saveSetting:settingName value:@"false"];
                            [saveToGallerySwitch setOn:NO animated:NO];
                            break;
                        case PHAuthorizationStatusNotDetermined:
                            [[IWInkworksService dbHelper] saveSetting:settingName value:@"false"];
                            [saveToGallerySwitch setOn:NO animated:NO];
                            break;
                    }
                }];
                break;
        }
    } else {
        [[IWInkworksService dbHelper] saveSetting:settingName value:@"false"];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    AVCaptureConnection *previewLayerConnection= captureVideoPreviewLayer.connection;
    captureVideoPreviewLayer.frame = photoPreview.layer.bounds;
    CGRect frame = self.photoPreview.layer.bounds;
    [self.photoPreview setFrame: frame];
    
    if ([previewLayerConnection isVideoOrientationSupported])
    {
        switch (toInterfaceOrientation)
        {
            case UIInterfaceOrientationPortrait:
                [previewLayerConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
                break;
            case UIInterfaceOrientationLandscapeRight:
                [previewLayerConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight]; //home button on right. Refer to .h not doc
                break;
            case UIInterfaceOrientationLandscapeLeft:
                [previewLayerConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft]; //home button on left. Refer to .h not doc
                break;
            default:
                [previewLayerConnection setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown]; //for portrait upside down. Refer to .h not doc
                break;
        }
    }
    
}

- (void) viewWillAppear:(BOOL)animated{
    captureVideoPreviewLayer.frame = photoPreview.layer.bounds;
    CGRect frame = self.photoPreview.layer.bounds;
    [self.photoPreview setFrame: frame];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void) viewDidAppear:(BOOL)animated {
    
    captureVideoPreviewLayer.frame = photoPreview.layer.bounds;
    CGRect frame = self.photoPreview.layer.bounds;
    [self.photoPreview setFrame: frame];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(saveLabelPressed)];
    while (self.saveToGalleryLabel.gestureRecognizers.count > 0) {
        [self.saveToGalleryLabel removeGestureRecognizer:[self.saveToGalleryLabel.gestureRecognizers firstObject]];
    }
    [self.saveToGalleryLabel addGestureRecognizer:tap];
}

- (void)viewWillDisappear:(BOOL)animated {
    [IWInkworksService getInstance].embeddingView = nil;
}

- (void) orientationChanged {
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        CGRect frame = self.photoPreview.layer.bounds;
//        [self.photoPreview setFrame: frame];
//        
//        captureVideoPreviewLayer.frame = photoPreview.layer.bounds;
//    });
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect frame = self.photoPreview.layer.bounds;
        [self.photoPreview setFrame: frame];
        
        captureVideoPreviewLayer.frame = photoPreview.layer.bounds;
    });
}

- (void)takePhoto {
    [self capImage];
}

- (void) capImage { //method to capture image from AVCaptureSession video feed
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in stillImageOutput.connections) {
        
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        
        if (videoConnection) {
            break;
        }
    }
    
    NSLog(@"about to request a capture from: %@", stillImageOutput);
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        
        if (imageSampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            [self processImage:[UIImage imageWithData:imageData]];
        }
    }];
}

- (void) processImage:(UIImage *)image { //process captured image, crop, resize and rotate
    haveImage = YES;
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) { //Device is ipad
        // Resize image
        UIGraphicsBeginImageContext(CGSizeMake(768, 1022));
        [image drawInRect: CGRectMake(0, 0, 768, 1022)];
        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGRect cropRect = CGRectMake(0, 0, 768, 1022);
        CGImageRef imageRef = CGImageCreateWithImageInRect([smallImage CGImage], cropRect);
        //or use the UIImage wherever you like
        
        [previewImageView setImage:[UIImage imageWithCGImage:imageRef]];
        
        CGImageRelease(imageRef);
        
    }else{ //Device is iphone
        // Resize image
        UIGraphicsBeginImageContext(CGSizeMake(320, 426));
        [image drawInRect: CGRectMake(0, 0, 320, 426)];
        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGRect cropRect = CGRectMake(0, 55, 320, 320);
        CGImageRef imageRef = CGImageCreateWithImageInRect([smallImage CGImage], cropRect);
        
        [previewImageView setImage:[UIImage imageWithCGImage:imageRef]];
        
        CGImageRelease(imageRef);
    }
    UIImage *rotatedImage = previewImageView.image;
    //adjust image orientation based on device orientation
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) {
        NSLog(@"landscape left image");
        
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.5];
        
        previewImageView.transform = CGAffineTransformMakeRotation(DegreesToRadians(-90));
        rotatedImage = [self rotate:previewImageView.image to:UIImageOrientationLeft];
        [UIView commitAnimations];
        
    }
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        NSLog(@"landscape right");
        
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.5];
        previewImageView.transform = CGAffineTransformMakeRotation(DegreesToRadians(90));
        rotatedImage = [self rotateImage:previewImageView.image byDegrees:90];
        [UIView commitAnimations];
        
    }
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
        NSLog(@"upside down");
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.5];
        previewImageView.transform = CGAffineTransformMakeRotation(DegreesToRadians(180));
        
        rotatedImage = [self rotate:previewImageView.image to:UIImageOrientationDown];
        [UIView commitAnimations];
        
    }
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait) {
        NSLog(@"upside upright");
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.5];
        previewImageView.transform = CGAffineTransformMakeRotation(DegreesToRadians(0));
        [UIView commitAnimations];
    }
    
    
    
    NSData *imgData = UIImageJPEGRepresentation(rotatedImage, 100);
   
    [formProcessor savePhoto:imgData];
    if (saveToGallerySwitch.on) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromImage:rotatedImage];
        } completionHandler:^(BOOL success, NSError *error) {
            if (success) {
                
            } else {
                
            }
        }];
    }
    if ([IWInkworksService getInstance].embeddingView != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:true completion:nil];
        });
        
    }
}

- (UIImage *)rotateImage:(UIImage*)image byDegrees:(CGFloat)degrees
{
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,image.size.width, image.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    
    CGContextTranslateCTM(bitmap, rotatedSize.width, rotatedSize.height);
    
    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
    
    
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-image.size.width, -image.size.height, image.size.width, image.size.height), [image CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

static CGRect swapWidthAndHeight(CGRect rect)
{
    CGFloat  swap = rect.size.width;
    
    rect.size.width  = rect.size.height;
    rect.size.height = swap;
    
    return rect;
}

-(UIImage*)rotate:(UIImage *)image to:(UIImageOrientation)orient
{
    CGRect             bnds = CGRectZero;
    UIImage*           copy = nil;
    CGContextRef       ctxt = nil;
    CGImageRef         imag = image.CGImage;
    CGRect             rect = CGRectZero;
    CGAffineTransform  tran = CGAffineTransformIdentity;
    
    rect.size.width  = CGImageGetWidth(imag);
    rect.size.height = CGImageGetHeight(imag);
    
    bnds = rect;
    
    switch (orient)
    {
        case UIImageOrientationUp:
            // would get you an exact copy of the original
            assert(false);
            return nil;
            
        case UIImageOrientationUpMirrored:
            tran = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown:
            tran = CGAffineTransformMakeTranslation(rect.size.width,
                                                    rect.size.height);
            tran = CGAffineTransformRotate(tran, M_PI);
            break;
            
        case UIImageOrientationDownMirrored:
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.height);
            tran = CGAffineTransformScale(tran, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeft:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.width);
            tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeftMirrored:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(rect.size.height,
                                                    rect.size.width);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRight:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
            tran = CGAffineTransformRotate(tran, M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeScale(-1.0, 1.0);
            tran = CGAffineTransformRotate(tran, M_PI / 2.0);
            break;
            
        default:
            // orientation value supplied is invalid
            assert(false);
            return nil;
    }
    
    UIGraphicsBeginImageContext(bnds.size);
    ctxt = UIGraphicsGetCurrentContext();
    
    switch (orient)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextScaleCTM(ctxt, -1.0, 1.0);
            CGContextTranslateCTM(ctxt, -rect.size.height, 0.0);
            break;
            
        default:
            CGContextScaleCTM(ctxt, 1.0, -1.0);
            CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
            break;
    }
    
    CGContextConcatCTM(ctxt, tran);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, imag);
    
    copy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return copy;
}

- (void)viewDidLayoutSubviews {
    captureVideoPreviewLayer.frame = photoPreview.layer.bounds;
    CGRect frame = self.photoPreview.layer.bounds;
    [self.photoPreview setFrame: frame];
}
- (void)viewWillLayoutSubviews {
    captureVideoPreviewLayer.frame = photoPreview.layer.bounds;
    CGRect frame = self.photoPreview.layer.bounds;
    [self.photoPreview setFrame: frame];
}

- (void)goBack {
    [goBackButton setSelected:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^(){
            [goBackButton setSelected:NO];
        }];
    });
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

@end
