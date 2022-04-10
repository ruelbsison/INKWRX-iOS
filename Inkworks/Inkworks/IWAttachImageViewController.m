//
//  IWAttachImageViewController.m
//  Inkworks
//
//  Created by Jamie Duggan on 13/06/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWAttachImageViewController.h"
#import "IWGalleryHeader.h"
#import "IWImageViewCell.h"
#import "IWFileSystem.h"
//#import "IWInkworksListItem.h"
#import "IWFormRenderer.h"
#import "IWFormProcessor.h"
#import "Inkworks-Swift.h"
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>

@implementation IWAttachImageViewController

@synthesize popController, backButton, galleryView, galleryImages, formPhotos, attachedGalleryImages,attachedFormPhotos, formId, headerLabel, updateTimer;

NSArray *imageTypeImages;
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
    imgCache = [NSMutableDictionary dictionary];
    // Do any additional setup after loading the view.

    
}

- (IBAction) backButtonPressed {
    [popController dismissPopoverAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {

   
    
    imageTypeImages =
@[
  @[
      [UIImage imageNamed:@"bar_icon_camera.png"],
      [UIImage imageNamed:@"bar_icon_attach_active.png"]
    ],
  @[
      [UIImage imageNamed:@"bar_icon_gallery.png"],
      [UIImage imageNamed:@"bar_icon_attach_active.png"]
    ]
];
    
    galleryImages = [NSMutableArray array];
    
    //[IWInkworksService getInstance].galleryImages;
    formId = [IWInkworksService getInstance].currentViewedForm.FormId;
    formPhotos = [IWInkworksService getInstance].currentProcessor.formPhotos;
    attachedFormPhotos = [IWInkworksService getInstance].currentProcessor.attachedFormPhotos;
    attachedGalleryImages = [IWInkworksService getInstance].currentProcessor.attachedGalleryImages;
    [super viewWillAppear:animated];
    
    
    
}

- (void) updateHeader{
    [headerLabel setText:[NSString stringWithFormat:@"Attach Images (%d item%@ attached)", attachedFormPhotos.count + attachedGalleryImages.count, (attachedFormPhotos.count + attachedGalleryImages.count == 1) ? @"" : @"s"]];
}

- (void) refreshGallery:(NSTimer *) timer {
    dispatch_async(dispatch_get_main_queue(), ^ {
        NSLog(@"image timer");
        [galleryView reloadData];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSMutableArray* assetURLDictionaries = [[NSMutableArray alloc] init];
    NSMutableArray *assetsp = [[NSMutableArray alloc] init];
    NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    void (^assetEnumerator)( ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if(result != nil) {
            if([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
                
                NSLog(@"result is:%@",result);
                NSLog(@"asset URLDictionary is:%@",assetURLDictionaries);
                NSURL *url= (NSURL*) [[result defaultRepresentation]url];
                
                [library assetForURL:url
                         resultBlock:^(ALAsset *asset) {
                             @try {
                             if (asset && assetsp) {
                                 [assetsp addObject:asset];
                                 [galleryImages addObject:[asset.defaultRepresentation url] ];
                             
                             
                             
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     if (updateTimer != nil) {
                                         [updateTimer invalidate];
                                     }
                                     updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(refreshGallery:) userInfo:nil repeats:NO];
                                     
                                 });
                             }
                             }
                             @catch (NSException *ex){
                                 NSLog(@"error here");
                             }
                         }
                        failureBlock:^(NSError *error){ NSLog(@"test:Fail"); } ];
            }
        }
    };
    
    
    void (^ assetGroupEnumerator) ( ALAssetsGroup *, BOOL *)= ^(ALAssetsGroup *group, BOOL *stop){
        NSLog(@"hi");
        if(group != nil) {
            [group enumerateAssetsUsingBlock:assetEnumerator];
            [assetGroups addObject:group];
            
            NSLog(@"Number of assets in group :%ld",(long)[group numberOfAssets]);
            for (ALAsset *asset in assetsp) {
                NSLog(@"%@", asset.description);
            }
        }
    };
    
    
    [library enumerateGroupsWithTypes:ALAssetsGroupAll
                           usingBlock:assetGroupEnumerator
                         failureBlock:^(NSError *error) {NSLog(@"A problem occurred");}];
    
    
    [self updateHeader];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

NSMutableDictionary *imgCache;

#pragma mark Collection View

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        //gallery image
        NSURL *url = [galleryImages objectAtIndex:indexPath.row];
        BOOL isSelected = [attachedGalleryImages containsObject:url];
        if (isSelected) {
            [attachedGalleryImages removeObject:url];
            
        } else {
            [attachedGalleryImages addObject:url];
        }
        
        [self.galleryView reloadItemsAtIndexPaths:@[indexPath]];
        [self updateHeader];
    } else {
        //form photo
        NSUUID *uuid = [formPhotos objectAtIndex:indexPath.row];
        BOOL isSelected = [attachedFormPhotos containsObject:uuid];
        if (isSelected) {
            [attachedFormPhotos removeObject:uuid];
        } else {
            [attachedFormPhotos addObject:uuid];
        }
        
        [self.galleryView reloadItemsAtIndexPaths:@[indexPath]];
        
        [self updateHeader];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [formPhotos count];
        case 1:
            return [galleryImages count];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    __block UIImage *image = nil;
    NSString *pathToImage = nil;
    
    if (indexPath.section == 1) {
        NSURL *url = [galleryImages objectAtIndex:indexPath.row];
        ALAssetsLibrary *al = [[ALAssetsLibrary alloc] init];
        __weak IWImageViewCell *cell = (IWImageViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
        
        BOOL isSelected = [attachedGalleryImages containsObject:url];
        
        [cell.imageTypeIcon setImage:[(NSArray *)[imageTypeImages objectAtIndex:1] objectAtIndex:isSelected ? 1 : 0]];
        [cell.imageTypeIcon setAlpha:isSelected ? 1 : 0.5];
        if ([imgCache objectForKey:[NSValue valueWithNonretainedObject:url]]){
            cell.loadedURL = url;
            cell.loadedImage = nil;
            [cell.imageView setImage:[imgCache objectForKey:[NSValue valueWithNonretainedObject:url]]];
        }
        else {
            [al assetForURL:url resultBlock:^(ALAsset *asset) {
                @try {
                    if (asset) {
                        image = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
                        [cell.imageView setImage:image];
                        [imgCache setObject:image forKey:[NSValue valueWithNonretainedObject:url]];
                        cell.loadedURL = url;
                        cell.loadedImage = nil;
                    }
                } @catch (NSException *ex) {
                    NSLog(@"Error here 2");
                }
            } failureBlock:^(NSError *error) {
                NSLog(@"error");
            }];
        }
        return cell;
    } else {
        pathToImage = [IWFileSystem getFormPhotoPathWithId:formId andUUID:[formPhotos objectAtIndex:indexPath.row]];
        
        BOOL isSelected = [attachedFormPhotos containsObject:[formPhotos objectAtIndex:indexPath.row]];
        
        
        
        IWImageViewCell *cell = (IWImageViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
        [cell.imageTypeIcon setImage:[(NSArray *)[imageTypeImages objectAtIndex:0] objectAtIndex:isSelected ? 1 : 0]];
        if ([imgCache objectForKey:[NSValue valueWithNonretainedObject:pathToImage]]){
            [cell.imageView setImage:[imgCache objectForKey:[NSValue valueWithNonretainedObject:pathToImage]]];
            cell.loadedImage = [formPhotos objectAtIndex:indexPath.row];
            cell.loadedURL = nil;
        } else  {
            
            image = [UIImage imageWithContentsOfFile:pathToImage];
            [cell.imageView setImage:image];
            cell.loadedImage = [formPhotos objectAtIndex:indexPath.row];
            cell.loadedURL = nil;
            [imgCache setObject:image forKey:[NSValue valueWithNonretainedObject:pathToImage]];
        }
        [cell.imageTypeIcon setAlpha:isSelected ? 1 : 0.5];
        
        return cell;
    }
    
    
    return nil;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]){
        IWGalleryHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"galleryImagesHeader" forIndexPath:indexPath];
        switch (indexPath.section) {
            case 0:
                [header.headerLabel setText:@"Form Photos"];
                break;
            case 1:
                [header.headerLabel setText:@"Gallery Images"];
                break;
        }
        return header;
    }
    return nil;
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
