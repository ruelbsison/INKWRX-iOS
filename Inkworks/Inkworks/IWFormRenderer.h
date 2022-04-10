//
//  IWFormRenderer.h
//  Inkworks
//
//  Created by Jamie Duggan on 15/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//
#import "IWZipFormDownloaderDelegate.h"
#import <Foundation/Foundation.h>
@class IWFormDescriptor;
@class IWInkworksListItem;
@class IWTransaction;
@class IWPageServer;
@class CSLinearLayoutView;
@class CSLinearLayoutItem;

@interface IWFormRenderer : NSObject <ZipCompletedDelegate> {
    IWInkworksListItem *listItem;
    IWFormDescriptor *formDescriptor;
    
    BOOL isFormDescriptorReady;
    BOOL formCanvasReady;
    BOOL recalcing;
    UIView *formCanvas;
    NSMutableDictionary *radioGroupManagers;
    NSMutableDictionary *allViews;
    NSMutableDictionary *ISOManagers;
    
    IWTransaction *currentTransaction;
    //id <UITextFieldDelegate, UITextViewDelegate> mainDelegate;
    int pageToRender;
    
    NSMutableDictionary *mandatoryViews;
    NSMutableArray *mandatoryRadioGroups;
    NSMutableDictionary *mandatoryRadioGroupManagers;
    NSMutableDictionary *mandatoryDescriptors;
    
    NSMutableDictionary *dynamicFields;
    NSMutableDictionary *repeatingPanelsLayouts;
    NSMutableDictionary *repeatingFields;
    NSMutableDictionary *repeatingPanels;
    NSMutableDictionary *repeatingDecriptors;
    NSMutableDictionary *repeatingIsoManagers;
    NSMutableDictionary *repeatingRadioManagers;
    NSMutableDictionary *panelLayouts;
    CSLinearLayoutView *panelledView;
    
    NSMutableDictionary *scannedVals;
    
    NSMutableDictionary *repeatingCalcs;
    NSMutableDictionary *repeatingCalcFields;
    
    NSMutableDictionary *panelPointers;
    
    NSMutableDictionary *dynamicPlusButtons;
    NSMutableDictionary *dynamicMinusButtons;
    
    NSMutableDictionary *loadedFieldValues;
    
    NSMutableDictionary *loadedFieldTriggers;
    
    IWPageServer *pageServer;
    bool shouldProcessVisibility;
    
    int freeSpace;
    
    NSNumber *repeatingPanelId;
    NSMutableDictionary *repeatingPanelIds;
    
    NSMutableDictionary *calcInputs;
    
    
    UIColor *mandatoryRed;
}

@property IWInkworksListItem *listItem;
@property IWFormDescriptor *formDescriptor;

@property CSLinearLayoutView *panelledView;

@property BOOL isFormDescriptorReady;
@property BOOL formCanvasReady;
@property BOOL recalcing;

@property NSMutableDictionary *dynamicPlusButtons;
@property NSMutableDictionary *dynamicMinusButtons;

@property UIView *formCanvas;
@property (retain) NSMutableDictionary *radioGroupManagers;
@property (retain) NSMutableDictionary *allViews;
@property (retain) NSMutableDictionary *ISOManagers;
@property (nonatomic, assign) id <UITextFieldDelegate, UITextViewDelegate> mainDelegate;
@property IWTransaction *currentTransaction;

@property NSMutableDictionary *loadedFieldTriggers;

@property NSMutableDictionary *loadedFieldValues;

@property NSMutableDictionary *mandatoryViews;
@property NSMutableArray *mandatoryRadioGroups;
@property NSMutableDictionary *mandatoryRadioGroupManagers;
@property NSMutableDictionary *mandatoryDescriptors;

@property NSMutableDictionary *calcInputs;
@property NSMutableDictionary *repeatingCalcs;
@property NSMutableDictionary *repeatingCalcFields;

@property NSMutableDictionary *dynamicFields;
@property NSMutableDictionary *repeatingPanelsLayouts;
@property NSMutableDictionary *repeatingFields;
@property NSMutableDictionary *repeatingPanels;
@property NSMutableDictionary *repeatingDecriptors;
@property NSMutableDictionary *repeatingIsoManagers;
@property NSMutableDictionary *repeatingRadioManagers;
@property NSMutableDictionary *panelLayouts;
@property NSMutableDictionary *scannedVals;

@property NSMutableDictionary *panelPointers;

@property int freeSpace;

@property NSNumber *repeatingPanelId;
@property NSMutableDictionary *repeatingPanelIds;
@property bool shouldProcessVisibility;
@property IWPageServer *pageServer;

@property UIColor *mandatoryRed;

@property int pageToRender;

- (id) initWithItem: (IWInkworksListItem *) item andTransaction: (IWTransaction *) transaction;
- (void) renderForm;
- (void) renderCanvas;
-(void) triggerPanelField: (NSString *) fieldName value: (BOOL) triggerOn;
- (void) recalculateFields;
- (int) pageCount;
- (void) renderForm:(BOOL)onePage;

- (void) loadPrepopData;
- (void) loadForm: (NSDictionary *) pageInfo;
- (void)loadMandatoryFields:(NSDictionary *)pageInfo;
@end
