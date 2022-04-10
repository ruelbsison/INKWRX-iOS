//
//  IWFormProcessor.h
//  Inkworks
//
//  Created by Jamie Duggan on 20/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#define EXT_DATE_FORMAT @"yyyy-MM-dd'T'HH:mm:ss.SSS"

#import <Foundation/Foundation.h>

@class IWInkworksListItem;
@class IWTransaction;
@class IWFormDescriptor;
@class IWFormRenderer;
@class IWInkworksDatabaseHelper;
@class PHAsset;

@interface IWFormProcessor : NSObject {
    IWFormDescriptor *formDescriptor;
    IWInkworksListItem *listItem;
    IWTransaction *originalTransaction;
    
    NSMutableDictionary *allElementsIndexed;
    NSDate *startDate;
    UIView *formCanvas;
    NSNumber *currentPageToSave;
    NSMutableDictionary *pageStrings;
    
    NSMutableArray *formPhotos;
    NSMutableArray *attachedGalleryImages;
    NSMutableArray *attachedFormPhotos;
    
    NSMutableDictionary *dynamicFields;
    IWFormRenderer *renderer;
    NSMutableArray *embeddedPhotos;
    
    IWTransaction *autoSavedTransaction;
}

@property IWFormDescriptor *formDescriptor;
@property IWInkworksListItem *listItem;
@property IWTransaction *originalTransaction;

@property NSMutableDictionary *allElementsIndexed;
@property NSDate *startDate;
@property UIView *formCanvas;
@property NSNumber *currentPageToSave;

@property NSMutableDictionary *pageStrings;

@property NSMutableDictionary *dynamicFields;
@property NSMutableArray *formPhotos;

@property IWFormRenderer *renderer;

@property NSMutableArray *attachedGalleryImages;
@property NSMutableArray *attachedFormPhotos;
@property NSMutableArray *embeddedPhotos;
@property IWTransaction *autoSavedTransaction;

- (void) loadParkedImages;
- (void) loadParkedImages:(long long) columnIndex;
- (void) attachFormPhoto: (NSUUID *)uuid;
//- (void) attachGalleryImage: (NSURL *) url;
- (void) attachGalleryImage: (PHAsset *) asset;

- (void) removeAttachedFormPhoto: (NSUUID *) uuid;
- (void) removeAttachedGalleryImage: (PHAsset *) asset;

- (id) initWithDescriptor: (IWFormDescriptor *)desc listItem: (IWInkworksListItem *)item canvas: (UIView *)canvas transaction: (IWTransaction *) transaction startDate: (NSDate *)date;
- (BOOL)saveFormForSending:(BOOL)sending onPageNumber:(NSNumber *)page dictionary:(NSDictionary *)fields radios:(NSDictionary *)radios renderer:(IWFormRenderer *)rend autoSave:(BOOL) autoSave;
- (BOOL) saveFormForSending: (BOOL) sending onPageNumber: (NSNumber *) page dictionary: (NSDictionary *) fields radios: (NSDictionary *) radios renderer:(IWFormRenderer *)rend;

- (void) savePage: (NSNumber *) page forSending: (BOOL)sending fields: (NSDictionary *) fields radios: (NSDictionary *) radios  renderer:(IWFormRenderer *)rend;

- (void) loadPageDataFromParked: (NSString *) procFormData strokes: (NSString *) strokeFormData;

- (void) savePhoto: (NSData *) data;

@end
