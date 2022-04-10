//
//  IWFormProcessor.m
//  Inkworks
//
//  Created by Jamie Duggan on 20/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWFormProcessor.h"
#import "IWPageDescriptor.h"
#import "IWFieldDescriptor.h"

#import "IWIsoFieldDescriptor.h"
#import "IWDateTimeFieldDescriptor.h"
#import "IWDecimalFieldDescriptor.h"
#import "IWNoteFieldDescriptor.h"
#import "IWTickedFieldDescriptor.h"
#import "IWDropdownDescriptor.h"
#import "IWRectElement.h"

#import "IWTickedFieldDescriptor.h"

#import "IWDrawingFieldDescriptor.h"
#import "IWRadioButtonDescriptor.h"
#import "IWTickBoxDescriptor.h"

#import "IWIsoFieldView.h"
#import "IWTickBox.h"
#import "IWRadioButton.h"
#import "IWRadioButtonManager.h"
#import "IWDropDown.h"
#import "IWDrawingField.h"
#import "IWCustomPath.h"
#import "IWNotesView.h"
#import "IWDecimalFieldView.h"
#import "IWDateTimeFieldView.h"

#import "IWInkworksService.h"
#import "IWPageServer.h"
#import "IWDynamicPanel.h"

#import "IWFormDescriptor.h"
#import "IWFormRenderer.h"
#import "IWFileSystem.h"
#import "Inkworks-Swift.h"

@import Photos;

@implementation IWFormProcessor


@synthesize formCanvas, formDescriptor, listItem, originalTransaction, allElementsIndexed, startDate, currentPageToSave, pageStrings, formPhotos, attachedFormPhotos, attachedGalleryImages, renderer, dynamicFields, embeddedPhotos, autoSavedTransaction;

- (id)initWithDescriptor:(IWFormDescriptor *)desc listItem:(IWInkworksListItem *)item canvas:(UIView *)canvas transaction:(IWTransaction *)transaction startDate:(NSDate *)date {
    self = [super init];
    
    if (self) {
        self.formDescriptor = desc;
        self.listItem = item;
        self.formCanvas = canvas;
        self.originalTransaction = transaction;
        self.startDate = date;
        self.formPhotos = [NSMutableArray array];
        self.attachedGalleryImages = [NSMutableArray array];
        self.attachedFormPhotos = [NSMutableArray array];
        self.pageStrings = [NSMutableDictionary dictionary];
        self.dynamicFields = [NSMutableDictionary dictionary];
        self.embeddedPhotos = [NSMutableArray array];
        [self loadParkedImages];
        [self loadDynamicFields];
        
    }
    
    return self;
}

#pragma mark Loading methods

- (void) loadPageDataFromParked: (NSString *) procFormData strokes: (NSString *) strokeFormData {
    //Am I going mad or is this possible...?
    if (procFormData == nil || strokeFormData == nil) return;
    
    procFormData = [procFormData stringByReplacingOccurrencesOfString:@"§§§-§§§" withString:@"§§§--§§§"];
    
    if ([procFormData rangeOfString:@"§-§"].location == NSNotFound) {
        procFormData = [procFormData stringByReplacingOccurrencesOfString:@"<page" withString:@"§-§<page"];
        procFormData = [procFormData stringByReplacingOccurrencesOfString:@"</form" withString:@"§-§</form"];
        
        strokeFormData = [strokeFormData stringByReplacingOccurrencesOfString:@"<page " withString:@"§-§<page "];
        strokeFormData = [strokeFormData stringByReplacingOccurrencesOfString:@"</pages" withString:@"§-§</pages"];
    }
    NSMutableArray *procComp = [[procFormData componentsSeparatedByString:@"§-§"] mutableCopy];
    NSMutableArray *strokeComp = [[strokeFormData componentsSeparatedByString:@"§-§"] mutableCopy];
    if ([procComp count] < 3 || [strokeComp count] < 3) return;
    [procComp removeObjectAtIndex:0];
    [procComp removeObjectAtIndex:[procComp count] - 1];
    [strokeComp removeObjectAtIndex:0];
    [strokeComp removeObjectAtIndex:[strokeComp count] - 1];
    
    for (int i = 0; i < [procComp count]; i++){
        NSNumber *pageNum = [NSNumber numberWithInt:i];
        NSString *procPage = [procComp objectAtIndex:i];
        NSString *strokePage = @"";
        if (strokeComp != nil) {
            if (strokeComp.count > i){
                strokePage = [strokeComp objectAtIndex:i];
            }
        }
        
        NSString *searchString = @"<stroke";
        
        int iStrokes = ([strokePage length] - [[strokePage stringByReplacingOccurrencesOfString:searchString withString:@""] length]) / [searchString length];
        
        NSNumber *numStrokes = [NSNumber numberWithInt:iStrokes];
        
        NSDictionary *pageInfo = @{@"proc":procPage, @"strokes": strokePage, @"num": numStrokes};
        if (pageStrings == nil) {
            pageStrings = [NSMutableDictionary dictionary];
        }
        [pageStrings setObject:pageInfo forKey:pageNum];
        
    }
    
}

- (void) loadParkedImages {
    long long columnIndex = autoSavedTransaction != nil ? autoSavedTransaction.ColumnIndex : originalTransaction.ColumnIndex;
    [self loadParkedImages:columnIndex];
}

- (void) loadParkedImages:(long long) columnIndex{
    NSMutableArray *list = [[[IWInkworksService dbHelper] getPhotos:columnIndex] mutableCopy];
    if (list.count == 0) return;
    self.formPhotos = [NSMutableArray array];
    self.attachedGalleryImages = [NSMutableArray array];
    self.attachedFormPhotos = [NSMutableArray array];
    
    int phIndex = -1;
    for (IWAttachedPhoto *photo in list) {
        phIndex++;
        if ([photo.ImageType isEqualToString:@"FORM_PHOTO"]) {
            NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:photo.ImageUUID];
            if (![formPhotos containsObject:uuid])
                [formPhotos addObject:uuid];
            if (![attachedFormPhotos containsObject:uuid])
                [attachedFormPhotos addObject:uuid];
            NSString *uuidString = [NSString stringWithFormat:@"{UUID}%@{/UUID}", photo.ImageUUID];
            NSString *filename = [NSString stringWithFormat:@"camera_%d.jpg", phIndex];
            for (NSDictionary *pageInfoKey in ((NSMutableDictionary *)pageStrings.mutableCopy).keyEnumerator) {
                NSMutableDictionary *pageInfos = [pageStrings[pageInfoKey] mutableCopy];
                pageInfos[@"proc"] = [pageInfos[@"proc"] stringByReplacingOccurrencesOfString:filename withString:uuidString];
                [pageStrings setObject:pageInfos forKey:pageInfoKey];
            }
        } else {
            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
            if(status != PHAuthorizationStatusAuthorized) {
                continue;
            }
            
            PHAsset *asset = nil;
            PHFetchOptions *phOptions = [[PHFetchOptions alloc] init];
            phOptions.includeAssetSourceTypes = PHAssetSourceTypeCloudShared | PHAssetSourceTypeUserLibrary;
            
            if ([photo.ImagePath rangeOfString:@"{PH}"].location == NSNotFound) {
                NSURL *url = [NSURL URLWithString:photo.ImagePath];
                
                PHFetchResult *fetch = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:phOptions];
                if (fetch.count > 0) {
                    asset = [fetch firstObject];
                }
                if (asset) {
                    if (![attachedGalleryImages containsObject:asset]){
                        [attachedGalleryImages addObject:asset];
                    }
                }
            } else {
                
                NSString *localId = [photo.ImagePath stringByReplacingOccurrencesOfString:@"{PH}" withString:@""];
                PHFetchResult *fetch = [PHAsset fetchAssetsWithLocalIdentifiers:@[localId] options:phOptions];
                if (fetch.count > 0) {
                    asset = [fetch firstObject];
                }
                if (asset) {
                    NSString *uuidString = [NSString stringWithFormat:@"%@{/PH}", photo.ImagePath];
                    NSString *filename = [NSString stringWithFormat:@"gallery_%d.jpg", phIndex];
                    for (NSDictionary *pageInfoKey in ((NSMutableDictionary *)pageStrings.mutableCopy).keyEnumerator) {
                        NSMutableDictionary *pageInfos = [pageStrings[pageInfoKey] mutableCopy];
                        pageInfos[@"proc"] = [pageInfos[@"proc"] stringByReplacingOccurrencesOfString:filename withString:uuidString];
                        [pageStrings setObject:pageInfos forKey:pageInfoKey];
                    }
                    
                    if (![attachedGalleryImages containsObject:asset]) {
                        [attachedGalleryImages addObject:asset];
                    }
                }
            }
        }
    }
}

- (void) loadDynamicFields {
    NSMutableArray *list = [[[IWInkworksService dbHelper] getDynamicFields:originalTransaction.ColumnIndex]  mutableCopy];
    if (list.count == 0) return;
    for (IWDynamicField *dyn in list) {
        [dynamicFields setObject:dyn forKey:dyn.FieldId];
    }
}



#pragma mark Page Saving Methods

//normal fields
- (int) handleFieldDescriptor:(UIView *) fld fieldName:(NSString *)fldName procString:(NSMutableString *)procPageString strokeString:(NSMutableString *)strokesPageString forSending: (BOOL) sending currentNumStrokes:(int) numStrokesForPage{
    if ([fld isKindOfClass:[IWTabletImageView class]]) {
        IWTabletImageView *tiField = (IWTabletImageView *)fld;
        NSString *fieldVal = @"";
        if (tiField.attachedUUID != nil) {
            fieldVal = [NSString stringWithFormat:@"{UUID}%@{/UUID}", [tiField.attachedUUID UUIDString]];
            [procPageString appendString:[self getProcFieldTag:fldName value:fieldVal isTickable:NO isTicked:NO scanned:NO]];
            
        } else if (tiField.attachedAsset != nil) {
            fieldVal = [NSString stringWithFormat:@"{PH}%@{/PH}", tiField.attachedAsset.localIdentifier];
            [procPageString appendString:[self getProcFieldTag:fldName value:fieldVal isTickable:NO isTicked:NO scanned:NO]];
        } else {
            //nothing attached...
            fieldVal = @"";
            [procPageString appendString:[self getProcFieldTag:fldName value:fieldVal isTickable:NO isTicked:NO scanned:NO]];
        }
    } else if ([fld isKindOfClass:[IWDateTimeFieldView class]]){
        IWDateTimeFieldView *dtfield = (IWDateTimeFieldView *)fld;
        NSString *val = [dtfield getValue];
        [procPageString appendString:[self getProcFieldTag:fldName value:val isTickable:NO isTicked:NO scanned:NO]];
    } else if ([fld isKindOfClass:[IWDecimalFieldView class]]){
        IWDecimalFieldView *decField = (IWDecimalFieldView *)fld;
        NSString *val = [decField getValue];
        if (decField.calcErrored) {
            
            val = [NSString stringWithFormat:@"%f", decField.rawValue];
            
        }
        [procPageString appendString:[self getProcFieldTag:fldName value:val isTickable:NO isTicked:NO scanned:NO]];
    } else if ([fld isKindOfClass:[IWIsoFieldView class]]){
        IWIsoFieldView *isoField = (IWIsoFieldView *)fld;
        NSString *val = [isoField getValue];
        [procPageString appendString:[self getProcFieldTag:fldName value:val isTickable:NO isTicked:NO scanned:NO]];
    } else if ([fld isKindOfClass:[IWDropDown class]]){
        IWDropDown *ddField = (IWDropDown *) fld;
        NSString *val = ddField.selectedValue;
        NSString *valVal = [ddField getVal];
        [procPageString appendString:[self getProcFieldTag:fldName value:val dynamic:NO ddVal:valVal]];
        //[procPageString appendString:[self getProcFieldTag:fldName value:val isTickable:NO isTicked:NO scanned:NO]];
    } else if ([fld isKindOfClass:[IWTickBox class]]){
        IWTickBox *tbField = (IWTickBox *) fld;
        IWTickBoxDescriptor *desc = (IWTickBoxDescriptor *)tbField.descriptor;
        NSString *val = tbField.isSelected ? desc.tickedValue : desc.notTickedValue;
        [procPageString appendString:[self getProcFieldTag:fldName value:val isTickable:YES isTicked:tbField.isSelected scanned:NO]];
    } else if ([fld isKindOfClass:[IWNotesView class]]){
        IWNotesView *notesField = (IWNotesView *)fld;
        IWNoteFieldDescriptor *desc = (IWNoteFieldDescriptor *)notesField.descriptor;
        NSString *val = notesField.text;
//        NSNumber *limitPerLine = notesField.limitPerLine;
//        int lineCount = [desc.rectElements count];
//        if (sending){
//            val = [self splitStringForWrap:val limit:[limitPerLine intValue] size:lineCount];
//        } else {
//            //val = [self makeSavedNotesString:val limit:[limitPerLine intValue] size:lineCount];
//        }
        [procPageString appendString:[self getProcFieldTag:fldName value:val isTickable:NO isTicked:NO scanned:notesField.scanned]];
    } else if ([fld isKindOfClass:[IWDrawingField class]]){
        IWDrawingField *dField = (IWDrawingField *)fld;
        IWRectElement *rect = nil;
        IWFieldDescriptor *fDesc = dField.descriptor;
        if (dField.notesLines == 0) {
            IWDrawingFieldDescriptor *desc = (IWDrawingFieldDescriptor *)dField.descriptor;
            NSString *val = [dField.paths count] > 0 ? desc.tickedValue : desc.notTickedValue;
            rect = desc.rectElement;
            [procPageString appendString:[self getProcFieldTag:fldName value:val isTickable:YES isTicked:[dField.paths count] > 0 scanned:NO]];
        } else {
            IWNoteFieldDescriptor *nDesc = (IWNoteFieldDescriptor *)dField.descriptor;
            rect = [nDesc.rectElements firstObject];
        }
        
        numStrokesForPage += [dField.paths count];
        
        for (IWCustomPath *p in dField.paths){
            if ([p.xArray count] == 0) continue;
            if (dField.notesLines > 0) {
                IWNoteFieldDescriptor *nDesc = (IWNoteFieldDescriptor *)fDesc;
                [strokesPageString appendString:[self getStrokeTagForField:[nDesc repeatingFieldId] minX:[NSNumber numberWithFloat:[p getMinX]- dField.frame.origin.x + rect.x] minY:[NSNumber numberWithFloat:[p getMinY]- dField.frame.origin.y + rect.y] maxX:[NSNumber numberWithFloat:[p getMaxX]- dField.frame.origin.x + rect.x] maxY:[NSNumber numberWithFloat:[p getMaxY]- dField.frame.origin.y + rect.y] ]];
            } else {
                IWDrawingFieldDescriptor *dDesc = (IWDrawingFieldDescriptor *)fDesc;
                [strokesPageString appendString:[self getStrokeTagForField:[dDesc repeatingFieldId] minX:[NSNumber numberWithFloat:[p getMinX]- dField.frame.origin.x + rect.x] minY:[NSNumber numberWithFloat:[p getMinY]- dField.frame.origin.y + rect.y] maxX:[NSNumber numberWithFloat:[p getMaxX]- dField.frame.origin.x + rect.x] maxY:[NSNumber numberWithFloat:[p getMaxY]- dField.frame.origin.y + rect.y] ]];
            }
            
            
            //samples
            
            for (int i = 0; i < [p.xArray count]; i++){
                NSNumber *x = [NSNumber numberWithFloat: [[p.xArray objectAtIndex:i] floatValue] - dField.frame.origin.x + rect.x];
                NSNumber *y = [NSNumber numberWithFloat: [[p.yArray objectAtIndex:i] floatValue] - dField.frame.origin.y + rect.y];
                [strokesPageString appendString:[self getStrokeSampleTagAtX:x andY:y]];
            }
            
            [strokesPageString appendString:[self getStrokeCloser]];
        }
        
    }

    
    return numStrokesForPage;
}


- (int) handleFieldDescriptor:(IWFieldDescriptor *) fldDesc fieldName:(NSString *)fldName forSending:(BOOL)sending panel:(IWDynamicPanel *)panel procPage:(NSMutableString *)procPageString strokePage:(NSMutableString *)strokesPageString currentStrokes:(int)numStrokesForPage{
    NSString *pointer = [NSString stringWithFormat:@"%p", panel];
    UIView *fld = renderer.repeatingFields[pointer][fldDesc.repeatingIndex][[NSValue valueWithNonretainedObject:fldDesc]];
    
    if ([fld isKindOfClass:[IWTabletImageView class]]) {
        IWTabletImageView *tiField = (IWTabletImageView *)fld;
        NSString *fieldVal = @"";
        if (tiField.attachedUUID != nil) {
            fieldVal = [NSString stringWithFormat:@"{UUID}%@{/UUID}", [tiField.attachedUUID UUIDString]];
            [procPageString appendString:[self getProcFieldTag:fldName value:fieldVal isTickable:NO isTicked:NO scanned:NO]];
            
        } else if (tiField.attachedAsset != nil) {
            fieldVal = [NSString stringWithFormat:@"{PH}%@{/PH}", tiField.attachedAsset.localIdentifier];
            [procPageString appendString:[self getProcFieldTag:fldName value:fieldVal isTickable:NO isTicked:NO scanned:NO]];
        } else {
            //nothing attached...
            fieldVal = @"";
            [procPageString appendString:[self getProcFieldTag:fldName value:fieldVal isTickable:NO isTicked:NO scanned:NO]];
        }
    } else if ([fld isKindOfClass:[IWDateTimeFieldView class]]){
        IWDateTimeFieldView *dtfield = (IWDateTimeFieldView *)fld;
        NSString *val = [dtfield getValue];
        [procPageString appendString:[self getProcFieldTag:fldName value:val isTickable:NO isTicked:NO scanned:NO]];
    } else if ([fld isKindOfClass:[IWDecimalFieldView class]]){
        IWDecimalFieldView *decField = (IWDecimalFieldView *)fld;
        NSString *val = [decField getValue];
        if (decField.calcErrored) {
            
            val = [NSString stringWithFormat:@"%f", decField.rawValue];
            
        }
        [procPageString appendString:[self getProcFieldTag:fldName value:val isTickable:NO isTicked:NO scanned:NO]];
    } else if ([fld isKindOfClass:[IWIsoFieldView class]]){
        IWIsoFieldView *isoField = (IWIsoFieldView *)fld;
        NSString *val = [isoField getValue];
        [procPageString appendString:[self getProcFieldTag:fldName value:val isTickable:NO isTicked:NO scanned:NO]];
    } else if ([fld isKindOfClass:[IWDropDown class]]){
        IWDropDown *ddField = (IWDropDown *) fld;
        NSString *val = ddField.selectedValue;
        NSString *ddVal = [ddField getVal];
        [procPageString appendString:[self getProcFieldTag:fldName value:val dynamic:NO ddVal:ddVal]];
        //[procPageString appendString:[self getProcFieldTag:fldName value:val isTickable:NO isTicked:NO scanned:NO]];
    } else if ([fld isKindOfClass:[IWTickBox class]]){
        IWTickBox *tbField = (IWTickBox *) fld;
        IWTickBoxDescriptor *desc = (IWTickBoxDescriptor *)tbField.descriptor;
        NSString *val = tbField.isSelected ? desc.tickedValue : desc.notTickedValue;
        [procPageString appendString:[self getProcFieldTag:fldName value:val isTickable:YES isTicked:tbField.isSelected scanned:NO]];
    } else if ([fld isKindOfClass:[IWNotesView class]]){
        IWNotesView *notesField = (IWNotesView *)fld;
        IWNoteFieldDescriptor *desc = (IWNoteFieldDescriptor *)notesField.descriptor;
        NSString *val = notesField.text;
//        NSNumber *limitPerLine = notesField.limitPerLine;
//        int lineCount = [desc.rectElements count];
//        if (sending){
//            val = [self splitStringForWrap:val limit:[limitPerLine intValue] size:lineCount];
//        } else {
//            //val = [self makeSavedNotesString:val limit:[limitPerLine intValue] size:lineCount];
//        }
        [procPageString appendString:[self getProcFieldTag:fldName value:val isTickable:NO isTicked:NO scanned:notesField.scanned]];
    } else if ([fld isKindOfClass:[IWDrawingField class]]){
        IWDrawingField *dField = (IWDrawingField *)fld;
        
        IWRectElement *rect = nil;
        IWFieldDescriptor *fDesc = dField.descriptor;
        if (dField.notesLines == 0) {
            IWDrawingFieldDescriptor *desc = (IWDrawingFieldDescriptor *)dField.descriptor;
            NSString *val = [dField.paths count] > 0 ? desc.tickedValue : desc.notTickedValue;
            rect = desc.rectElement;
            [procPageString appendString:[self getProcFieldTag:fldName value:val isTickable:YES isTicked:[dField.paths count] > 0 scanned:NO]];
        } else {
            IWNoteFieldDescriptor *nDesc = (IWNoteFieldDescriptor *)dField.descriptor;
            rect = [nDesc.rectElements firstObject];
        }
        
        //IWDrawingFieldDescriptor *desc = (IWDrawingFieldDescriptor *)dField.descriptor;
//        NSString *val = [dField.paths count] > 0 ? desc.tickedValue : desc.notTickedValue;
//        [procPageString appendString:[self getProcFieldTag:fldName value:val isTickable:YES isTicked:[dField.paths count] > 0]];
        numStrokesForPage += [dField.paths count];
        
        for (IWCustomPath *p in dField.paths){
            if ([p.xArray count] == 0) continue;
            
            if (dField.notesLines > 0) {
                IWNoteFieldDescriptor *nDesc = (IWNoteFieldDescriptor *)fDesc;
                [strokesPageString appendString:[self getStrokeTagForField:[nDesc repeatingFieldId] minX:[NSNumber numberWithFloat:[p getMinX]- dField.frame.origin.x + rect.x] minY:[NSNumber numberWithFloat:[p getMinY]- dField.frame.origin.y + rect.y] maxX:[NSNumber numberWithFloat:[p getMaxX]- dField.frame.origin.x + rect.x] maxY:[NSNumber numberWithFloat:[p getMaxY]- dField.frame.origin.y + rect.y] ]];
            } else {
                IWDrawingFieldDescriptor *dDesc = (IWDrawingFieldDescriptor *)fDesc;
                [strokesPageString appendString:[self getStrokeTagForField:[dDesc repeatingFieldId] minX:[NSNumber numberWithFloat:[p getMinX]- dField.frame.origin.x + rect.x] minY:[NSNumber numberWithFloat:[p getMinY]- dField.frame.origin.y + rect.y] maxX:[NSNumber numberWithFloat:[p getMaxX]- dField.frame.origin.x + rect.x] maxY:[NSNumber numberWithFloat:[p getMaxY]- dField.frame.origin.y + rect.y] ]];
            }

            
//       [strokesPageString appendString:[self getStrokeTagForField:[desc repeatingFieldId] minX:[NSNumber numberWithFloat:[p getMinX]- dField.frame.origin.x + desc.rectElement.x] minY:[NSNumber numberWithFloat:[p getMinY]- dField.frame.origin.y + desc.rectElement.y] maxX:[NSNumber numberWithFloat:[p getMaxX]- dField.frame.origin.x + desc.rectElement.x] maxY:[NSNumber numberWithFloat:[p getMaxY]- dField.frame.origin.y + desc.rectElement.y] ]];
            
            //samples
            
            for (int i = 0; i < [p.xArray count]; i++){
                NSNumber *x = [NSNumber numberWithFloat: [[p.xArray objectAtIndex:i] floatValue] - dField.frame.origin.x + rect.x];
                NSNumber *y = [NSNumber numberWithFloat: [[p.yArray objectAtIndex:i] floatValue] - dField.frame.origin.y + rect.y];
                [strokesPageString appendString:[self getStrokeSampleTagAtX:x andY:y]];
            }
            
            [strokesPageString appendString:[self getStrokeCloser]];
        }
        
    }

    
    return numStrokesForPage;
}

- (int) handleFieldDescriptor:(IWFieldDescriptor *)fldDesc fieldName:(NSString *)fldName forSending:(BOOL)sending dynField:(IWDynamicField *)dynField procPage:(NSMutableString *)procPageString strokePage:(NSMutableString *)strokesPageString parentVisible:(BOOL)parentVisible currentStrokes:(int)numStrokesForPage {
    
    UIView *fld = renderer.dynamicFields[[NSValue valueWithNonretainedObject:fldDesc]];
    
    if ([fld isKindOfClass:[IWTabletImageView class]]) {
        IWTabletImageView *tiField = (IWTabletImageView *)fld;
        NSString *fieldVal = @"";
        if (tiField.attachedUUID != nil) {
            fieldVal = [NSString stringWithFormat:@"{UUID}%@{/UUID}", [tiField.attachedUUID UUIDString]];
            dynField.shownValue = fieldVal;
            [procPageString appendString:[self getProcFieldTag:fldName value:[NSString stringWithFormat:@"DYNAMIC¬¬%@", fldName] isTickable:NO isTicked:NO scanned:NO]];
            
        } else if (tiField.attachedAsset != nil) {
            fieldVal = [NSString stringWithFormat:@"{PH}%@{/PH}", tiField.attachedAsset.localIdentifier];
            dynField.shownValue = fieldVal;
            [procPageString appendString:[self getProcFieldTag:fldName value:[NSString stringWithFormat:@"DYNAMIC¬¬%@", fldName] isTickable:NO isTicked:NO scanned:NO]];
        } else {
            //nothing attached...
            fieldVal = @"";
            dynField.shownValue = fieldVal;
            [procPageString appendString:[self getProcFieldTag:fldName value:[NSString stringWithFormat:@"DYNAMIC¬¬%@", fldName] isTickable:NO isTicked:NO scanned:NO]];
        }
    } else if ([fld isKindOfClass:[IWDateTimeFieldView class]]){
        IWDateTimeFieldView *dtfield = (IWDateTimeFieldView *)fld;
        NSString *val = [dtfield getValue];
        dynField.shownValue = val;
        
        [procPageString appendString:[self getProcFieldTag:fldName value:[NSString stringWithFormat:@"DYNAMIC¬¬%@", fldName] isTickable:NO isTicked:NO scanned:NO]];
    } else if ([fld isKindOfClass:[IWDecimalFieldView class]]){
        IWDecimalFieldView *decField = (IWDecimalFieldView *)fld;
        NSString *val = [decField getValue];
        if (decField.calcErrored) {
            
            val = [NSString stringWithFormat:@"%f", decField.rawValue];
            
        }
        dynField.shownValue = val;
        
        [procPageString appendString:[self getProcFieldTag:fldName value:[NSString stringWithFormat:@"DYNAMIC¬¬%@", fldName] isTickable:NO isTicked:NO scanned:NO]];
    } else if ([fld isKindOfClass:[IWIsoFieldView class]]){
        IWIsoFieldView *isoField = (IWIsoFieldView *)fld;
        NSString *val = [isoField getValue];
        dynField.shownValue = val;
        [procPageString appendString:[self getProcFieldTag:fldName value:[NSString stringWithFormat:@"DYNAMIC¬¬%@", fldName] isTickable:NO isTicked:NO scanned:NO]];
    } else if ([fld isKindOfClass:[IWDropDown class]]){
        IWDropDown *ddField = (IWDropDown *) fld;
        NSString *val = ddField.selectedValue;
        dynField.shownValue = val;
        NSString *ddVal = [ddField getVal];
        [procPageString appendString:[self getProcFieldTag:fldName value:[NSString stringWithFormat:@"DYNAMIC¬¬%@", fldName] dynamic:YES ddVal:ddVal]];
//        [procPageString appendString:[self getProcFieldTag:fldName value:[NSString stringWithFormat:@"DYNAMIC¬¬%@", fldName] isTickable:NO isTicked:NO scanned:NO]];
    } else if ([fld isKindOfClass:[IWTickBox class]]){
        IWTickBox *tbField = (IWTickBox *) fld;
        IWTickBoxDescriptor *desc = (IWTickBoxDescriptor *)tbField.descriptor;
        NSString *val = tbField.isSelected ? desc.tickedValue : desc.notTickedValue;
        dynField.shownValue = val;
        dynField.notShownValue = desc.notTickedValue;
        [procPageString appendString:[self getProcFieldTag:fldName value:[NSString stringWithFormat:@"DYNAMIC¬¬%@", fldName] isTickable:YES isTicked:tbField.isSelected scanned:NO dynamic:YES]];
    } else if ([fld isKindOfClass:[IWNotesView class]]){
        IWNotesView *notesField = (IWNotesView *)fld;
        IWNoteFieldDescriptor *desc = (IWNoteFieldDescriptor *)notesField.descriptor;
        NSString *val = notesField.text;
//        NSNumber *limitPerLine = notesField.limitPerLine;
//        int lineCount = [desc.rectElements count];
//        if (sending){
//            val = [self splitStringForWrap:val limit:[limitPerLine intValue] size:lineCount];
//        } else {
//            //val = [self makeSavedNotesString:val limit:[limitPerLine intValue] size:lineCount];
//        }
        dynField.shownValue = val;
        [procPageString appendString:[self getProcFieldTag:fldName value:[NSString stringWithFormat:@"DYNAMIC¬¬%@", fldName] isTickable:NO isTicked:NO scanned:notesField.scanned]];
    } else if ([fld isKindOfClass:[IWDrawingField class]]){
        IWDrawingField *dField = (IWDrawingField *)fld;
        
        IWRectElement *rect = nil;
        IWFieldDescriptor *fDesc = dField.descriptor;
        if (dField.notesLines == 0) {
            IWDrawingFieldDescriptor *desc = (IWDrawingFieldDescriptor *)dField.descriptor;
            NSString *val = [dField.paths count] > 0 ? desc.tickedValue : desc.notTickedValue;
            rect = desc.rectElement;
            [procPageString appendString:[self getProcFieldTag:fldName value:[NSString stringWithFormat:@"DYNAMIC¬¬%@", fldName] isTickable:YES isTicked:[dField.paths count] > 0 scanned:NO dynamic: YES]];
            dynField.shownValue = val;
            dynField.notShownValue = desc.notTickedValue;
        } else {
            IWNoteFieldDescriptor *nDesc = (IWNoteFieldDescriptor *)dField.descriptor;
            rect = [nDesc.rectElements firstObject];
            dynField.shownValue = @"";
            dynField.notShownValue = @"";
        }
        
//        IWDrawingFieldDescriptor *desc = (IWDrawingFieldDescriptor *)dField.descriptor;
//        NSString *val = [dField.paths count] > 0 ? desc.tickedValue : desc.notTickedValue;
//        dynField.shownValue = val;
//        dynField.notShownValue = desc.notTickedValue;
//        [procPageString appendString:[self getProcFieldTag:fldName value:[NSString stringWithFormat:@"DYNAMIC¬¬%@", fldName] isTickable:YES isTicked:[dField.paths count] > 0 dynamic:YES]];
        numStrokesForPage += [dField.paths count];
        
        for (IWCustomPath *p in dField.paths){
            if ([p.xArray count] == 0) continue;

            if (dField.notesLines > 0) {
                IWNoteFieldDescriptor *nDesc = (IWNoteFieldDescriptor *)fDesc;
                [strokesPageString appendString:[self getStrokeTagForField:[nDesc repeatingFieldId] minX:[NSNumber numberWithFloat:[p getMinX]- dField.frame.origin.x + rect.x] minY:[NSNumber numberWithFloat:[p getMinY]- dField.frame.origin.y + rect.y] maxX:[NSNumber numberWithFloat:[p getMaxX]- dField.frame.origin.x + rect.x] maxY:[NSNumber numberWithFloat:[p getMaxY]- dField.frame.origin.y + rect.y] ]];
            } else {
                IWDrawingFieldDescriptor *dDesc = (IWDrawingFieldDescriptor *)fDesc;
                [strokesPageString appendString:[self getStrokeTagForField:[dDesc repeatingFieldId] minX:[NSNumber numberWithFloat:[p getMinX]- dField.frame.origin.x + rect.x] minY:[NSNumber numberWithFloat:[p getMinY]- dField.frame.origin.y + rect.y] maxX:[NSNumber numberWithFloat:[p getMaxX]- dField.frame.origin.x + rect.x] maxY:[NSNumber numberWithFloat:[p getMaxY]- dField.frame.origin.y + rect.y] ]];
            }
            
//[strokesPageString appendString:[self getStrokeTagForField:[desc repeatingFieldId] minX:[NSNumber numberWithFloat:[p getMinX]- dField.frame.origin.x + desc.rectElement.x] minY:[NSNumber numberWithFloat:[p getMinY]- dField.frame.origin.y + desc.rectElement.y] maxX:[NSNumber numberWithFloat:[p getMaxX]- dField.frame.origin.x + desc.rectElement.x] maxY:[NSNumber numberWithFloat:[p getMaxY]- dField.frame.origin.y + desc.rectElement.y] ]];
            
            //samples
            
            for (int i = 0; i < [p.xArray count]; i++){
                NSNumber *x = [NSNumber numberWithFloat: [[p.xArray objectAtIndex:i] floatValue] - dField.frame.origin.x + rect.x];
                NSNumber *y = [NSNumber numberWithFloat: [[p.yArray objectAtIndex:i] floatValue] - dField.frame.origin.y + rect.y];
                [strokesPageString appendString:[self getStrokeSampleTagAtX:x andY:y]];
            }
            
            [strokesPageString appendString:[self getStrokeCloser]];
        }
        
    }

    
    return numStrokesForPage;
}

- (int) handlePanel: (IWDynamicPanel *)panel forSending:(BOOL) sending page:(IWPageDescriptor *)page procString:(NSMutableString *)procPageString strokeString:(NSMutableString *)strokesPageString currentStrokeCount:(int)numStrokesForPage{
    return [self handlePanel:panel forSending:sending page:page procString:procPageString strokeString:strokesPageString currentStrokeCount:numStrokesForPage parentVisible:YES];
}

- (int) handlePanel: (IWDynamicPanel *)panel forSending:(BOOL) sending page:(IWPageDescriptor *)page procString:(NSMutableString *)procPageString strokeString:(NSMutableString *)strokesPageString currentStrokeCount:(int)numStrokesForPage parentVisible:(BOOL) parentVisible{
    
    NSString *pointer = [NSString stringWithFormat:@"%p", panel];
    
    if (panel.repeatingPanel) {
        NSMutableArray *list = renderer.repeatingDecriptors[pointer];
        
        [procPageString appendFormat:@"<repeating fieldid=\"%@\">\n", panel.fieldId];
        
        for (int i = 0; i < list.count; i++) {
            [procPageString appendFormat:@"<instance id=\"%u\">\n", i];
            NSMutableArray *innerList = list[i];
            for (int j = 0; j < innerList.count; j++) {
                if (![innerList[j] isKindOfClass:[IWFieldDescriptor class]]) {
                    continue;
                }
                numStrokesForPage = [self handleFieldDescriptor:(IWFieldDescriptor *)innerList[j] fieldName:((IWFieldDescriptor *)innerList[j]).fieldId forSending:sending panel:panel procPage:procPageString strokePage:strokesPageString currentStrokes:numStrokesForPage];
            }
            
            //radios...
            for (NSObject *o in panel.children) {
                if (![o isKindOfClass:[NSString class]]) {
                    continue;
                }
                
                //radio manager...
                IWRadioButtonManager *rbm = renderer.repeatingRadioManagers[pointer][i][(NSString *)o];
                for (IWRadioButton *rd in rbm.radios.objectEnumerator) {
                    [procPageString appendString:[self getProcFieldTag:rd.descriptor.fieldId value:rd.isTicked ? rd.descriptor.tickedValue : rd.descriptor.notTickedValue isTickable:YES isTicked:rd.isTicked scanned:NO]];
                }
            }
            [procPageString appendString:@"</instance>\n"];
        }
        [procPageString appendString:@"</repeating>\n"];
    } else {
        for (NSObject *o in panel.children) {
            if ([o isKindOfClass:[IWDynamicPanel class]]) {
                numStrokesForPage = [self handlePanel:(IWDynamicPanel *)o forSending:sending page:page procString:procPageString strokeString:strokesPageString currentStrokeCount:numStrokesForPage parentVisible:parentVisible && panel.shouldShowPanel];
                continue;
            }
            
            if ([o isKindOfClass:[NSString class]]) {
                IWRadioButtonManager *rbm = renderer.repeatingRadioManagers[(NSString *)o];
                for (IWRadioButton *rd in rbm.radios) {
                    
                    IWDynamicField *dynField = !dynamicFields[rd.descriptor.fieldId] ? [[IWDynamicField alloc] init] : dynamicFields[rd.descriptor.fieldId];
                    
                    dynField.shownValue = rd.isTicked ? rd.descriptor.tickedValue : rd.descriptor.notTickedValue;
                    dynField.notShownValue = rd.descriptor.notTickedValue;
                    dynField.fieldId = rd.descriptor.fieldId;
                    dynField.tickable = YES;
                    dynField.ticked = rd.isTicked;
                    
                    [procPageString appendString:[self getProcFieldTag:rd.descriptor.fieldId value:[NSString stringWithFormat:@"DYNAMIC¬¬%@", rd.descriptor.fieldId] isTickable:YES isTicked:rd.isTicked scanned:NO dynamic:YES]];
                    
                    [dynamicFields setObject:dynField forKey:rd.descriptor.fieldId];
                    
                }
                continue;
            }
            
            if ([o isKindOfClass:[IWFieldDescriptor class]]) {
                IWFieldDescriptor *fieldDescriptor = (IWFieldDescriptor *)o;
                
                IWDynamicField *dynField = !dynamicFields[fieldDescriptor.fieldId] ? [[IWDynamicField alloc] init] : dynamicFields[fieldDescriptor.fieldId];
                
                dynField.shownValue = @"";
                dynField.notShownValue = @"";
                dynField.fieldId = fieldDescriptor.fieldId;
                dynField.tickable = NO;
                dynField.ticked = NO;
                
                numStrokesForPage = [self handleFieldDescriptor:fieldDescriptor fieldName:fieldDescriptor.fieldId forSending:sending dynField:dynField procPage:procPageString strokePage:strokesPageString parentVisible:parentVisible && panel.shouldShowPanel currentStrokes:numStrokesForPage];
                
                [dynamicFields setObject:dynField forKey:fieldDescriptor.fieldId];
                
            }
        }
    }
    
    
    return numStrokesForPage;
}

//Saves a completed/partially completed page. This happens for any page the user has visited
- (void) savePage: (NSNumber *) page forSending: (BOOL)sending fields: (NSDictionary *) fields radios: (NSDictionary *) radios renderer:(IWFormRenderer *)rend{
    self.renderer = rend;
    currentPageToSave = page;
    NSMutableString *strokesPageString = [NSMutableString stringWithString:@""];
    NSMutableString *procPageString = [NSMutableString stringWithString:@""];
    int numStrokesForPage = 0;
    NSNumber *pageNum = [NSNumber numberWithInt:((IWPageDescriptor *)formDescriptor.pageDescriptors[[page intValue]]).pageNumber - 1];
    //Create page here
    [strokesPageString appendString:[self getStrokesPageHeader:pageNum]];
    [procPageString appendString:[self getProcPageTag:pageNum]];
    
    //fields
    
    for (NSString *fldName in fields) {
        
        UIView *fld = [fields objectForKey:fldName];
        numStrokesForPage = [self handleFieldDescriptor:fld fieldName:fldName procString:procPageString strokeString:strokesPageString forSending:sending currentNumStrokes:numStrokesForPage];
    }
    
    //panels
    IWPageDescriptor *pageDesc = renderer.pageServer.pages[page];
    for (IWDynamicPanel *panel in pageDesc.panels) {
        numStrokesForPage = [self handlePanel:panel forSending:sending page:pageDesc procString:procPageString strokeString:strokesPageString currentStrokeCount:numStrokesForPage];
    }
    
    //radios
    for (NSString *groupName in radios){
        IWRadioButtonManager *mgr = [radios objectForKey:groupName];
        
        for (NSString *rdString in mgr.radios){
            IWRadioButton *radio = [mgr.radios objectForKey:rdString];
            IWRadioButtonDescriptor *desc = (IWRadioButtonDescriptor *) radio.descriptor;
            NSString *val = radio.isTicked ? desc.tickedValue : desc.notTickedValue;
            [procPageString appendString:[self getProcFieldTag:desc.fieldId value:val isTickable:YES isTicked:radio.isTicked scanned:NO]];
        }
    }
    
    [strokesPageString appendString:[self getStrokesPageCloser]];
    [procPageString appendString:[self getProcPageCloser]];
    
    
    NSDictionary *pageInfo = @{@"proc":procPageString, @"strokes": strokesPageString, @"num":[NSNumber numberWithInt:numStrokesForPage]};
    [pageStrings setObject:pageInfo forKey:currentPageToSave];
}

// This happens for any pages that have not been visited, at the time of saving or sending.
- (void) saveEmptyPage: (NSNumber *) page {
    NSMutableString *strokesPageString = [NSMutableString stringWithString:@""];
    NSMutableString *procPageString = [NSMutableString stringWithString:@""];
    NSNumber *pageNum = [NSNumber numberWithInt:((IWPageDescriptor *)formDescriptor.pageDescriptors[[page intValue]]).pageNumber - 1];
    
    [strokesPageString appendString:[self getStrokesPageHeader:pageNum]];
    [procPageString appendString:[self getProcPageTag:pageNum]];
    
    IWPageDescriptor *pageDesc = [formDescriptor.pageDescriptors objectAtIndex:[page intValue]];
    for (IWFieldDescriptor *field in pageDesc.fieldDescriptors) {
        if ([field isKindOfClass:[IWTickedFieldDescriptor class]]) {
            NSString *val = ((IWTickedFieldDescriptor *)field).notTickedValue;
            if ([renderer.loadedFieldValues objectForKey:field.fieldId]) {
                val = renderer.loadedFieldValues[field.fieldId];
            }
            [procPageString appendString:[self getProcFieldTag:field.fieldId value:val isTickable:YES isTicked:NO scanned:NO]];
        } else {
            NSString *val = @"";
            if ([renderer.loadedFieldValues objectForKey:field.fieldId]) {
                val = renderer.loadedFieldValues[field.fieldId];
            }
            [procPageString appendString:[self getProcFieldTag:field.fieldId value:val isTickable:NO isTicked:NO scanned:NO]];
        }
    }
    
    for (NSString *s in pageDesc.radioGroups.keyEnumerator) {
        for (IWTickedFieldDescriptor *rd in pageDesc.radioGroups[s]){
            
            [procPageString appendString:[self getProcFieldTag:rd.fieldId value:rd.notTickedValue isTickable:YES isTicked:NO scanned:NO]];

           
        }
    }
    
    [procPageString appendString:[self getProcPageCloser]];
    [strokesPageString appendString:[self getStrokesPageCloser]];
    
    NSDictionary *dict = @{@"proc":procPageString, @"strokes":strokesPageString, @"num": @0};
    [pageStrings setObject:dict forKey:page];
}

# pragma mark Note field management

- (NSString *) fixPanel:(IWDynamicPanel *)panel string:(NSString *)pageString visible:(BOOL)visible {
    NSString *s = pageString;
    
    BOOL showThisPanel = visible && panel.shouldShowPanel;
    
    for (NSObject *o in panel.children) {
        if ([o isKindOfClass:[IWDynamicPanel class]]) {
            s = [self fixPanel:(IWDynamicPanel *)o string:s visible:showThisPanel];
            continue;
        }
        
        if ([o isKindOfClass:[IWFieldDescriptor class]]) {
            IWFieldDescriptor *fd = (IWFieldDescriptor *)o;
            IWDynamicField *dyn = dynamicFields[fd.fieldId];
            if (!dyn) continue;
            if ([fd isKindOfClass:[IWTickedFieldDescriptor class]]) {
                //tickable
                s = [s stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"DYNAMICTICKED¬¬%@", fd.fieldId] withString:dyn.Ticked ? @"true" : @"false"];
            }
            s = [s stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"DYNAMIC¬¬%@", fd.fieldId] withString:showThisPanel ? dyn.ShownValue : dyn.NotShownValue];
        }
    }
    
    
    return s;
}

//replaces the §§§ coded strings in the xml with line-wrapped versions
- (NSString *) fixProcPageForSending: (NSString *) pageString {
    
    for (NSNumber *pageNo in renderer.pageServer.pages.keyEnumerator) {
        IWPageDescriptor *page = renderer.pageServer.pages[pageNo];
        for (IWDynamicPanel *panel in page.panels) {
            if (panel.repeatingPanel) continue;
            pageString = [self fixPanel:panel string:pageString visible:YES];
        }
    }
    
    NSArray *elements = [pageString componentsSeparatedByString:@"§§§"];
    //this splits up the old string, making the contents of each notes field their own.
    //the order goes like this:
    // 0 = normal form content    4 = normal form content
    // 1 = limit per line         5 = limit per line
    // 2 = number of lines        6 = number of lines
    // 3 = notes text             7 = notes text
    // etc
    
    
    // made like this:
    //   |---------------- 0 ------------------|--1-|-2-|--------3--------|------------4---------...
    //   ...form data.... <field...><value...>§§§25§§§5§§§Some Notes Here§§§</value></field>... etc
    if ([elements count] == 1) return pageString;
    
    NSMutableString *newString = [NSMutableString stringWithString:@""];
    
    for (int i = 1; i < [elements count]; i += 4){
//        NSString *limitPerLineS = [elements objectAtIndex:i];
//        NSString *numLinesS = [elements objectAtIndex:i + 1];
        //NSNumber *numLines = [NSNumber numberWithInt:[numLinesS integerValue]];
        //NSNumber *limitPerLine = [NSNumber numberWithInt:[limitPerLineS integerValue]];
        NSString *noteText = @"";
        if (elements.count > i+2){
            noteText = [elements objectAtIndex:i + 2];
        }
        // DISABLED since Form View and PDF both wrap text now
        //noteText = [self splitStringForWrap:noteText limit:[limitPerLine intValue] size:[numLines intValue]];
        NSString *formData = [elements objectAtIndex:i - 1];
        [newString appendString:formData];
        [newString appendString:noteText];
    }
    
    NSString *formData = [elements lastObject];
    [newString appendString:formData];
    
    return newString;
}

//creates the §§§ coded strings for a note field for saving, rather than wrapping for sending. This is needed in case field needs to be changed before sending
- (NSString *) makeSavedNotesString: (NSString *) noteText limit: (int) limit size: (int) size {
    NSString *ret = [NSString stringWithFormat:@"§§§%d§§§%d§§§%@§§§", limit, size, noteText];
    
    return ret;
}

//this splits the string as per the previous versions (Android + Windows)
- (NSString *) splitStringForWrap: (NSString *) original limit: (int) limit size: (int) size{
    

    if ([original length] < limit) {
        int countLines = [original length] - [[original stringByReplacingOccurrencesOfString:@"\n" withString:@""] length] + 1;
        if (countLines > size){
            NSRange range = NSMakeRange(0, [original length]);
            for (int i = 0; i < size - 1; i++){
                range = [original rangeOfString:@"\n" options:0 range:range];
                range = NSMakeRange(range.location + range.length, [original length] - (range.location + range.length));
            }
            range = [original rangeOfString:@"\n" options:0 range:range];
            original = [original substringToIndex:range.location];
            
        }
        return original;
    }
    
    NSMutableString *sb = [NSMutableString stringWithString:@""];
    int index = 0;
    while (index < [original length] - 1){
        NSString *block;
        if (index + limit < [original length]){
            block = [original substringWithRange:NSMakeRange(index, limit)];
            if ([block rangeOfString:@" "].location != NSNotFound){
                NSRange lastSpace = [block rangeOfString:@" " options:NSBackwardsSearch];
                block = [block substringToIndex:lastSpace.location + 1];
            }
        } else {
            block = [original substringFromIndex:index];
        }
        
        if ([block rangeOfString:@"\n"].location != NSNotFound){
            block = [block substringToIndex:[block rangeOfString:@"\n"].location];
            index++;
        }
        
        [sb appendString:block];
        [sb appendString:@"\n"];
        index += [block length];
    }
    
    //replace last "\n"
    NSString *finalString = [sb substringToIndex:[sb length] - 2];
    NSString *lastchar = [sb substringFromIndex:[sb length] - 2];
    lastchar = [lastchar stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    finalString = [finalString stringByAppendingString:lastchar];
    
    int countLines = [finalString length] - [[finalString stringByReplacingOccurrencesOfString:@"\n" withString:@""] length] + 1;
    if (countLines > size){
        NSRange range = NSMakeRange(0, [finalString length]);
        for (int i = 0; i < size - 1; i++){
            range = [finalString rangeOfString:@"\n" options:0 range:range];
            range = NSMakeRange(range.location + range.length, [finalString length] - (range.location + range.length));
        }
        range = [finalString rangeOfString:@"\n" options:0 range:range];
        finalString = [finalString substringToIndex:range.location];
        
    }
    return finalString;
}

#pragma mark Main Saving/Sending Methods

- (BOOL) hasValue: (NSArray *) tickboxes {
    for (IWTickBox *tb in tickboxes) {
        if (tb.isSelected) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)saveFormForSending:(BOOL)sending onPageNumber:(NSNumber *)page dictionary:(NSDictionary *)fields radios:(NSDictionary *)radios renderer:(IWFormRenderer *)rend {
    return [self saveFormForSending:sending onPageNumber:page dictionary:fields radios:radios renderer:rend autoSave:NO];
}

- (BOOL)saveFormForSending:(BOOL)sending onPageNumber:(NSNumber *)page dictionary:(NSDictionary *)fields radios:(NSDictionary *)radios renderer:(IWFormRenderer *)rend autoSave:(BOOL) autoSave {
    
    int numberOfStrokesForForm = 0;
    [self savePage:page forSending:sending fields:fields radios:radios renderer:rend];
    
    NSDictionary *mandatory = renderer.mandatoryViews;
    NSMutableDictionary *mandDescs = [NSMutableDictionary dictionary];
    NSArray *mandRads = renderer.mandatoryRadioGroups;
    NSDictionary *mandatoryRadioGroupManagers = renderer.mandatoryRadioGroupManagers;
    NSDictionary *mandChecks = renderer.formDescriptor.mandatoryCheckBoxGroups;
    NSMutableDictionary *mandTicks = [NSMutableDictionary dictionary];
    
    for (IWFieldDescriptor *fld in renderer.mandatoryDescriptors) {
        [mandDescs setObject:renderer.mandatoryDescriptors[fld] forKey:fld];
    }
    
    if (sending) {
        
        for (NSString *key in mandChecks.keyEnumerator) {
            NSArray *list = mandChecks[key];
            for (NSString *fid in list) {
                IWTickBox *tb = (IWTickBox *)mandatory[fid];
                if (tb == nil) {
                    BOOL shouldContinue = NO;
                    for (NSString *k in mandatory) {
                        int ind = -1;
                        NSString *indStr = [NSString stringWithFormat:@"%@",k];
                        NSString *flatField = [NSString stringWithFormat:@"%@",k];
                        
                        while ([indStr rangeOfString:@"_"].location != NSNotFound) {
                            indStr = [indStr substringFromIndex:[indStr rangeOfString:@"_"].location +1];
                        }
                        if ([[NSScanner scannerWithString:indStr] scanInt:nil]) {
                            ind = [indStr intValue];
                        }
                        
                        if (ind > -1) {
                            flatField = [flatField stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"_%d", ind] withString:@""];
                        }
                        
                        if ([flatField isEqualToString:fid]) {
                            IWTickBox *rtb = (IWTickBox *) mandatory[k];
                            if (![rend.formDescriptor fieldIsOnPage:rtb.descriptor.fieldId]) {
                                IWDynamicPanel *parentP = nil;
                                for (IWPageDescriptor *pge in renderer.formDescriptor.pageDescriptors) {
                                    for (IWDynamicPanel *pan in pge.panels) {
                                        if ([pan fieldIsChild:rtb.descriptor.fieldId]) {
                                            parentP = pan;
                                            break;
                                        }
                                        if (parentP != nil) {
                                            break;
                                        }
                                    }
                                    if (parentP != nil) {
                                        break;
                                    }
                                }
                                if (![parentP fieldIsVisible:rtb.descriptor.fieldId]) {
                                    shouldContinue = true;
                                    break;
                                }
                            } else {
                                for (IWPageDescriptor *pge in renderer.formDescriptor.pageDescriptors) {
                                    for (IWFieldDescriptor *fld in pge.fieldDescriptors) {
                                        if (fld.fieldId == rtb.descriptor.fieldId) {
                                            if (![renderer.pageServer.servedPages containsObject:pge]) {
                                                shouldContinue = true;
                                                break;
                                            }
                                        }
                                    }
                                    if (shouldContinue) {
                                        break;
                                    }
                                }
                                if (shouldContinue) {
                                    break;
                                }
                            }
                            
                            NSString *newKey = [NSString stringWithFormat:@"%@_%d", rtb.descriptor.groupName, ind];
                            if (mandTicks[newKey] == nil) {
                                [mandTicks setObject:[NSMutableArray array] forKey:newKey];
                            }
                            [mandTicks[newKey] addObject:rtb];
                        }
                    }
                    if (shouldContinue) {
                        continue;
                    }
                }
                if (tb != nil) {
                    if (![rend.formDescriptor fieldIsOnPage:tb.descriptor.fieldId]) {
                        IWDynamicPanel *parentP = nil;
                        for (IWPageDescriptor *pge in renderer.formDescriptor.pageDescriptors) {
                            for (IWDynamicPanel *pan in pge.panels) {
                                if ([pan fieldIsChild:tb.descriptor.fieldId]) {
                                    parentP = pan;
                                    break;
                                }
                                if (parentP != nil) {
                                    break;
                                }
                            }
                            if (parentP != nil) {
                                break;
                            }
                        }
                        if (![parentP fieldIsVisible:tb.descriptor.fieldId]) {
                            continue;
                        }
                    } else {
                        for (IWPageDescriptor *pge in renderer.formDescriptor.pageDescriptors) {
                            for (IWFieldDescriptor *fld in pge.fieldDescriptors) {
                                if (fld.fieldId == tb.descriptor.fieldId) {
                                    if (![renderer.pageServer.servedPages containsObject:pge]) {
                                        continue;
                                    }
                                }
                            }
                        }
                    }
                    if (mandTicks[key] == nil) {
                        [mandTicks setObject:[NSMutableArray array] forKey:key];
                    }
                    [mandTicks[key] addObject:tb];
                }
            }
        }
        
        for (NSString *key in mandTicks.keyEnumerator) {
            NSArray *list = mandTicks[key];
            if (![self hasValue:list]) {
                return NO;
            }
        }
        
        for (NSString *key in mandRads) {
            IWDynamicPanel *parentP = nil;
            
            int ind = -1;
            NSString *indStr = [NSString stringWithFormat:@"%@",key];
            NSString *flatField = [NSString stringWithFormat:@"%@",key];
            
            while ([indStr rangeOfString:@"_"].location != NSNotFound) {
                indStr = [indStr substringFromIndex:[indStr rangeOfString:@"_"].location +1];
            }
            if ([[NSScanner scannerWithString:indStr] scanInt:nil]) {
                ind = [indStr intValue];
            }
            
            if (ind > -1) {
                flatField = [flatField stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"_%d", ind] withString:@""];
            }
            
            
            IWPageDescriptor *parentPage = nil;
            
            for (IWPageDescriptor *pge in renderer.formDescriptor.pageDescriptors) {
                for (IWDynamicPanel *pan in pge.panels) {
                    if ([pan fieldIsChild:flatField]) {
                        
                        parentPage = pge;
                        parentP = pan;
                        break;
                    }
                    if (parentP != nil) {
                        break;
                    }
                }
                if (parentP != nil) {
                    break;
                }
            }
            if (parentP != nil) {
                if (![parentP fieldIsVisible:flatField]) {
                    continue;
                }
            } else {
                for (IWPageDescriptor *pge in rend.formDescriptor.pageDescriptors) {
                    if ([pge.radioGroups objectForKey:flatField] != nil) {
                        parentPage = pge;
                        break;
                    }
                }
                if (parentPage != nil) {
                    if (![rend.pageServer.servedPages containsObject:parentPage]) {
                        continue;
                    }
                }
            }
            if ([mandatoryRadioGroupManagers objectForKey:key] == nil ){
                BOOL hasval = NO;
                IWPageDescriptor *parentPage = nil;
                IWDynamicPanel *parentP = nil;
                NSMutableArray *possFields = [NSMutableArray array];
                for (IWPageDescriptor *pge in renderer.formDescriptor.pageDescriptors) {
                    if ([pge fieldIsOnPage:flatField]) {
                        parentPage = pge;
                        break;
                    }
                    for (IWDynamicPanel *pan in pge.panels) {
                        if ([pan fieldIsChild:flatField]) {
                            parentP = pan;
                            parentPage = pge;
                            
                            break;
                        }
                        
                    }
                    if (parentP != nil) {
                        break;
                    }
                }
                if (parentP != nil) {
                    if (![parentP fieldIsVisible:flatField]) {
                        continue;
                    }
                }
                if (parentPage != nil) {
                    if (![renderer.pageServer.servedPages containsObject:parentPage]) {
                        continue;
                    }
                    
                    NSArray *possibles = parentPage.radioGroups[flatField];
                    for (IWRadioButtonDescriptor *rbd in possibles) {
                        NSString *buttonName = rbd.fieldId;
                        if (ind > -1) {
                            buttonName = [buttonName stringByAppendingString:[NSString stringWithFormat:@"_%d", ind]];
                        }
                        if (renderer.loadedFieldValues[buttonName] && ![renderer.loadedFieldValues[buttonName] isEqualToString:@""]) {
                            hasval = YES;
                        }
                    }
                }
                
                if (!hasval) {
                    return NO;
                }
                
                
            }
        }
        
        for (NSString *key in mandDescs.keyEnumerator) {
            int ind = -1;
            NSString *indStr = [NSString stringWithFormat:@"%@",key];
            NSString *flatField = [NSString stringWithFormat:@"%@",key];
            
            while ([indStr rangeOfString:@"_"].location != NSNotFound) {
                indStr = [indStr substringFromIndex:[indStr rangeOfString:@"_"].location +1];
            }
            if ([[NSScanner scannerWithString:indStr] scanInt:nil]) {
                ind = [indStr intValue];
            }
            
            if (ind > -1) {
                flatField = [flatField stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"_%d", ind] withString:@""];
            }
            

            if ([mandatory objectForKey:key] == nil) {
                BOOL cont = false;
                if (![rend.formDescriptor fieldIsOnPage:flatField]) {
                    IWDynamicPanel *parentP = nil;
                    for (IWPageDescriptor *pge in renderer.formDescriptor.pageDescriptors) {
                        for (IWDynamicPanel *pan in pge.panels) {
                            if ([pan fieldIsChild:flatField]) {
                                if (![renderer.pageServer.servedPages containsObject:pge]) {
                                    cont = true;
                                    break;
                                }
                                parentP = pan;
                                //cont = true;
                                break;
                            }
                            if (parentP != nil) {
                                break;
                            }
                        }
                        if (parentP != nil) {
                            break;
                        }
                    }
                    if (![parentP fieldIsVisible:flatField]) {
                        cont = true;
                        continue;
                    }
                } else {
                    for (IWPageDescriptor *pge in renderer.formDescriptor.pageDescriptors) {
                        for (IWFieldDescriptor *fld in pge.fieldDescriptors) {
                            if (fld.fieldId == key) {
                                if (![renderer.pageServer.servedPages containsObject:pge]) {
                                    cont = true;
                                    break;
                                }
                            }
                        }
                    }
                }
                if (cont) {
                    continue;
                }
                IWFieldDescriptor *fieldDesc = mandDescs[key];
                if ([fieldDesc isKindOfClass:[IWTickBoxDescriptor class]]) {
                    
                    if (!renderer.loadedFieldValues[key] || ![renderer.loadedFieldValues[key] isEqualToString:((IWTickBoxDescriptor *)fieldDesc).notTickedValue]) {
                        return NO;
                    }
                } else if (!renderer.loadedFieldValues[key] || [renderer.loadedFieldValues[key] isEqualToString:@""]) {
                    return NO;
                }
            }
        }
        
        for (NSString *key in mandatoryRadioGroupManagers.keyEnumerator) {
            
            int ind = -1;
            NSString *indStr = [NSString stringWithFormat:@"%@",key];
            NSString *flatField = [NSString stringWithFormat:@"%@",key];
            
            while ([indStr rangeOfString:@"_"].location != NSNotFound) {
                indStr = [indStr substringFromIndex:[indStr rangeOfString:@"_"].location +1];
            }
            if ([[NSScanner scannerWithString:indStr] scanInt:nil]) {
                ind = [indStr intValue];
            }
            if (ind > -1) {
                flatField = [flatField stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"_%d", ind] withString:@""];
            }
            IWDynamicPanel *parentP = nil;
            BOOL shouldCont = NO;
            for (IWPageDescriptor *pge in renderer.formDescriptor.pageDescriptors) {
                for (IWDynamicPanel *pan in pge.panels) {
                    if ([pan fieldIsChild:flatField]) {
                        if (![renderer.pageServer.servedPages containsObject:pge]) {
                            shouldCont = YES;
                            break;
                        }
                        parentP = pan;
                        break;
                    }
                    if (parentP != nil) {
                        break;
                    }
                }
                if (shouldCont) {
                    break;
                }
                if (parentP != nil) {
                    break;
                }
            }
            if (shouldCont) continue;
            if (parentP != nil) {
                if (![parentP fieldIsVisible:flatField]) {
                    continue;
                }
            }
            IWRadioButtonManager *rbm = mandatoryRadioGroupManagers[key];
            BOOL visible = YES;
            for (IWPageDescriptor *pge in renderer.pageServer.pages.objectEnumerator) {
                if ([pge fieldIsOnPage:flatField]) {
                    if (![renderer.pageServer.servedPages containsObject:pge]) {
                        visible = NO;
                    }
                    break;
                }
            }
            if (visible) {
                if (![rbm hasValue]) {
                    return NO;
                }
            }
        }
        
        for (NSString *key1 in mandatory ) {
            int ind = -1;
            NSString *indStr = [NSString stringWithFormat:@"%@",key1];
            NSString *key = [NSString stringWithFormat:@"%@",key1];
            
            while ([indStr rangeOfString:@"_"].location != NSNotFound) {
                indStr = [indStr substringFromIndex:[indStr rangeOfString:@"_"].location +1];
            }
            if ([[NSScanner scannerWithString:indStr] scanInt:nil]) {
                ind = [indStr intValue];
            }
            if (ind > -1) {
                key = [key stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"_%d", ind] withString:@""];
            }
            BOOL shouldCont = NO;
            if (![rend.formDescriptor fieldIsOnPage:key]) {
                IWDynamicPanel *parentP = nil;
                for (IWPageDescriptor *pge in renderer.formDescriptor.pageDescriptors) {
                    for (IWDynamicPanel *pan in pge.panels) {
                        if ([pan fieldIsChild:key]) {
                            
                            parentP = pan;
                            if (![renderer.pageServer.servedPages containsObject:pge]) {
                                shouldCont = YES;
                                break;
                            }
                            break;
                        }
                        if (parentP != nil) {
                            break;
                        }
                    }
                    if (parentP != nil) {
                        break;
                    }
                }
                if (parentP != nil) {
                    if (![parentP fieldIsVisible:key]) {
                        continue;
                    }
                }
            } else {
                for (IWPageDescriptor *pge in renderer.formDescriptor.pageDescriptors) {
                    if ([pge fieldIsOnPage:key]) {
                        if (![renderer.pageServer.servedPages containsObject:pge]) {
                            shouldCont = YES;
                            break;
                        }
                    }
                }
            }

            if (shouldCont) continue;
            
            UIView *v = mandatory[key1];
            if ([v isKindOfClass:[IWIsoFieldView class]]) {
                NSString *val = [((IWIsoFieldView *)v) getValue];
                if ([val isEqualToString:@""]) {
                    return NO;
                }
            }
            if ([v isKindOfClass:[IWDropDown class]]) {
                NSString *val = [((IWDropDown *)v) selectedValue];
                if ([val isEqualToString:@""]) {
                    return NO;
                }
            }
            if ([v isKindOfClass:[IWDrawingField class]]) {
                if (((IWDrawingField *)v).paths.count == 0) {
                    return NO;
                }
            }
            if ([v isKindOfClass:[IWNotesView class]]) {
                if ([((IWNotesView *)v).text isEqualToString:@""]){
                    return NO;
                }
            }
            if ([v isKindOfClass:[IWTickBox class]]) {
                if (!((IWTickBox *)v).isTicked && (((IWTickBox *)v).descriptor.groupName == nil || [((IWTickBox *)v).descriptor.groupName isEqualToString:@""])) {
                    return NO;
                }
            }
        }
        
    }
    
    
    for (int i = 0; i < [formDescriptor numberOfPages]; i++){
        if ([pageStrings objectForKey:[NSNumber numberWithInt:i]] == nil){
            [self saveEmptyPage:[NSNumber numberWithInt:i]];
        } else {
            NSDictionary *dict = [pageStrings objectForKey:[NSNumber numberWithInt:i]];
            NSNumber *numStrokes = [dict objectForKey:@"num"];
            numberOfStrokesForForm += [numStrokes intValue];
            if (sending){
                NSString *procString = [dict objectForKey:@"proc"];
                procString = [self fixProcPageForSending:procString];
                NSString *strokeString = [dict objectForKey:@"strokes"];
                NSDictionary *newDict = @{@"proc":procString, @"strokes":strokeString, @"num":numStrokes};
                [pageStrings setObject:newDict forKey:[NSNumber numberWithInt:i]];
            }
        }
    }
    
    NSMutableString *procFormString = [NSMutableString stringWithString:@""];
    NSMutableString *strokeFormString = [NSMutableString stringWithString:@""];
    
    [procFormString appendString:[self getProcFormHeader:[NSDate date]]];
    [strokeFormString appendString:[self getStrokesFormHeader:[NSDate date] strokeCount:[NSNumber numberWithInt: numberOfStrokesForForm]]];
    
    if (!sending) {
        [procFormString appendString:@"§-§"];
        [strokeFormString appendString:@"§-§"];
    }
    
    for (int i = 0; i < [formDescriptor.pageDescriptors count]; i++){
        NSNumber *pageNumber = [NSNumber numberWithInt:i];
        NSDictionary *pageInfos = [pageStrings objectForKey:pageNumber];
        NSString *proc = [pageInfos objectForKey:@"proc"];
        NSString *strokes = [pageInfos objectForKey:@"strokes"];
        IWPageDescriptor *pageDesc = [renderer.pageServer.pages objectForKey:@(i)];
        NSString *oldPageNo = [NSString stringWithFormat:@"pageno=\"%d\"", i+1];
        NSString *newPageNo = [NSString stringWithFormat:@"pageno=\"%d\"", pageDesc.realPageNumber];
        if (sending) {
            proc = [proc stringByReplacingOccurrencesOfString:oldPageNo withString:newPageNo];
            strokes = [strokes stringByReplacingOccurrencesOfString:oldPageNo withString:newPageNo];
        }
        [procFormString appendString:proc];
        [strokeFormString appendString:strokes];
        
        if (!sending) {
            [procFormString appendString:@"§-§"];
            [strokeFormString appendString:@"§-§"];
        }
    }
    
    [procFormString appendString:[self getProcFormCloser]];
    [strokeFormString appendString:[self getStrokesFormCloser]];
    
    
    if (autoSave) {
        if (autoSavedTransaction == nil) {
            autoSavedTransaction = [[IWTransaction alloc] initWithIndex:-1 formId:listItem.FormId sent:NO username:[IWInkworksService getInstance].loggedInUser savedDate:[NSDate date] addedDate:startDate sentDate:nil originalAddedDate:startDate autoSavedDate:[[NSDate alloc] init] formName:listItem.FormName penData:procFormString strokes:strokeFormString status:sending? @"Awaiting" : @"Parked" historyItemIndex:0 hashedPassword:[IWInkworksService getHashedPassword:[IWInkworksService getInstance].loggedInPassword] prepopId:[IWInkworksService getInstance].currentPrepopItem.PrepopId parentTransaction:originalTransaction == nil ? -1 : originalTransaction.ColumnIndex];
        }
        autoSavedTransaction.ParentTransaction = originalTransaction == nil ? -1 : originalTransaction.ColumnIndex;
        autoSavedTransaction.HashedPassword = [IWInkworksService getHashedPassword:[IWInkworksService getInstance].loggedInPassword];
        autoSavedTransaction.PenDataXml = procFormString;
        autoSavedTransaction.StrokesXml = strokeFormString;
        autoSavedTransaction.SavedDate = originalTransaction == nil ? nil : originalTransaction.SavedDate;
        autoSavedTransaction.Status = @"Autosaved";
        if ([IWInkworksService getInstance].currentPrepopItem) {
            autoSavedTransaction.PrepopId = [IWInkworksService getInstance].currentPrepopItem.PrepopId;
        } else {
            autoSavedTransaction.PrepopId = -1;
        }
        
        autoSavedTransaction = [[IWInkworksService dbHelper] addOrUpdateTransaction:autoSavedTransaction];
        
        // now do the photo thing
        // first reset attached images...
        [[IWInkworksService dbHelper] resetAttachedPhotos:autoSavedTransaction.ColumnIndex];
        // next check attached form photos
        for (NSUUID *uuid in attachedFormPhotos) {
            NSString *path = [IWFileSystem getFormPhotoPathWithId:listItem.FormId andUUID:uuid];
            IWAttachedPhoto *photo = [[IWAttachedPhoto alloc] init];
            photo.ImageStatus = @"Sending";
            photo.ImagePath = path;
            photo.ImageType = @"FORM_PHOTO";
            photo.ImageUUID = [uuid UUIDString];
            photo.TransactionId = autoSavedTransaction.ColumnIndex;
            
            [[IWInkworksService dbHelper] addOrUpdatePhoto:photo];
        }
        for (PHAsset * asset in attachedGalleryImages) {
            IWAttachedPhoto *photo = [[IWAttachedPhoto alloc] init];
            NSString *path = [NSString stringWithFormat:@"{PH}%@", asset.localIdentifier];
            photo.ImageStatus = @"Sending";
            photo.ImagePath = path;
            photo.ImageType = @"GALLERY_IMAGE";
            photo.TransactionId = autoSavedTransaction.ColumnIndex;
            
            [[IWInkworksService dbHelper] addOrUpdatePhoto:photo];
        }
        
        for (IWDynamicField *dynField in dynamicFields.objectEnumerator) {
            dynField.TransactionId = autoSavedTransaction.ColumnIndex;
            [[IWInkworksService dbHelper] addOrUpdateDynamicField:dynField];
        }
        
    } else {
        //Database stuff here...
        if (originalTransaction == nil) {
            originalTransaction = [[IWTransaction alloc] initWithIndex:-1 formId:listItem.FormId sent:NO username:[IWInkworksService getInstance].loggedInUser savedDate:[NSDate date] addedDate:startDate sentDate:nil originalAddedDate:startDate autoSavedDate:nil formName:listItem.FormName penData:procFormString strokes:strokeFormString status:sending? @"Awaiting" : @"Parked" historyItemIndex:0 hashedPassword:[IWInkworksService getHashedPassword:[IWInkworksService getInstance].loggedInPassword] prepopId:-1 parentTransaction:-1];
        }
        originalTransaction.FormName = listItem.FormName;
        originalTransaction.HashedPassword = [IWInkworksService getHashedPassword:[IWInkworksService getInstance].loggedInPassword];
        originalTransaction.PenDataXml = procFormString;
        originalTransaction.StrokesXml = strokeFormString;
        originalTransaction.SavedDate = [NSDate date];
        originalTransaction.Status = sending ? @"Awaiting" : @"Parked";
        if ([IWInkworksService getInstance].currentPrepopItem) {
            originalTransaction.PrepopId = [IWInkworksService getInstance].currentPrepopItem.PrepopId;
        } else {
            originalTransaction.PrepopId = -1;
        }
        originalTransaction = [[IWInkworksService dbHelper] addOrUpdateTransaction:originalTransaction];
        
        // now do the photo thing
        // first reset attached images...
        [[IWInkworksService dbHelper] resetAttachedPhotos:originalTransaction.ColumnIndex];
        // next check attached form photos
        for (NSUUID *uuid in attachedFormPhotos) {
            NSString *path = [IWFileSystem getFormPhotoPathWithId:listItem.FormId andUUID:uuid];
            IWAttachedPhoto *photo = [[IWAttachedPhoto alloc] init];
            photo.ImageStatus = @"Sending";
            photo.ImagePath = path;
            photo.ImageType = @"FORM_PHOTO";
            photo.ImageUUID = [uuid UUIDString];
            photo.TransactionId = originalTransaction.ColumnIndex;
            
            [[IWInkworksService dbHelper] addOrUpdatePhoto:photo];
        }
        for (PHAsset * asset in attachedGalleryImages) {
            IWAttachedPhoto *photo = [[IWAttachedPhoto alloc] init];
            NSString *path = [NSString stringWithFormat:@"{PH}%@", asset.localIdentifier];
            photo.ImageStatus = @"Sending";
            photo.ImagePath = path;
            photo.ImageType = @"GALLERY_IMAGE";
            photo.TransactionId = originalTransaction.ColumnIndex;
            
            [[IWInkworksService dbHelper] addOrUpdatePhoto:photo];
        }
        
        for (IWDynamicField *dynField in dynamicFields.objectEnumerator) {
            dynField.TransactionId = originalTransaction.ColumnIndex;
            [[IWInkworksService dbHelper] addOrUpdateDynamicField:dynField];
        }
        
        if (sending) {
            originalTransaction.Status = @"Sending";
            [[IWInkworksService dbHelper] addOrUpdateTransaction:originalTransaction];
            if (autoSavedTransaction != nil) {
                if (autoSavedTransaction.ColumnIndex != NSNotFound && autoSavedTransaction.ColumnIndex != -1) {
                    [[IWInkworksService dbHelper] removeTransaction:autoSavedTransaction clearPrepop:NO];
                    autoSavedTransaction = nil;
                }
            }
        }

    }
    return YES;
    
}

#pragma mark Photos

- (void)savePhoto:(NSData *)data {
    NSUUID *newId = [NSUUID UUID];
    NSString *photoPath = [IWFileSystem getFormPhotoPathWithId:listItem.FormId andUUID:newId];
    dispatch_async(dispatch_get_main_queue(), ^{
        [IWFileSystem saveFileWithFileName:photoPath andData:data];
        
        [formPhotos addObject:newId];
        [attachedFormPhotos addObject:newId];
        
        if ([IWInkworksService getInstance].embeddingView != nil) {
            [[IWInkworksService getInstance].embeddingView setImageFromUUID:newId];
        }
    });
    
}


- (void) attachFormPhoto: (NSUUID *)uuid {
    if (![attachedFormPhotos containsObject:uuid])
        [attachedFormPhotos addObject:uuid];
}

- (void) attachGalleryImage: (PHAsset *) asset {
    if (![attachedGalleryImages containsObject:asset])
        [attachedGalleryImages addObject:asset];
}

- (void)removeAttachedFormPhoto:(NSUUID *)uuid {
    if ([attachedFormPhotos containsObject:uuid])
        [attachedFormPhotos removeObject:uuid];
}

- (void) removeAttachedGalleryImage:(PHAsset *)asset {
    if ([attachedGalleryImages containsObject:asset])
        [attachedGalleryImages removeObject:asset];
}

#pragma mark Premade strings

- (NSString *) getStrokesFormHeader: (NSDate *) sendDate strokeCount: (NSNumber *)strokesCount {
    
    NSNumber *startDateNum = [NSNumber numberWithDouble: [startDate timeIntervalSince1970]];
    NSNumber *sentDateNum = [NSNumber numberWithDouble: [sendDate timeIntervalSince1970]];
    
    return [NSString stringWithFormat:@"<rawformdata xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"http://destiny.com/xml/penData\">\n  <form firststroketime=\"%lu\" laststroketime=\"%lu\" appinstancekey=\"%lu\" formtranid=\"1\" strokecount=\"%ld\" tad=\"0\">\n    <pages>\n", [startDateNum longValue], [sentDateNum longValue],(long)listItem.FormId, [strokesCount longValue]];
}

- (NSString *) getStrokesFormCloser {
    return @"    </pages>\n  </form>\n</rawformdata>";
}

- (NSString *) getStrokesPageHeader: (NSNumber *) pageNumber {
    return [NSString stringWithFormat:@"      <page address=\"0\" pageno=\"%lu\">\n        <strokes>\n          <unassigned>\n", [pageNumber longValue] + 1];
}

- (NSString *) getStrokesPageCloser {
    return @"          </unassigned>\n        </strokes>\n      </page>\n";
}

- (NSString *) getStrokeTagForField: (NSString *) fieldId minX: (NSNumber *) minX minY: (NSNumber *) minY maxX: (NSNumber *) maxX maxY: (NSNumber *) maxY{
    NSString *ret = [NSString stringWithFormat:@"            <stroke start=\"0\" duration=\"0\" color=\"0\" linewidth=\"1\" minx=\"%f\" miny=\"%f\" maxx=\"%f\" maxy=\"%f\" fieldid=\"%@\">\n", [minX floatValue], [minY floatValue], [maxX floatValue], [maxY floatValue], fieldId];
    return ret;
}

- (NSString *) getStrokeCloser {
    return @"            </stroke>\n";
}

- (NSString *) getStrokeSampleTagAtX: (NSNumber *) x andY: (NSNumber *) y{
    return [NSString stringWithFormat: @"              <sample x=\"%f\" y=\"%f\" force=\"0\" timestamp=\"0\" />\n", [x floatValue], [y floatValue]];
}

- (NSString *) getProcFormHeader: (NSDate *) sendDate {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:EXT_DATE_FORMAT];
    
    NSString *startDateStr = [formatter stringFromDate:startDate];
    NSString *sendDateStr = [formatter stringFromDate:sendDate];
    
    return [NSString stringWithFormat:@"<procformdata xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"http://destiny.com/xml/procformdata\">\n  <header>\n    <formInfo appinstance=\"%lu\" devrecv=\"%@\" devsent=\"%@\" sysrecv=\"%@\" />\n    <action key=\"43\" datetime=\"%@\" id=\"1\" type=\"entry\" userforename=\"a\" usersurname=\"b\" startdatetime=\"%@\" />\n  </header>\n  <form minrs=\"0\" minnrs=\"0\">\n", (long)listItem.FormId, startDateStr, sendDateStr, sendDateStr, sendDateStr, startDateStr];
}

- (NSString *) getProcFormCloser{
    return @"  </form>\n</procformdata>";
}

- (NSString *) getProcPageTag: (NSNumber *) pageNumber {
    return [NSString stringWithFormat:  @"    <page pageno=\"%d\">\n      <fields>\n", [pageNumber intValue] + 1];
}

- (NSString *) getProcPageCloser {
    return @"      </fields>\n    </page>\n";
}

- (NSString *) getProcFieldTag: (NSString *) fieldId value: (NSString *)value isTickable: (BOOL)tickable isTicked: (BOOL) ticked scanned:(BOOL)scanned{
    return [self getProcFieldTag:fieldId value:value isTickable:tickable isTicked:ticked scanned:scanned dynamic:NO];
}

- (NSString *) getProcFieldTag:(NSString *) fieldId value: (NSString *) value dynamic:(BOOL) dynamic ddVal: (NSString *) ddVal {
    if ([[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] || [[[[[value stringByReplacingOccurrencesOfString:@"/" withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]isEqualToString:@""] ) {
        return [NSString stringWithFormat: @"        <field fieldid=\"%@\">\n          <value actionid=\"1\" actiontype=\"entry\" val=\"\" />\n        </field>\n", fieldId];
    }
    NSString *fixedVal = [value stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    fixedVal = [fixedVal stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    fixedVal = [fixedVal stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    fixedVal = [fixedVal stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"];
    fixedVal = [fixedVal stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return [NSString stringWithFormat: @"        <field fieldid=\"%@\">\n          <value actionid=\"1\" actiontype=\"entry\" val=\"%@\">%@</value>\n        </field>\n", fieldId, ddVal, fixedVal];
    
}

- (NSString *) getProcFieldTag: (NSString *) fieldId value: (NSString *)value isTickable: (BOOL)tickable isTicked: (BOOL) ticked scanned:(BOOL)scanned dynamic:(BOOL)dynamic{
    
    NSString *tickValue = dynamic ? [NSString stringWithFormat:@"DYNAMICTICKED¬¬%@", fieldId] : ticked == YES ? @"true" : @"false";
    
    if (!tickable && ([[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] || [[[[[value stringByReplacingOccurrencesOfString:@"/" withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]isEqualToString:@""] )) {
        return [NSString stringWithFormat: @"        <field fieldid=\"%@\">\n          <value actionid=\"1\" actiontype=\"entry\" />\n        </field>\n", fieldId];
    }
    
    if ([[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] || [[[[[value stringByReplacingOccurrencesOfString:@"/" withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]isEqualToString:@""] ){
        //tickable, no value:
        
        return [NSString stringWithFormat:@"        <field fieldid=\"%@\">\n          <value actionid=\"1\" actiontype=\"entry\" ticked=\"%@\"/>\n        </field>\n", fieldId, tickValue];
    }
    
    if (tickable) {
        //tickable, has value
        
        NSString *fixedVal = [value stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
        fixedVal = [fixedVal stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
        fixedVal = [fixedVal stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
        fixedVal = [fixedVal stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"];
        fixedVal = [fixedVal stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        return [NSString stringWithFormat: @"        <field fieldid=\"%@\">\n          <value actionid=\"1\" actiontype=\"entry\" ticked=\"%@\">%@</value>\n        </field>\n", fieldId, tickValue, fixedVal];
    }
    
    //not tickable, has value
    NSString *fixedVal = [value stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    fixedVal = [fixedVal stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    fixedVal = [fixedVal stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    fixedVal = [fixedVal stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"];
    fixedVal = [fixedVal stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    return [NSString stringWithFormat: @"        <field fieldid=\"%@\">\n          <value actionid=\"1\" actiontype=\"entry\"%@>%@</value>\n        </field>\n", fieldId, scanned ? @" scanned=\"true\"" : @"", fixedVal];
}

@end
