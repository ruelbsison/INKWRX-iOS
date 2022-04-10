//
//  IWFormRenderer.m
//  Inkworks
//
//  Created by Jamie Duggan on 15/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWFormRenderer.h"
#import "TBXML.h"
#import "IWFileSystem.h"
#import "IWPageDescriptor.h"

#import "IWRectangleView.h"

#import "IWShapeDescriptor.h"
#import "IWRectangleDescriptor.h"
#import "IWRoundedRectangleDescriptor.h"
#import "IWLineDescriptor.h"
#import "IWCircleDescriptor.h"

#import "IWFieldDescriptor.h"
#import "IWTextLabelDescriptor.h"
#import "IWImageDescriptor.h"

#import "IWIsoFieldDescriptor.h"
#import "IWDateTimeFieldDescriptor.h"
#import "IWDecimalFieldDescriptor.h"
#import "IWNoteFieldDescriptor.h"
#import "IWTickedFieldDescriptor.h"
#import "IWDropdownDescriptor.h"
#import "IWRectElement.h"

#import "IWDrawingFieldDescriptor.h"
#import "IWRadioButtonDescriptor.h"
#import "IWTickBoxDescriptor.h"

#import "IWIsoFieldView.h"
#import "IWTickBox.h"
#import "IWRadioButton.h"
#import "IWRadioButtonManager.h"
#import "IWDropDown.h"
#import "IWClearButton.h"
#import "IWNotesView.h"
#import "IWDecimalFieldView.h"
#import "IWDateTimeFieldView.h"

#import "IWCustomPath.h"
#import "IWDynamicPanel.h"
#import "IWDataButton.h"
#import "IWButtonData.h"

#import "IWNonClippingLabel.h"

#import "IWFormDescriptor.h"
#import "IWPageServer.h"
#import "CSLinearLayoutView.h"
#import "IWInkworksService.h"

#import "IWTabletImageDescriptor.h"

#import "Inkworks-Swift.h"

#import "GDataXMLNode.h"

@implementation IWFormRenderer

@synthesize formCanvasReady, formCanvas,isFormDescriptorReady, currentTransaction, pageToRender,radioGroupManagers, ISOManagers, allViews, listItem, formDescriptor, mainDelegate, mandatoryRadioGroups, mandatoryDescriptors, mandatoryRadioGroupManagers, mandatoryViews, mandatoryRed, recalcing;
@synthesize dynamicFields, repeatingPanelsLayouts, repeatingFields, repeatingPanels, repeatingDecriptors, repeatingIsoManagers, repeatingRadioManagers, repeatingPanelId, repeatingPanelIds, pageServer, panelLayouts, freeSpace, panelledView, panelPointers, scannedVals;
@synthesize dynamicPlusButtons, dynamicMinusButtons, loadedFieldValues, calcInputs, repeatingCalcFields, repeatingCalcs, shouldProcessVisibility, loadedFieldTriggers;

NSDictionary *fonts;
- (id) initWithItem:(IWInkworksListItem *)item andTransaction:(IWTransaction *)transaction{
    self = [super init];
    
    if (self) {
        self.shouldProcessVisibility = YES;
        self.listItem = item;
        self.currentTransaction = transaction;
        self.pageToRender = 0;
        self.mandatoryViews = [NSMutableDictionary dictionary];
        self.mandatoryDescriptors = [NSMutableDictionary dictionary];
        self.mandatoryRadioGroups = [NSMutableArray array];
        self.mandatoryRadioGroupManagers = [NSMutableDictionary dictionary];
        
        self.calcInputs = [NSMutableDictionary dictionary];
        
        self.panelLayouts = [NSMutableDictionary dictionary];
        self.repeatingDecriptors = [NSMutableDictionary dictionary];
        self.panelPointers = [NSMutableDictionary dictionary];
        self.repeatingFields = [NSMutableDictionary dictionary];
        self.repeatingIsoManagers = [NSMutableDictionary dictionary];
        self.repeatingPanels = [NSMutableDictionary dictionary];
        self.repeatingPanelIds = [NSMutableDictionary dictionary];
        self.repeatingPanelsLayouts = [NSMutableDictionary dictionary];
        self.dynamicMinusButtons = [NSMutableDictionary dictionary];
        self.dynamicPlusButtons = [NSMutableDictionary dictionary];
        self.loadedFieldValues = [NSMutableDictionary dictionary];
        self.scannedVals = [NSMutableDictionary dictionary];
        
        self.repeatingCalcs = [NSMutableDictionary dictionary];
        self.repeatingCalcFields = [NSMutableDictionary dictionary];
        self.loadedFieldTriggers = [NSMutableDictionary dictionary];
        self.repeatingRadioManagers = [NSMutableDictionary dictionary];
        self.repeatingPanelId = @0;
        
        //gd.setColor(Color.argb(255, 248, 158, 163));
        
        self.mandatoryRed = [UIColor colorWithRed:248.0/255.0 green:158.0/255.0 blue:163.0/255.0 alpha:1];
        
        
        fonts = @{
                  @"arial narrow": @"ArialNarrow",
                  @"arial":@"ArialMT",
                  @"times new roman":@"TimesNewRomanPSMT",
                  @"times new roman,times":@"TimesNewRomanPSMT",
                  @"times new roman, times":@"TimesNewRomanPSMT",
                  @"tahoma": @"Tahoma"
                };
        
    }
    return self;
}
-(void) completeZip {
    doneZip = YES;
    NSString *formdatafilename = [[IWFileSystem getFormFolderWithId:listItem.FormId] stringByAppendingPathComponent:@"formdata.txt"];
    NSData *data = [NSData dataWithContentsOfFile:formdatafilename options:NSDataReadingMappedIfSafe error:nil];
    NSString *newString = [[NSString alloc] initWithData:data encoding:NSUTF16LittleEndianStringEncoding];
    NSData *newData = [newString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    //TBXML *xmlFile = [[TBXML alloc]initWithXMLData:newData error:&error];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:newData options:0 error:&error];
    
    formDescriptor = [IWFormDescriptor newWithXml:doc];
    pageServer = [[IWPageServer alloc]initWithArray:formDescriptor.pageDescriptors];
    mandatoryRadioGroups = formDescriptor.mandatoryRadioGroups;
    for (IWFieldDescriptor *field in formDescriptor.mandatoryFields) {
        if ([mandatoryDescriptors objectForKey:field.fieldId] == nil) {
            [mandatoryDescriptors setObject:field forKey:field.fieldId];
        }
    }
    
    for (IWPageDescriptor *page in pageServer.pages.objectEnumerator) {
        for (NSString *panel in page.panelPointers.keyEnumerator) {
            [panelPointers setObject:page.panelPointers[panel] forKey:panel];
        }
    }
    
    isFormDescriptorReady = YES;

    
    
    
}
BOOL doneZip = YES;

-(void) renderForm {
    [self renderForm:NO];
}

- (void) renderForm:(BOOL)onePage {
    NSString *formdatafilename = [[IWFileSystem getFormFolderWithId:listItem.FormId] stringByAppendingPathComponent:@"formdata.txt"];
    NSData *data = [NSData dataWithContentsOfFile:formdatafilename options:NSDataReadingMappedIfSafe error:nil];
    //NSString *xstring = [[NSString alloc] initWithData:data encoding:NSUTF16LittleEndianStringEncoding];
    //NSLog(xstring);
    BOOL corruptApp = NO;
    if (data.length == 0) {
        doneZip = NO;
        corruptApp = YES;
        IWZipFormDownloaderDelegate *delZip = [[IWZipFormDownloaderDelegate alloc]initWithFormId:listItem.FormId];
        delZip.completeDelegate = self;
        [delZip start];
    }
        if (corruptApp) {
        return;
    }
    
    NSString *newString = [[NSString alloc] initWithData:data encoding:NSUTF16LittleEndianStringEncoding];
    NSData *newData = [newString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:newData options:0 error:&error];
    //TBXML *xmlFile = [[TBXML alloc]initWithXMLData:newData error:&error];
    
    
    formDescriptor = [IWFormDescriptor newWithXml:doc onePage:onePage];
    pageServer = [[IWPageServer alloc]initWithArray:formDescriptor.pageDescriptors];
    mandatoryRadioGroups = formDescriptor.mandatoryRadioGroups;
    for (IWFieldDescriptor *field in formDescriptor.mandatoryFields) {
        if ([mandatoryDescriptors objectForKey:field.fieldId] == nil) {
            [mandatoryDescriptors setObject:field forKey:field.fieldId];
        }
    }
    
    for (IWPageDescriptor *page in pageServer.pages.objectEnumerator) {
        for (NSString *panel in page.panelPointers.keyEnumerator) {
            [panelPointers setObject:page.panelPointers[panel] forKey:panel];
        }
    }
    
    isFormDescriptorReady = YES;
}

- (UIView *) getLine: (IWLineDescriptor *)lineDesc{
    NSString *lineType = lineDesc.lineType;
    float x = MIN(lineDesc.x1, lineDesc.x2);
    float y = MIN(lineDesc.y1, lineDesc.y2);
    float width;
    float height;
    if ([lineType isEqualToString:@"H"]){
        height = lineDesc.strokeWidth;
        width = MAX(lineDesc.x1, lineDesc.x2) - MIN(lineDesc.x1, lineDesc.x2);
    } else {
        width = lineDesc.strokeWidth;
        height = MAX(lineDesc.y1, lineDesc.y2) - MIN(lineDesc.y1, lineDesc.y2);
    }
    
    CGRect frame = CGRectMake(x, y, width, height);
    UIView *v = [[UIView alloc] initWithFrame:frame];
    v.tag = 1000;
    v.backgroundColor = lineDesc.strokeColor;
    return v;
}

- (IWCircleView *) getCircle:(IWCircleDescriptor *) circDesc {
    CGRect frame = CGRectMake(circDesc.cX - circDesc.r, circDesc.cY - circDesc.r, circDesc.r * 2, circDesc.r*2);
    IWCircleView *v = [[IWCircleView alloc] initWithFrame:frame r:circDesc.r fill:circDesc.fillColor stroke:circDesc.strokeColor strokeWidth:circDesc.strokeWidth];
    v.tag = 1000;
    return v;
}

- (IWRectangleView *) getRectangle: (IWRectangleDescriptor *) rectDesc{
    CGRect frame = CGRectMake(rectDesc.x, rectDesc.y, rectDesc.width, rectDesc.height);
    IWRectangleView *v = [[IWRectangleView alloc] initWithFrame:frame fillColor:rectDesc.fillColor stroke:rectDesc.strokeColor strokeWidth:rectDesc.strokeWidth];
    v.tag = 1000;
    return v;
}

- (IWRectangleView *) getRoundedRectangle: (IWRoundedRectangleDescriptor *) rectDesc{
    CGRect frame = CGRectMake(rectDesc.x, rectDesc.y, rectDesc.width, rectDesc.height);
    IWRectangleView *v = [[IWRectangleView alloc] initWithFrame:frame fillColor:rectDesc.fillColor stroke:rectDesc.strokeColor strokeWidth:rectDesc.strokeWidth cornerRadius:rectDesc.rX];
    v.tag = 1000;
    return v;
}

- (UIImageView *) getImageView: (IWImageDescriptor *) imageDesc{
    CGRect frame = CGRectMake(imageDesc.x, imageDesc.y, imageDesc.width, imageDesc.height);
    
    UIImageView *v = [[UIImageView alloc] initWithFrame:frame];
    
    NSString *imageFileName = [NSString stringWithFormat:@"image%@.jpg", imageDesc.imageId];
    NSString *formFolder = [IWFileSystem getFormFolderWithId:listItem.FormId];
    NSString *imagePath = [formFolder stringByAppendingPathComponent:imageFileName];
    
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
    [v setImage:image];
    v.tag = 1000;
    
    return v;
}

- (IWNonClippingLabel *) getTextLabel: (IWTextLabelDescriptor *) labelDesc{
    
    
//    NSString *fontName = [fonts objectForKey:labelDesc.fontFamily != nil ? [labelDesc.fontFamily lowercaseString] : @"arial"];
//    if (!fontName) {
//        fontName = @"ArialMT";
//    }
//    NSString *fontAddition;
//    if ([labelDesc.textWeight isEqualToString:@"bold"]){
//        fontAddition = @"-Bold";
//    } else {
//        fontAddition = @"";
//    }
//   
//    
//    NSString *newFontName = [fontName stringByAppendingString:fontAddition];
//   
//    if ([newFontName isEqualToString:@"ArialMT-Bold"]){
//        newFontName = @"Arial-BoldMT";
//    }
//    if ([newFontName isEqualToString:@"TimesNewRomanPSMT-Bold"]){
//        newFontName = @"TimesNewRomanPS-BoldMT";
//    }
//    
//    UIFont *font = [UIFont fontWithName: newFontName size:(((float)labelDesc.textSize) / 3) * 4];
//    //NSMutableDictionary *underlineAttribute = [NSMutableDictionary dictionaryWithDictionary: @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)}];
//    
//    
//    NSMutableDictionary *textAttributes = [NSMutableDictionary dictionary];
//    [textAttributes setObject:font forKey:NSFontAttributeName];
//    
//    NSString *test = labelDesc.textValue;
//    CGSize size = [test sizeWithAttributes:textAttributes];
//    
//    if ([labelDesc.fontDecoration isEqualToString:@"underline"]){
//        [textAttributes setObject:@(NSUnderlineStyleSingle) forKey:NSUnderlineStyleAttributeName];
//    }
//    if ([labelDesc.textStyle isEqualToString:@"italic"]){
//        [textAttributes setObject:@0.20 forKey:NSObliquenessAttributeName];
//    }
//    [textAttributes setObject:labelDesc.textColor forKey:NSForegroundColorAttributeName];
    //myLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Test string" attributes:underlineAttribute];
    NSRange r = NSMakeRange(0, labelDesc.attString.length);
    UIFont *font = [labelDesc.attString attributesAtIndex:0 effectiveRange:&r][NSFontAttributeName];
    CGRect frame = CGRectMake(labelDesc.x - GUTTER, labelDesc.y + labelDesc.yOffset - font.ascender, labelDesc.width, labelDesc.height);
    
    IWNonClippingLabel *v = [[IWNonClippingLabel alloc] initWithFrame:frame];
    
//    [v setFont:font];
//    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:labelDesc.textValue attributes:textAttributes];
//    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
//    [style setLineSpacing: 0];
//    [attString addAttribute:NSParagraphStyleAttributeName
//                       value:style
//                       range:NSMakeRange(0, labelDesc.textValue.length)];
    v.attributedText = labelDesc.attString;
    [v setNumberOfLines:0];
    [v sizeToFit];
//    CGRect newFrame = v.frame;
//    newFrame.size.width += 2*GUTTER;
//    v.frame = newFrame;
    v.tag = 1000;
    return v;
    
}

- (IWTabletImageView *) getTabletImageView: (IWTabletImageDescriptor *) tabImgDesc {
    CGRect frame = CGRectMake(tabImgDesc.x, tabImgDesc.y, tabImgDesc.width, tabImgDesc.height);
    IWTabletImageView *v = [[IWTabletImageView alloc] initWithFrame:frame strokeColor:tabImgDesc.strokeColor fillColor:tabImgDesc.fillColor strokeWidth:tabImgDesc.strokeWidth cornerRadius:tabImgDesc.rX];
    return v;
}

- ( IWDropDown *) getDropdown: (IWDropdownDescriptor *) dropdownDesc{
    CGRect frame = CGRectMake(dropdownDesc.x, dropdownDesc.y, dropdownDesc.width, dropdownDesc.height);
    
    NSString *lexiconFileName = [NSString stringWithFormat:@"lexicon%@.txt", dropdownDesc.lexiconId];
    NSString *formFolder = [IWFileSystem getFormFolderWithId:listItem.FormId];
    NSString *lexiconPath = [formFolder stringByAppendingPathComponent:lexiconFileName];
    
    NSError *error;
    NSString *lexiconFull = [NSString stringWithContentsOfFile:lexiconPath encoding:NSUTF16LittleEndianStringEncoding error:&error];
    NSArray *lexicon = [lexiconFull componentsSeparatedByString:@"\r\n"];
    NSMutableArray *newLex = [lexicon mutableCopy];
    NSString *newFirstItem = [newLex objectAtIndex:0];
    NSMutableString *newString = [newFirstItem mutableCopy];
    [newString replaceCharactersInRange:NSMakeRange(0, 1) withString:@""];
    [newLex replaceObjectAtIndex:0 withObject:newString];
    NSMutableArray *trimmedLex = [NSMutableArray array];
    for (NSString *s in newLex) {
        [trimmedLex addObject:[s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }
    dropdownDesc.lexicon = [trimmedLex copy];
    
    IWDropDown *v = [[IWDropDown alloc] initWithFrame:frame andLexicon:dropdownDesc.lexicon andStrokeColor:dropdownDesc.strokeColor descriptor:dropdownDesc];
    if (dropdownDesc.isCalc) {
        for (IWCalcList *calc in formDescriptor.formCalcFields) {
            for (NSString *input in calc.inputs) {
                if ([input isEqualToString:dropdownDesc.fdtFieldName]) {
                    [calcInputs setObject:v forKey:input];
                }
            }
        }
    }
    return v;
    
}

- (IWIsoFieldView *) getIsoField: (IWIsoFieldDescriptor *) isoDesc{
    CGRect frame = CGRectMake(isoDesc.x, isoDesc.y, isoDesc.width, isoDesc.height);
    
    IWIsoFieldView *v = [[IWIsoFieldView alloc] initWithFrame:frame descriptor:isoDesc andRects:isoDesc.rectElements andStrokeColor:isoDesc.strokeColor delegate:mainDelegate];
    if (isoDesc.isCalcField && isoDesc.repeatingIndex == -1) {
        //calculated field...
        [v setCalc];
        for (IWCalcList *c in formDescriptor.formCalcFields) {
            if ([c.fieldName isEqualToString: isoDesc.fdtFieldName]) {
                c.fieldView = v;
                break;
            }
        }
    }
    
    if (isoDesc.repeatingIndex == -1) {
        for (IWCalcList *calc in formDescriptor.formCalcFields) {
            for (NSString *input in calc.inputs) {
                if ([input isEqualToString:isoDesc.fdtFieldName]) {
                    [calcInputs setObject:v forKey:input];
                }
            }
        }
    }
    
    v.mainDelegate = mainDelegate;
    return v;
}

- (IWTickBox *) getTickBox: (IWTickBoxDescriptor *) tbDesc {
    CGRect frame = CGRectMake(tbDesc.x - 5, tbDesc.y - 5, tbDesc.width + 10, tbDesc.height + 10);
    
    IWTickBox *v = [[IWTickBox alloc] initWithFrame:frame andStrokeColor:tbDesc.strokeColor descriptor:tbDesc];
    
    return v;
}

- (IWRadioButton *) getRadioButton: (IWRadioButtonDescriptor *) rbDesc {
    CGRect frame = CGRectMake(rbDesc.x, rbDesc.y, rbDesc.width - 5, rbDesc.height - 5);
    
    IWRadioButton *v = [[IWRadioButton alloc] initWithFrame:frame andStrokeColor:rbDesc.strokeColor descriptor:rbDesc];
    
    return v;
}

- (IWDrawingField *) getDrawingFieldWithNotes: (IWNoteFieldDescriptor *)nDesc {
    NSArray *rects = nDesc.rectElements;
    IWRectElement *firstRect = [rects firstObject];
    IWRectElement *lastRect = [rects lastObject];
    CGRect frame = CGRectMake(nDesc.x, nDesc.y, firstRect.width, (lastRect.y + lastRect.height) - firstRect.y);
    IWDrawingField *v = [[IWDrawingField alloc] initWithFrame:frame andStrokeColor:nDesc.strokeColor noteDescriptor:nDesc];
    return v;
}

- (IWDrawingField *) getDrawingField: (IWDrawingFieldDescriptor *)dDesc{
    CGRect frame = CGRectMake(dDesc.x, dDesc.y, dDesc.width, dDesc.height);
    
    IWDrawingField *v = [[IWDrawingField alloc] initWithFrame:frame andStrokeColor:dDesc.strokeColor descriptor:dDesc];
    
    return v;
}

- (IWNotesView *) getNotesView: (IWNoteFieldDescriptor *)nDesc {
    CGRect frame = CGRectMake(nDesc.x,  nDesc.y, nDesc.width, nDesc.height);
    IWNotesView *v = [[IWNotesView alloc]initWithFrame:frame andStrokeColor:nDesc.strokeColor descriptor:nDesc];
    
    v.mainDelegate = mainDelegate;
    
    return v;
    
    
}

- (IWDecimalFieldView *) getDecimalField: (IWDecimalFieldDescriptor *)decDesc {
    CGRect frame = CGRectMake(decDesc.x, decDesc.y, decDesc.width, decDesc.height);
    NSMutableArray *labels = [NSMutableArray array];
    for (IWTextLabelDescriptor *tld in decDesc.textLabelDescriptors){
        IWNonClippingLabel *l = [self getTextLabel:tld];
        CGRect lFrame = CGRectMake(l.frame.origin.x - frame.origin.x, l.frame.origin.y - frame.origin.y, l.frame.size.width, l.frame.size.height);
        l.frame = lFrame;
        [labels addObject:l];
    }
    IWDecimalFieldView *v = [[IWDecimalFieldView alloc] initWithFrame:frame descriptor:decDesc andRects:decDesc.rectElements andStrokeColor:decDesc.strokeColor andTextLabels:labels delegate:mainDelegate];
    if (decDesc.isCalcField && decDesc.repeatingIndex == -1) {
        //calculated field...
        [v setCalc];
        for (IWCalcList *c in formDescriptor.formCalcFields) {
            if ([c.fieldName isEqualToString: decDesc.fdtFieldName]) {
                c.fieldView = v;
                break;
            }
        }
    }
    
    if (decDesc.repeatingIndex == -1) {
        for (IWCalcList *calc in formDescriptor.formCalcFields) {
            
            for (NSString *input in calc.inputs) {
                if ([input isEqualToString:decDesc.fdtFieldName]) {
                    [calcInputs setObject:v forKey:input];
                }
            }
        }
    }

    
    
    return v;
    
}

- (IWDateTimeFieldView *) getDateTimeField: (IWDateTimeFieldDescriptor *) dateDesc {
    CGRect frame = CGRectMake(dateDesc.x, dateDesc.y, dateDesc.width, dateDesc.height);
    NSMutableArray *labels = [NSMutableArray array];
    for (IWTextLabelDescriptor *tld in dateDesc.textLabelDescriptors){
        IWNonClippingLabel *l = [self getTextLabel:tld];
        CGRect lFrame = CGRectMake(l.frame.origin.x - frame.origin.x, l.frame.origin.y - frame.origin.y, l.frame.size.width, l.frame.size.height);
        l.frame = lFrame;
        [labels addObject:l];
    }
    IWDateTimeFieldView *v = [[IWDateTimeFieldView alloc] initWithFrame:frame descriptor:dateDesc andRects:dateDesc.rectElements andStrokeColor:dateDesc.strokeColor andTextLabels:labels delegate:mainDelegate];
    return v;
}
-(CSLinearLayoutView *) getFormLayout: (IWPageDescriptor *) page {
    CSLinearLayoutView *ll = [[CSLinearLayoutView alloc]initWithFrame:CGRectMake(0, 0, page.pageWidth, page.pageHeight)];
    [ll setScrollEnabled:NO];
    //ll.autoAdjustContentSize = NO;
    ll.orientation = CSLinearLayoutViewOrientationVertical;
    NSMutableDictionary *orderedPanels = [NSMutableDictionary dictionary];
    for (IWDynamicPanel *p in page.panels) {
        if (p.shouldMoveFieldsBelow || p.repeatingPanel) {
            [orderedPanels setObject:[NSString stringWithFormat:@"%p", p] forKey:[NSNumber numberWithFloat:p.rectArea.y]];
        }
    }
    if ([orderedPanels count] ==0) {
        return nil;
    }
    
    //NSArray *ordKeys = [[orderedPanels allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    UIView *firstView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, page.pageWidth, [[[[orderedPanels allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:0] floatValue])];
    float formHeight = firstView.frame.size.height;
    CSLinearLayoutItem *firstItem = [CSLinearLayoutItem layoutItemForView:firstView];
    [ll addItem:firstItem];
    for (NSNumber *top in [[orderedPanels allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
        if (formHeight !=[top floatValue]) {
            //Need to add padding
            UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, page.pageWidth, [top floatValue]-formHeight)];
            //paddingView.backgroundColor = [UIColor greenColor];
            formHeight +=paddingView.frame.size.height;
            CSLinearLayoutItem *paddingItem = [CSLinearLayoutItem layoutItemForView:paddingView];
            [ll addItem:paddingItem];
        }
        NSString *panelAddress = orderedPanels[top];
        IWDynamicPanel *panel = page.panelPointers[panelAddress];
        UIView  *panelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, page.pageWidth, panel.rectArea.height)];
        //panelView.backgroundColor = [UIColor blueColor];
        formHeight += panelView.frame.size.height;
        if (panel.repeatingPanel) {
            CSLinearLayoutView *repeatingLayout = [[CSLinearLayoutView alloc] initWithFrame:CGRectMake(0, 0, page.pageWidth, panel.rectArea.height)];
            [repeatingLayout setScrollEnabled:NO];
            repeatingLayout.autoAdjustFrameSize = YES;
            repeatingLayout.autoAdjustContentSize = NO;
            repeatingLayout.orientation = CSLinearLayoutViewOrientationVertical;
            [repeatingPanels setObject:repeatingLayout forKey:panelAddress];
            [repeatingPanelsLayouts setObject:[NSMutableArray array] forKey:panelAddress];
            UIView *firstLayout = [[UIView alloc] initWithFrame:CGRectMake(0, 0, page.pageWidth, panel.rectArea.height)];
            CSLinearLayoutItem *firstLayoutItem = [CSLinearLayoutItem layoutItemForView:firstLayout];
            [repeatingPanelsLayouts[panelAddress] addObject:firstLayoutItem];
            [repeatingLayout addItem:firstLayoutItem];
            [panelView addSubview:repeatingLayout];
            
        }
        CSLinearLayoutItem *panelItem = [CSLinearLayoutItem layoutItemForView:panelView];
        [ll addItem:panelItem];
        [panelLayouts setObject:panelItem forKey:panelAddress];
        if (!panel.shouldShowPanel ) {
            CGRect rect = CGRectMake(0, 0, page.pageWidth, 0);
            panelView.frame = rect;
            [panelView setHidden:YES];
        }
    }
    if (formHeight <page.pageHeight) {
        UIView *lastView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, page.pageWidth, page.pageHeight-formHeight)];
        CSLinearLayoutItem *lastItem = [CSLinearLayoutItem layoutItemForView:lastView];
        [ll addItem:lastItem];
    }
    
    
    
    return ll;
}

-(void) addView:(UIView *) view toPanelledView:(CSLinearLayoutView *) panel {
    [self addView:view toPanelledView:panel button:NO strokeView:nil];
    
    
}

-(void) addView:(UIView *) view toPanelledView:(CSLinearLayoutView *) panel button:(BOOL) isButton strokeView: (IWDrawingField *) sv {
    int currentHeight = 0;
    int currentTop = 0;
    for (int i = 0; i<panel.items.count; i++) {
        CSLinearLayoutItem *belongsTo = (CSLinearLayoutItem *) panel.items [i];
        currentTop = currentHeight;
        if (belongsTo.view.frame.size.height == 0) {
            for (NSString *pointer in panelLayouts.keyEnumerator) {
                if (panelLayouts[pointer] == belongsTo) {
                    currentHeight += ((IWDynamicPanel *)panelPointers[pointer]).rectArea.height;
                }
            }
        } else {
            currentHeight += belongsTo.view.frame.size.height;
        }
        UIView *belongsToView = belongsTo.view;
//        if (belongsToView.subviews.count>0 && [belongsToView.subviews[0] isKindOfClass:[CSLinearLayoutView class]]) {
//            for (NSString *pointer in repeatingPanels.keyEnumerator) {
//                IWDynamicPanel *dpanel = panelPointers[pointer];
//                CSLinearLayoutView *ll = repeatingPanels[pointer];
//                if (ll == belongsToView.subviews[0]) {
//                    currentHeight += dpanel.rectArea.height;
//                    break;
//                }
//            }
//            continue;
//        }
        
        if (view.frame.origin.y < currentHeight) {
            if (!isButton) {
                view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y - currentTop, view.frame.size.width, view.frame.size.height);
            }
            
            if (belongsToView.subviews.count > 0 && [belongsToView.subviews[0] isKindOfClass:[CSLinearLayoutView class]]) {
                CSLinearLayoutView *innerLayout = belongsToView.subviews[0];
                UIView *innerView = ((CSLinearLayoutItem *) innerLayout.items[0]).view;
                [innerView addSubview:view];
            } else {
                [belongsToView addSubview:view];
            }
            break;
        }
        
    }
    
    
}


-(void) handleFieldDescriptor:(IWFieldDescriptor *) fieldDescriptor page:(IWPageDescriptor *) page panelledView:(CSLinearLayoutView *) panelledV panelView:(UIView *) panelView panelTop:(int) panelTop panelLeft:(int) panelLeft {
    [self handleFieldDescriptor:fieldDescriptor page:page panelledView:panelledV panelView:panelView panelTop:panelTop panelLeft:panelLeft repeatingPanel:nil repeatingIndex:0];
    
}

-(void) handleFieldDescriptor:(IWFieldDescriptor *) fieldDesc page:(IWPageDescriptor *) page panelledView:(CSLinearLayoutView *) panelledV panelView:(UIView *) panelView panelTop:(int) panelTop panelLeft:(int) panelLeft repeatingPanel:(IWDynamicPanel *) repeatingPanel repeatingIndex:(int) repeatingIndex {
    if ([fieldDesc isKindOfClass:[IWTabletImageDescriptor class]]) {
        IWTabletImageView *v = [self getTabletImageView:(IWTabletImageDescriptor *)fieldDesc];
        if (repeatingPanel) {
            NSString *repeatingPointer = [NSString stringWithFormat:@"%p", repeatingPanel];
            if (!repeatingFields[repeatingPointer]) {
                [repeatingFields setObject:[NSMutableArray array] forKey:repeatingPointer];
            }
            if (((NSMutableArray *)repeatingFields[repeatingPointer]).count <= repeatingIndex) {
                [((NSMutableArray *)repeatingFields[repeatingPointer]) addObject:[NSMutableDictionary dictionary]];
            }
            if (!repeatingDecriptors[repeatingPointer]) {
                [repeatingDecriptors setObject:[NSMutableArray array] forKey:repeatingPointer];
            }
            if (((NSMutableArray *) repeatingDecriptors[repeatingPointer]).count <= repeatingIndex) {
                [((NSMutableArray *)repeatingDecriptors[repeatingPointer]) addObject:[NSMutableArray array]];
            }
            
            [((NSMutableDictionary *) ((NSMutableArray *) repeatingFields[repeatingPointer])[repeatingIndex]) setObject:v forKey:[NSValue valueWithNonretainedObject:fieldDesc]];
            [((NSMutableArray *) ((NSMutableArray *)repeatingDecriptors[repeatingPointer])[repeatingIndex]) addObject:fieldDesc];
        } else {
            [allViews setObject:v forKey:fieldDesc.fieldId];
        }
        
        if (panelView) {
            v.frame = CGRectMake(v.frame.origin.x - panelLeft, v.frame.origin.y - panelTop, v.frame.size.width, v.frame.size.height);
            [panelView addSubview:v];
        } else {
            if (panelledV) {
                [self addView:v toPanelledView:panelledV];
            } else {
                [formCanvas addSubview:v];
            }
        }
    } else if ([fieldDesc isKindOfClass:[IWDateTimeFieldDescriptor class]]){
        IWDateTimeFieldView *v = [self getDateTimeField:(IWDateTimeFieldDescriptor *)fieldDesc];
        if (repeatingPanel) {
            NSString *repeatingPointer = [NSString stringWithFormat:@"%p", repeatingPanel];
            if (!repeatingFields[repeatingPointer]) {
                [repeatingFields setObject:[NSMutableArray array] forKey:repeatingPointer];
            }
            if (((NSMutableArray *) repeatingFields[repeatingPointer]).count <= repeatingIndex) {
                [((NSMutableArray *) repeatingFields[repeatingPointer]) addObject:[NSMutableDictionary dictionary]];
            }
            if (!repeatingDecriptors[repeatingPointer]) {
                [repeatingDecriptors setObject:[NSMutableArray array] forKey:repeatingPointer];
            }
            if (((NSMutableArray *) repeatingDecriptors[repeatingPointer]).count <= repeatingIndex) {
                [((NSMutableArray *) repeatingDecriptors[repeatingPointer]) addObject:[NSMutableArray array]];

            }

            [((NSMutableDictionary *) ((NSMutableArray *) repeatingFields[repeatingPointer])[repeatingIndex]) setObject:v forKey:[NSValue valueWithNonretainedObject:fieldDesc]];
            [((NSMutableArray *) ((NSMutableArray *)repeatingDecriptors[repeatingPointer])[repeatingIndex]) addObject:fieldDesc];
        } else {
            [allViews setObject:v forKey:fieldDesc.fieldId];
        }
        
        if (panelView) {
            v.frame = CGRectMake(v.frame.origin.x - panelLeft, v.frame.origin.y - panelTop, v.frame.size.width, v.frame.size.height);
            [panelView addSubview:v];
        } else {
            if (panelledV) {
                [self addView:v toPanelledView:panelledV];
            } else {
                [formCanvas addSubview:v];
            }
        }
        
        
        if (fieldDesc.mandatory) {
            [v setMand:YES];
            [mandatoryViews setObject:v forKey:[fieldDesc repeatingFieldId]];
        }
    } else if ([fieldDesc isKindOfClass:[IWDecimalFieldDescriptor class]]){
        IWDecimalFieldView *v = [self getDecimalField:(IWDecimalFieldDescriptor *)fieldDesc];
        if (repeatingPanel) {
            NSString *repeatingPointer = [NSString stringWithFormat:@"%p", repeatingPanel];
            if (!repeatingFields[repeatingPointer]) {
                [repeatingFields setObject:[NSMutableArray array] forKey:repeatingPointer];
            }
            if (((NSMutableArray *) repeatingFields[repeatingPointer]).count <= repeatingIndex) {
                [((NSMutableArray *) repeatingFields[repeatingPointer]) addObject:[NSMutableDictionary dictionary]];
            }
            if (!repeatingDecriptors[repeatingPointer]) {
                [repeatingDecriptors setObject:[NSMutableArray array] forKey:repeatingPointer];
            }
            if (((NSMutableArray *) repeatingDecriptors[repeatingPointer]).count <= repeatingIndex) {
                [((NSMutableArray *) repeatingDecriptors[repeatingPointer]) addObject:[NSMutableArray array]];

            }

            
            [((NSMutableDictionary *) ((NSMutableArray *) repeatingFields[repeatingPointer])[repeatingIndex]) setObject:v forKey:[NSValue valueWithNonretainedObject:fieldDesc]];
            [((NSMutableArray *) ((NSMutableArray *)repeatingDecriptors[repeatingPointer])[repeatingIndex]) addObject:fieldDesc];
        } else {
            [allViews setObject:v forKey:fieldDesc.fieldId];
        }

        if (panelView) {
            v.frame = CGRectMake(v.frame.origin.x - panelLeft, v.frame.origin.y - panelTop, v.frame.size.width, v.frame.size.height);
            [panelView addSubview:v];
        } else {
            if (panelledV) {
                [self addView:v toPanelledView:panelledV];
            } else {
                [formCanvas addSubview:v];
            }
        }

        if (fieldDesc.mandatory) {
            [v setMand:YES];
            [mandatoryViews setObject:v forKey:[fieldDesc repeatingFieldId]];
        }
    } else if ([fieldDesc isKindOfClass:[IWIsoFieldDescriptor class]]){
        IWIsoFieldView *v = [self getIsoField:((IWIsoFieldDescriptor *)fieldDesc)];
        if (repeatingPanel) {
            NSString *repeatingPointer = [NSString stringWithFormat:@"%p", repeatingPanel];
            if (!repeatingFields[repeatingPointer]) {
                [repeatingFields setObject:[NSMutableArray array] forKey:repeatingPointer];
            }
            if (((NSMutableArray *) repeatingFields[repeatingPointer]).count <= repeatingIndex) {
                [((NSMutableArray *) repeatingFields[repeatingPointer]) addObject:[NSMutableDictionary dictionary]];
            }
            [((NSMutableDictionary *) ((NSMutableArray *) repeatingFields[repeatingPointer])[repeatingIndex]) setObject:v forKey:[NSValue valueWithNonretainedObject:fieldDesc]];
            
            if (!repeatingDecriptors[repeatingPointer]) {
                [repeatingDecriptors setObject:[NSMutableArray array] forKey:repeatingPointer];
            }
            if (((NSMutableArray *)repeatingDecriptors[repeatingPointer]).count <= repeatingIndex) {
                [((NSMutableArray *)repeatingDecriptors[repeatingPointer]) addObject:[NSMutableArray array]];
            }
            [((NSMutableArray *) ((NSMutableArray *)repeatingDecriptors[repeatingPointer])[repeatingIndex]) addObject:fieldDesc];
        } else {
            [allViews setObject:v forKey:fieldDesc.fieldId];
        }

        if (panelView) {
            v.frame = CGRectMake(v.frame.origin.x - panelLeft, v.frame.origin.y - panelTop, v.frame.size.width, v.frame.size.height);
            [panelView addSubview:v];
        } else {
            if (panelledV) {
                [self addView:v toPanelledView:panelledV];
            } else {
                [formCanvas addSubview:v];
            }
        }

        if (fieldDesc.mandatory) {
            [v setMand:YES];
            [mandatoryViews setObject:v forKey:[fieldDesc repeatingFieldId]];
        }
    } else if ([fieldDesc isKindOfClass:[IWDropdownDescriptor class]]){
        IWDropDown *v = [self getDropdown:(IWDropdownDescriptor *) fieldDesc];
        if (repeatingPanel) {
            NSString *repeatingPointer = [NSString stringWithFormat:@"%p", repeatingPanel];
            if (!repeatingFields[repeatingPointer]) {
                [repeatingFields setObject:[NSMutableArray array] forKey:repeatingPointer];
            }
            if (((NSMutableArray *) repeatingFields[repeatingPointer]).count <= repeatingIndex) {
                [((NSMutableArray *) repeatingFields[repeatingPointer]) addObject:[NSMutableDictionary dictionary]];
            }
            if (!repeatingDecriptors[repeatingPointer]) {
                [repeatingDecriptors setObject:[NSMutableArray array] forKey:repeatingPointer];
            }
            if (((NSMutableArray *) repeatingDecriptors[repeatingPointer]).count <= repeatingIndex) {
                [((NSMutableArray *) repeatingDecriptors[repeatingPointer]) addObject:[NSMutableArray array]];

            }
            
            [((NSMutableDictionary *) ((NSMutableArray *) repeatingFields[repeatingPointer])[repeatingIndex]) setObject:v forKey:[NSValue valueWithNonretainedObject:fieldDesc]];
            [((NSMutableArray *) ((NSMutableArray *)repeatingDecriptors[repeatingPointer])[repeatingIndex]) addObject:fieldDesc];
        } else {
            [allViews setObject:v forKey:fieldDesc.fieldId];
        }

        if (panelView) {
            v.frame = CGRectMake(v.frame.origin.x - panelLeft, v.frame.origin.y - panelTop, v.frame.size.width, v.frame.size.height);
            [panelView addSubview:v];
        } else {
            if (panelledV) {
                [self addView:v toPanelledView:panelledV];
            } else {
                [formCanvas addSubview:v];
            }
        }

        if (fieldDesc.mandatory) {
            v.layer.backgroundColor = [mandatoryRed CGColor];
            [mandatoryViews setObject:v forKey:[fieldDesc repeatingFieldId]];
        }
    } else if ([fieldDesc isKindOfClass:[IWTickBoxDescriptor class]]){
        IWTickBox *v = [self getTickBox:(IWTickBoxDescriptor *)fieldDesc];
        if (repeatingPanel) {
            NSString *repeatingPointer = [NSString stringWithFormat:@"%p", repeatingPanel];
            if (!repeatingFields[repeatingPointer]) {
                [repeatingFields setObject:[NSMutableArray array] forKey:repeatingPointer];
            }
            if (((NSMutableArray *) repeatingFields[repeatingPointer]).count <= repeatingIndex) {
                [((NSMutableArray *) repeatingFields[repeatingPointer]) addObject:[NSMutableDictionary dictionary]];
            }
            if (!repeatingDecriptors[repeatingPointer]) {
                [repeatingDecriptors setObject:[NSMutableArray array] forKey:repeatingPointer];
            }
            if (((NSMutableArray *) repeatingDecriptors[repeatingPointer]).count <= repeatingIndex) {
                [((NSMutableArray *) repeatingDecriptors[repeatingPointer]) addObject:[NSMutableArray array]];

            }

            
            [((NSMutableDictionary *) ((NSMutableArray *) repeatingFields[repeatingPointer])[repeatingIndex]) setObject:v forKey:[NSValue valueWithNonretainedObject:fieldDesc]];
            [((NSMutableArray *) ((NSMutableArray *)repeatingDecriptors[repeatingPointer])[repeatingIndex]) addObject:fieldDesc];
        } else {
            [allViews setObject:v forKey:fieldDesc.fieldId];
        }

        if (panelView) {
            v.frame = CGRectMake(v.frame.origin.x - panelLeft, v.frame.origin.y - panelTop, v.frame.size.width, v.frame.size.height);
            [panelView addSubview:v];
        } else {
            if (panelledV) {
                [self addView:v toPanelledView:panelledV];
            } else {
                [formCanvas addSubview:v];
            }
        }

        if (fieldDesc.mandatory) {
            v.layer.backgroundColor = [mandatoryRed CGColor];
            [mandatoryViews setObject:v forKey:[fieldDesc repeatingFieldId]];
        }
    } else if ([fieldDesc isKindOfClass:[IWNoteFieldDescriptor class]]){
        IWNoteFieldDescriptor *noteFD = (IWNoteFieldDescriptor *)fieldDesc;
        UIView *v = nil;
        if (noteFD.isGraphical) {
            v = [self getDrawingFieldWithNotes:noteFD];
            CGRect frame = v.frame;
            CGFloat left = frame.origin.x + frame.size.width;
            CGFloat top = frame.origin.y;
            CGRect buttonFrame = CGRectMake(left, top, 25, 25);
            IWClearButton *clearButton = [[IWClearButton alloc] initWithFrame:buttonFrame];
            [clearButton setBackgroundImage:[UIImage imageNamed:@"clear_icon_01.png"] forState:UIControlStateNormal];
            [clearButton setBackgroundImage:[UIImage imageNamed:@"clear_icon_02.png"] forState:UIControlStateSelected];
            clearButton.drawingField = (IWDrawingField *)v;
            [clearButton addTarget:self action:@selector(clearButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            
            if (panelView) {
                clearButton.frame = CGRectMake(clearButton.frame.origin.x - panelLeft, clearButton.frame.origin.y - panelTop, clearButton.frame.size.width, clearButton.frame.size.height);
                [panelView addSubview:clearButton];
            } else {
                if (panelledV) {
                    [self addView:clearButton toPanelledView:panelledV];
                    
                } else {
                    [formCanvas addSubview:clearButton];
                }
            }
        } else {
        
            v = [self getNotesView:(IWNoteFieldDescriptor *)fieldDesc];
        }
        if (repeatingPanel) {
            NSString *repeatingPointer = [NSString stringWithFormat:@"%p", repeatingPanel];
            if (!repeatingFields[repeatingPointer]) {
                [repeatingFields setObject:[NSMutableArray array] forKey:repeatingPointer];
            }
            if (((NSMutableArray *) repeatingFields[repeatingPointer]).count <= repeatingIndex) {
                [((NSMutableArray *) repeatingFields[repeatingPointer]) addObject:[NSMutableDictionary dictionary]];
            }
            if (!repeatingDecriptors[repeatingPointer]) {
                [repeatingDecriptors setObject:[NSMutableArray array] forKey:repeatingPointer];
            }
            if (((NSMutableArray *) repeatingDecriptors[repeatingPointer]).count <= repeatingIndex) {
                [((NSMutableArray *) repeatingDecriptors[repeatingPointer]) addObject:[NSMutableArray array]];

            }
            
            [((NSMutableDictionary *) ((NSMutableArray *) repeatingFields[repeatingPointer])[repeatingIndex]) setObject:v forKey:[NSValue valueWithNonretainedObject:fieldDesc]];
            [((NSMutableArray *) ((NSMutableArray *)repeatingDecriptors[repeatingPointer])[repeatingIndex]) addObject:fieldDesc];
        } else {
            [allViews setObject:v forKey:fieldDesc.fieldId];
        }

        if (panelView) {
            v.frame = CGRectMake(v.frame.origin.x - panelLeft, v.frame.origin.y - panelTop, v.frame.size.width, v.frame.size.height);
            [panelView addSubview:v];
        } else {
            if (panelledV) {
                [self addView:v toPanelledView:panelledV];
            } else {
                [formCanvas addSubview:v];
            }
        }

        if (fieldDesc.mandatory) {
            v.layer.backgroundColor = [mandatoryRed CGColor];
            [mandatoryViews setObject:v forKey:[fieldDesc repeatingFieldId]];
        }
        
    } else if ([fieldDesc isKindOfClass:[IWDrawingFieldDescriptor class]]){
        IWDrawingField *v = [self getDrawingField:(IWDrawingFieldDescriptor *)fieldDesc];
        if (repeatingPanel) {
            NSString *repeatingPointer = [NSString stringWithFormat:@"%p", repeatingPanel];
            if (!repeatingFields[repeatingPointer]) {
                [repeatingFields setObject:[NSMutableArray array] forKey:repeatingPointer];
            }
            if (((NSMutableArray *) repeatingFields[repeatingPointer]).count <= repeatingIndex) {
                [((NSMutableArray *) repeatingFields[repeatingPointer]) addObject:[NSMutableDictionary dictionary]];
            }
            if (!repeatingDecriptors[repeatingPointer]) {
                [repeatingDecriptors setObject:[NSMutableArray array] forKey:repeatingPointer];
            }
            if (((NSMutableArray *) repeatingDecriptors[repeatingPointer]).count <= repeatingIndex) {
                [((NSMutableArray *) repeatingDecriptors[repeatingPointer]) addObject:[NSMutableArray array]];

            }

            
            [((NSMutableDictionary *) ((NSMutableArray *) repeatingFields[repeatingPointer])[repeatingIndex]) setObject:v forKey:[NSValue valueWithNonretainedObject:fieldDesc]];
            [((NSMutableArray *) ((NSMutableArray *)repeatingDecriptors[repeatingPointer])[repeatingIndex]) addObject:fieldDesc];
        } else {
            [allViews setObject:v forKey:fieldDesc.fieldId];
        }

        CGRect frame = v.frame;
        CGFloat left = frame.origin.x + frame.size.width;
        CGFloat top = frame.origin.y;
        CGRect buttonFrame = CGRectMake(left, top, 25, 25);
        IWClearButton *clearButton = [[IWClearButton alloc] initWithFrame:buttonFrame];
        [clearButton setBackgroundImage:[UIImage imageNamed:@"clear_icon_01.png"] forState:UIControlStateNormal];
        [clearButton setBackgroundImage:[UIImage imageNamed:@"clear_icon_02.png"] forState:UIControlStateSelected];
        clearButton.drawingField = v;
        [clearButton addTarget:self action:@selector(clearButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        if (panelView) {
            clearButton.frame = CGRectMake(clearButton.frame.origin.x - panelLeft, clearButton.frame.origin.y - panelTop, clearButton.frame.size.width, clearButton.frame.size.height);
            [panelView addSubview:clearButton];
        } else {
            if (panelledV) {
                [self addView:clearButton toPanelledView:panelledV];
                
            } else {
                [formCanvas addSubview:clearButton];
            }
        }

        if (panelView) {
            v.frame = CGRectMake(v.frame.origin.x - panelLeft, v.frame.origin.y - panelTop, v.frame.size.width, v.frame.size.height);
            [panelView addSubview:v];
        } else {
            if (panelledV) {
                [self addView:v toPanelledView:panelledV];
            } else {
                [formCanvas addSubview:v];
            }
        }

        if (fieldDesc.mandatory) {
            v.layer.backgroundColor = [mandatoryRed CGColor];
            [mandatoryViews setObject:v forKey:[fieldDesc repeatingFieldId]];
        }
    }

    
    
}

-(void) handleRepeatingPanel:(IWDynamicPanel *) panel page:(IWPageDescriptor *) page panelledView:(CSLinearLayoutView *) panelledV parentPanel:(UIView *) parentPanel panellLeft:(int) panellLeft panelTop:(int) panelTop panelIndex:(int) panelIndex {
    UIView *panelView = nil;
    NSString *pointer = [NSString stringWithFormat:@"%p", panel];
    CSLinearLayoutView *repeatingLayout = repeatingPanels[pointer];
    if (!repeatingPanelIds[pointer]) {
        [repeatingPanelIds setObject:[NSMutableArray array] forKey:pointer];
    }
    if (((NSMutableArray *) repeatingPanelsLayouts[pointer]).count -1 < panelIndex) {
        panelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, page.pageWidth, panel.rectArea.height)];
        CSLinearLayoutItem *panelItem = [CSLinearLayoutItem layoutItemForView:panelView];
        [repeatingLayout addItem:panelItem];
        [((NSMutableArray *)repeatingPanelsLayouts[pointer]) addObject:panelItem];
        freeSpace -= panel.rectArea.height;
    } else {
        CSLinearLayoutItem *panelItem = repeatingPanelsLayouts[pointer][panelIndex];
        panelView = panelItem.view;
    }
    if (!repeatingDecriptors[pointer]) {
        [repeatingDecriptors setObject:[NSMutableArray array] forKey:pointer];
    }
    while (((NSMutableArray *)repeatingDecriptors[pointer]).count <= panelIndex) {
        [((NSMutableArray *)repeatingDecriptors[pointer]) addObject:[NSMutableArray array]];
    }
    CSLinearLayoutItem *item = panelLayouts[pointer];
    UIView *view = item.view;
    CGRect rect =CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, panel.rectArea.height * ((NSMutableArray *) repeatingPanelsLayouts[pointer]).count);

    
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, panel.rectArea.height * ((NSMutableArray *) repeatingPanelsLayouts[pointer]).count);
    [panelledV setNeedsLayout];
    panellLeft = 0;
    panelTop = panel.rectArea.y;
    [((NSMutableArray *) repeatingPanelIds[pointer]) addObject:repeatingPanelId];
    int panelId = [repeatingPanelId intValue];
    repeatingPanelId = @([repeatingPanelId intValue] +1);
    for (NSObject *o in panel.children) {
        if ([o isKindOfClass:[IWDynamicPanel class]]) {
            //just to avoid crashes - I'm told we won't be having panels inside repeating panels...
            
            // (07/10/2014)
            //                [11:23:19] Jamie Duggan: ok
            //                [11:37:49] Jamie Duggan: so to confirm
            //                [11:37:59] Jamie Duggan: there will be NO panels inside a repeating panel
            //                [11:38:00] Jamie Duggan: ?
            //                [11:38:18] Jamie Duggan: even fixed panels?
            //                [11:39:12] Ferguson Vastenhout: definitely not for this itteration - and I can't see it in the future
            
            continue;
        }
        if ([o isKindOfClass:[IWLineDescriptor class]]) {
            IWLineDescriptor *desc = [IWLineDescriptor newWithOriginal:(IWLineDescriptor *)o];
            desc.repeatingIndex = panelIndex;
            UIView *v = [self getLine:desc];
//            if (parentPanel) {
//                v.frame = CGRectMake(v.frame.origin.x - panellLeft, v.frame.origin.y - panelTop, v.frame.size.width, v.frame.size.height);
//                [parentPanel addSubview:v];
//            } else {
//                if (panelledV) {
//                    [self addView:v toPanelledView:panelledV];
//                } else {
                    v.frame = CGRectMake(v.frame.origin.x - panellLeft, v.frame.origin.y - panelTop, v.frame.size.width, v.frame.size.height);

                    [panelView addSubview:v];
                    
//                }
//            }
            continue;
        }
        if ([o isKindOfClass:[IWRoundedRectangleDescriptor class]]) {
            IWRoundedRectangleDescriptor *desc = [IWRoundedRectangleDescriptor newWithOriginal:(IWRoundedRectangleDescriptor *)o];
            desc.repeatingIndex = panelIndex;
            UIView *v = [self getRoundedRectangle:desc];
//            if (parentPanel) {
//                v.frame = CGRectMake(v.frame.origin.x - panellLeft, v.frame.origin.y - panelTop, v.frame.size.width, v.frame.size.height);
//                [parentPanel addSubview:v];
//            } else {
//                if (panelledV) {
//                    [self addView:v toPanelledView:panelledV];
//                } else {
                    v.frame = CGRectMake(v.frame.origin.x - panellLeft, v.frame.origin.y - panelTop, v.frame.size.width, v.frame.size.height);
                    
                    [panelView addSubview:v];
                    
//                }
//            }
            continue;
        }
        if ([o isKindOfClass:[IWCircleDescriptor class]]) {
            IWCircleDescriptor *desc = [IWCircleDescriptor newWithOriginal:(IWCircleDescriptor *)o];
            desc.repeatingIndex = panelIndex;
            IWCircleView *v = [self getCircle:desc];
            
            v.frame = CGRectMake(v.frame.origin.x - panellLeft, v.frame.origin.y - panelTop, v.frame.size.width, v.frame.size.height);
            
            [panelView addSubview:v];
            continue;
        }
        if ([o isKindOfClass:[IWRectangleDescriptor class]]) {
            IWRectangleDescriptor *desc = [IWRectangleDescriptor newWithOriginal:(IWRectangleDescriptor *)o];
            desc.repeatingIndex = panelIndex;
            UIView *v = [self getRectangle:desc];
//            if (parentPanel) {
//                v.frame = CGRectMake(v.frame.origin.x - panellLeft, v.frame.origin.y - panelTop, v.frame.size.width, v.frame.size.height);
//                [parentPanel addSubview:v];
//            } else {
//                if (panelledV) {
//                    [self addView:v toPanelledView:panelledV];
//                } else {
                    v.frame = CGRectMake(v.frame.origin.x - panellLeft, v.frame.origin.y - panelTop, v.frame.size.width, v.frame.size.height);
                    
                    [panelView addSubview:v];
                    
//                }
//            }
            continue;
        }
        if ([o isKindOfClass:[IWImageDescriptor class]]) {
            IWImageDescriptor *desc = [IWImageDescriptor newWithOriginal:(IWImageDescriptor *)o];
            desc.repeatingIndex = panelIndex;
            UIView *v = [self getImageView:desc];
//            if (parentPanel) {
//                v.frame = CGRectMake(v.frame.origin.x - panellLeft, v.frame.origin.y - panelTop, v.frame.size.width, v.frame.size.height);
//                [parentPanel addSubview:v];
//            } else {
//                if (panelledV) {
//                    [self addView:v toPanelledView:panelledV];
//                } else {
                    v.frame = CGRectMake(v.frame.origin.x - panellLeft, v.frame.origin.y - panelTop, v.frame.size.width, v.frame.size.height);
                    
                    [panelView addSubview:v];
                    
//                }
//            }
            continue;
        }
        if ([o isKindOfClass:[IWTextLabelDescriptor class]]) {
            IWTextLabelDescriptor *desc = [IWTextLabelDescriptor newWithOriginal:(IWTextLabelDescriptor *)o];
            desc.repeatingIndex = panelIndex;
            IWNonClippingLabel *v = [self getTextLabel:desc];
//            if (parentPanel) {
//                v.frame = CGRectMake(v.frame.origin.x - panellLeft, v.frame.origin.y - panelTop, v.frame.size.width, v.frame.size.height);
//                [parentPanel addSubview:v];
//            } else {
//                if (panelledV) {
//                    [self addView:v toPanelledView:panelledV];
//                } else {
                    v.frame = CGRectMake(v.frame.origin.x - panellLeft, v.frame.origin.y - panelTop, v.frame.size.width, v.frame.size.height);
                    
                    [panelView addSubview:v];
                    
//                }
//            }
            continue;
        }
        
        BOOL isCalc = NO;
        BOOL isCalcInput = NO;
        
        if ([o isKindOfClass:[NSString class]]) {
            NSString *groupName = (NSString *)o;
            //NSString *repeatingGroupName = [groupName stringByAppendingString:[NSString stringWithFormat:@"_%i", panelIndex]];
                NSArray *radios = [page.repeatingRadioGroups objectForKey:groupName];
            if (!repeatingRadioManagers[pointer]) {
                [repeatingRadioManagers setObject:[NSMutableArray array] forKey:pointer];
            }
            if (((NSMutableArray *)repeatingRadioManagers[pointer]).count <= panelIndex) {
                [((NSMutableArray *)repeatingRadioManagers[pointer]) addObject:[NSMutableDictionary dictionary]];
            }
            IWRadioButtonManager *rbm;
            if (((NSMutableDictionary *)((NSMutableArray *)repeatingRadioManagers[pointer])[panelIndex])[groupName]) {
                rbm = ((NSMutableDictionary *)((NSMutableArray *)repeatingRadioManagers[pointer])[panelIndex])[groupName];
            } else {
                rbm = [[IWRadioButtonManager alloc] init];
            }
            if ([mandatoryRadioGroups containsObject:((NSString *)o)]) {
                [mandatoryRadioGroups removeObject:((NSString *)o)];
                [mandatoryRadioGroupManagers removeObjectForKey:((NSString *)o)];
            }
            for (IWRadioButtonDescriptor *rbDesc in radios){
                IWRadioButtonDescriptor *copy = [IWRadioButtonDescriptor newWithOriginal:rbDesc];
                copy.repeatingIndex = panelIndex;
                IWRadioButton *v = [self getRadioButton:copy];
                
                [rbm addButton:v withId:copy.fieldId];
                
                if (rbDesc.mandatory) {
                    v.layer.backgroundColor = [mandatoryRed CGColor];
                    
                }
                
                v.frame = CGRectMake(v.frame.origin.x - panellLeft, v.frame.origin.y - panelTop, v.frame.size.width, v.frame.size.height);
                [panelView addSubview:v];
                if (copy.mandatory) {
                    [v setBackgroundColor:mandatoryRed];
                    if (![mandatoryRadioGroups containsObject:[copy repeatingGroupName]]) {
                        [mandatoryRadioGroups addObject:[copy repeatingGroupName]];
                        [mandatoryRadioGroupManagers setObject:rbm forKey:[copy repeatingGroupName]];
                    }
                }
                
            }
            
            if (!((NSMutableDictionary *)((NSMutableArray *)repeatingRadioManagers[pointer])[panelIndex])[groupName]){
                [((NSMutableDictionary *)((NSMutableArray *)repeatingRadioManagers[pointer])[panelIndex]) setObject:rbm forKey:groupName];
            }

            continue;
        
        }
        IWFieldDescriptor *fd = nil;
        if ([o isKindOfClass:[IWTabletImageDescriptor class]]) {
            fd = [IWTabletImageDescriptor newWithOriginal:(IWTabletImageDescriptor *)o];
        } else if ([o isKindOfClass:[IWDateTimeFieldDescriptor class]]) {
            fd = [IWDateTimeFieldDescriptor newWithOriginal:(IWDateTimeFieldDescriptor *)o];
            if (((IWIsoFieldDescriptor *)fd).isCalcField) {
                if (repeatingCalcs[pointer] == nil) {
                    [repeatingCalcs setObject:[NSMutableArray array] forKey:pointer];
                }
                if (repeatingCalcFields[pointer] == nil) {
                    [repeatingCalcFields setObject:[NSMutableArray array] forKey:pointer];
                }
                if (((NSMutableArray *)repeatingCalcs[pointer]).count == 0 || ((NSMutableArray *)repeatingCalcs[pointer]).count - 1 < panelIndex) {
                    [repeatingCalcs[pointer] addObject:[NSMutableDictionary dictionary]];
                }
                if (((NSMutableArray *)repeatingCalcFields[pointer]).count == 0 || ((NSMutableArray *)repeatingCalcFields[pointer]).count -1 < panelIndex) {
                    [repeatingCalcFields[pointer] addObject:[NSMutableDictionary dictionary]];
                }
                
                isCalcInput = YES;
                isCalc = YES;
                
            } else {
                if (((IWIsoFieldDescriptor *)fd).isCalcInput) {
                    if (repeatingCalcFields[pointer] == nil) {
                        [repeatingCalcFields setObject:[NSMutableArray array] forKey:pointer];
                    }
                    if (((NSMutableArray *)repeatingCalcFields[pointer]).count == 0 || ((NSMutableArray *)repeatingCalcFields[pointer]).count -1 < panelIndex) {
                        [repeatingCalcFields[pointer] addObject:[NSMutableDictionary dictionary]];
                    }
                    isCalcInput = YES;
                    
                }
            }
        }
        else if ([o isKindOfClass:[IWDecimalFieldDescriptor class]]) {
            fd = [IWDecimalFieldDescriptor newWithOriginal:(IWDecimalFieldDescriptor *)o];
            if (((IWIsoFieldDescriptor *)fd).isCalcField) {
                if (repeatingCalcs[pointer] == nil) {
                    [repeatingCalcs setObject:[NSMutableArray array] forKey:pointer];
                }
                if (repeatingCalcFields[pointer] == nil) {
                    [repeatingCalcFields setObject:[NSMutableArray array] forKey:pointer];
                }
                if (((NSMutableArray *)repeatingCalcs[pointer]).count == 0 || ((NSMutableArray *)repeatingCalcs[pointer]).count - 1 < panelIndex) {
                    [repeatingCalcs[pointer] addObject:[NSMutableDictionary dictionary]];
                }
                if (((NSMutableArray *)repeatingCalcFields[pointer]).count == 0 || ((NSMutableArray *)repeatingCalcFields[pointer]).count - 1 < panelIndex) {
                    [repeatingCalcFields[pointer] addObject:[NSMutableDictionary dictionary]];
                }
                
                isCalcInput = YES;
                isCalc = YES;
            } else {
                if (((IWIsoFieldDescriptor *)fd).isCalcInput) {
                    if (repeatingCalcFields[pointer] == nil) {
                        [repeatingCalcFields setObject:[NSMutableArray array] forKey:pointer];
                    }
                    if (((NSMutableArray *)repeatingCalcFields[pointer]).count == 0 || ((NSMutableArray *)repeatingCalcFields[pointer]).count - 1 < panelIndex) {
                        [repeatingCalcFields[pointer] addObject:[NSMutableDictionary dictionary]];
                    }
                    isCalcInput = YES;
                    
                }
            }

        }
        else if ([o isKindOfClass:[IWIsoFieldDescriptor class]]) {
            fd = [IWIsoFieldDescriptor newWithOriginal:(IWIsoFieldDescriptor *)o];
            if (((IWIsoFieldDescriptor *)fd).isCalcField) {
                if (repeatingCalcs[pointer] == nil) {
                    [repeatingCalcs setObject:[NSMutableArray array] forKey:pointer];
                }
                if (repeatingCalcFields[pointer] == nil) {
                    [repeatingCalcFields setObject:[NSMutableArray array] forKey:pointer];
                }
                if (((NSMutableArray *)repeatingCalcs[pointer]).count == 0 || ((NSMutableArray *)repeatingCalcs[pointer]).count - 1 < panelIndex) {
                    [repeatingCalcs[pointer] addObject:[NSMutableDictionary dictionary]];
                }
                if (((NSMutableArray *)repeatingCalcFields[pointer]).count == 0 || ((NSMutableArray *)repeatingCalcFields[pointer]).count - 1 < panelIndex) {
                    [repeatingCalcFields[pointer] addObject:[NSMutableDictionary dictionary]];
                }
                
                isCalcInput = YES;
                isCalc = YES;
                
            } else {
                if (((IWIsoFieldDescriptor *)fd).isCalcInput) {
                    if (repeatingCalcFields[pointer] == nil) {
                        [repeatingCalcFields setObject:[NSMutableArray array] forKey:pointer];
                    }
                    if (((NSMutableArray *)repeatingCalcFields[pointer]).count == 0 || ((NSMutableArray *)repeatingCalcFields[pointer]).count - 1 < panelIndex) {
                        [repeatingCalcFields[pointer] addObject:[NSMutableDictionary dictionary]];
                    }
                    isCalcInput = YES;
                }
            }

        }
        else if ([o isKindOfClass:[IWTickBoxDescriptor class]]) {
            fd = [IWTickBoxDescriptor newWithOriginal:(IWTickBoxDescriptor *)o];
        }
        else if ([o isKindOfClass:[IWRadioButtonDescriptor class]]) {
            fd = [IWRadioButtonDescriptor newWithOriginal:(IWRadioButtonDescriptor *)o];
        }
        else if ([o isKindOfClass:[IWDrawingFieldDescriptor class]]) {
            fd = [IWDrawingFieldDescriptor newWithOriginal:(IWDrawingFieldDescriptor *)o];
        }
        else if ([o isKindOfClass:[IWDropdownDescriptor class]]) {
            fd = [IWDropdownDescriptor newWithOriginal:(IWDropdownDescriptor *)o];
            if (((IWDropdownDescriptor *)fd).isCalc) {
                if (repeatingCalcFields[pointer] == nil) {
                    [repeatingCalcFields setObject:[NSMutableArray array] forKey:pointer];
                }
                if (((NSMutableArray *)repeatingCalcFields[pointer]).count == 0 || ((NSMutableArray *)repeatingCalcFields[pointer]).count - 1 < panelIndex) {
                    [repeatingCalcFields[pointer] addObject:[NSMutableDictionary dictionary]];
                }
                isCalcInput = YES;
            }
        }
        else if ([o isKindOfClass:[IWNoteFieldDescriptor class]]) {
            fd = [IWNoteFieldDescriptor newWithOriginal:(IWNoteFieldDescriptor *)o];
        }
        
        if (fd) {
            if ([mandatoryDescriptors objectForKey:fd.fieldId] != nil) {
                [mandatoryDescriptors removeObjectForKey:fd.fieldId];
            }
            fd.repeatingIndex = panelIndex;
            [self handleFieldDescriptor:fd page:page panelledView:panelledV panelView:panelView panelTop:panelTop panelLeft:panellLeft repeatingPanel:panel repeatingIndex:panelIndex];
            if (isCalcInput) {
                UIView *view = [panelView.subviews lastObject];
                [repeatingCalcFields[pointer][panelIndex] setObject:view forKey:fd.fdtFieldName];
                if (isCalc) {
                    IWIsoFieldView *isoView = (IWIsoFieldView *)view;
                    [isoView setCalc];
                    [repeatingCalcs[pointer][panelIndex] setObject:view forKey:fd.fdtFieldName];
                }
            }
            
        }
        
        [self recalculateFields];
        
        
    }
    
    //The Add Button
    IWDataButton *addButton = [[IWDataButton alloc]initWithFrame:CGRectMake(panel.rectArea.x +
                                                                            panel.rectArea.width - 25, 0, 25, 25)];
    [addButton setTitle:@"" forState:UIControlStateNormal];
    [addButton setTitle:@"" forState:UIControlStateHighlighted];
    [addButton setTitle:@"" forState:UIControlStateSelected];
    addButton.backgroundColor = [UIColor clearColor];
    UIImage *plusImageEnabled = [UIImage imageNamed:@"plus_icon_02.png"];
    UIImage *plusImageDisabled = [UIImage imageNamed:@"plus_icon_01.png"];
    [addButton setImage:plusImageEnabled forState:UIControlStateNormal];
    [addButton setImage:plusImageEnabled forState:UIControlStateHighlighted];
    [addButton setImage:plusImageDisabled forState:UIControlStateDisabled];
    [addButton setImage:plusImageEnabled forState:UIControlStateSelected];
    int finalPanelLeft = panellLeft;
    IWButtonData *buttonData = [[IWButtonData alloc] init];
    buttonData.panel = panel;
    buttonData.panelLeft = panellLeft;
    buttonData.panelledV = panelledV;
    buttonData.page = page;
    buttonData.parentPanel = parentPanel;
    buttonData.panelId = panelId;
    addButton.buttonData = buttonData;
    [addButton addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    if (!dynamicPlusButtons[pointer]) {
        [dynamicPlusButtons setObject:[NSMutableArray array] forKey:pointer];
    }
    if (!dynamicMinusButtons[pointer]) {
        [dynamicMinusButtons setObject:[NSMutableArray array] forKey:pointer];
    }
    [((NSMutableArray *) dynamicPlusButtons[pointer]) addObject:addButton];
    
    //The Remove Button
    IWDataButton *removeButton = [[IWDataButton alloc] initWithFrame:CGRectMake(panel.rectArea.x + panel.rectArea.width - 75, 0 , 25, 25)];
    [removeButton setTitle:@"" forState:UIControlStateNormal];
    [removeButton setTitle:@"" forState:UIControlStateHighlighted];
    [removeButton setTitle:@"" forState:UIControlStateSelected];
    removeButton.backgroundColor = [UIColor clearColor];
    removeButton.buttonData = buttonData;
    UIImage *minusImageDisabled = [UIImage imageNamed:@"minus_icon_01.png"];
    UIImage *minusImageEnabled = [UIImage imageNamed:@"minus_icon_02.png"];
    [removeButton setImage:minusImageDisabled forState:UIControlStateDisabled];
    [removeButton setImage:minusImageEnabled forState:UIControlStateHighlighted];
    [removeButton setImage:minusImageEnabled forState:UIControlStateSelected];
    [removeButton setImage:minusImageEnabled forState:UIControlStateNormal];
    [removeButton setEnabled:NO];
    [removeButton addTarget:self action:@selector(removeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [((NSMutableArray *) dynamicMinusButtons[pointer]) addObject:removeButton];
    [panelView addSubview:addButton];
    [panelView addSubview:removeButton];

    
    [self handleRepeatingButtons];
}

- (void) addButtonClick:(id) sender {
    IWDataButton *button = (IWDataButton *) sender;
    IWButtonData *buttonData = (IWButtonData *) button.buttonData;
    NSString *pointer = [NSString stringWithFormat:@"%p", buttonData.panel];
    [self handleRepeatingPanel:buttonData.panel page:buttonData.page panelledView:buttonData.panelledV parentPanel:buttonData.parentPanel panellLeft:buttonData.panelLeft panelTop:buttonData.panel.rectArea.y panelIndex:(int)((NSMutableArray *)repeatingPanelsLayouts[pointer]).count];
    [self handleRepeatingButtons];
    
}

- (void) removeButtonClick: (id)sender {
    IWDataButton *button = (IWDataButton *)sender;
    IWButtonData *buttonData = (IWButtonData *)button.buttonData;
    [self removeRepeatingPanel: buttonData.panel panelId:buttonData.panelId];
    [self handleRepeatingButtons];
}

- (void) removeRepeatingPanel:(IWDynamicPanel *)panel panelId:(int) panelId{
    NSString *pointer = [NSString stringWithFormat:@"%p", panel];
    NSNumber *panelIdNumber = [NSNumber numberWithInt:panelId];
    if (![((NSMutableArray *) repeatingPanelIds[pointer]) containsObject:panelIdNumber]) {
        return;
    }
    
    NSUInteger panelIndex = [((NSMutableArray  *) repeatingPanelIds[pointer]) indexOfObject:panelIdNumber];
    if (repeatingCalcFields[pointer] != nil) {
        [repeatingCalcFields[pointer] removeObjectAtIndex:panelIndex];
        if (repeatingCalcs[pointer] != nil) {
            [repeatingCalcs[pointer] removeObjectAtIndex:panelIndex];
        }
    }
    [((NSMutableArray *) repeatingPanelIds[pointer]) removeObjectAtIndex:panelIndex];
    [((NSMutableArray *) repeatingPanelsLayouts[pointer]) removeObjectAtIndex:panelIndex];
    [((CSLinearLayoutView *) repeatingPanels[pointer]) removeItem:((CSLinearLayoutView *) repeatingPanels[pointer]).items[panelIndex]];
    if (((NSMutableArray *) repeatingDecriptors[pointer]).count > 0) {
        [((NSMutableArray *) repeatingDecriptors[pointer]) removeObjectAtIndex:panelIndex];
    }
    NSMutableDictionary *fields = ((NSMutableDictionary *)((NSMutableArray *) repeatingFields[pointer])[panelIndex]);
    NSMutableArray *remove = [NSMutableArray array];
    for (UIView *v in fields.objectEnumerator) {
        for (NSString *k in mandatoryViews) {
            if (v == mandatoryViews[k]) {
                [remove addObject:k];
                break;
            }
        }
    }
    for (NSString *k in remove) {
        [mandatoryViews removeObjectForKey:k];
    }
    [((NSMutableArray *) repeatingFields[pointer]) removeObjectAtIndex:panelIndex];
    NSMutableDictionary *rads = ((NSMutableDictionary *)((NSMutableArray *) repeatingRadioManagers[pointer])[panelIndex]);
    NSMutableArray *removeRads = [NSMutableArray array];
    for (UIView *v in rads.objectEnumerator) {
        for (NSString *k in mandatoryRadioGroupManagers) {
            if (v == mandatoryRadioGroupManagers[k]) {
                [removeRads addObject:k];
                break;
            }
        }
    }
    for (NSString *k in removeRads) {
        [mandatoryRadioGroups removeObject:k];
        [mandatoryRadioGroupManagers removeObjectForKey:k];
    }
    [((NSMutableArray *) repeatingRadioManagers[pointer]) removeObjectAtIndex:panelIndex];
    [((NSMutableArray *) dynamicMinusButtons[pointer]) removeObjectAtIndex:panelIndex];
    [((NSMutableArray *) dynamicPlusButtons[pointer]) removeObjectAtIndex:panelIndex];
    CSLinearLayoutItem *item = panelLayouts[pointer];
    UIView *view = item.view;
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, panel.rectArea.height * ((NSMutableArray *) repeatingPanelsLayouts[pointer]).count);
    for (int i = 0; i < ((NSMutableArray *)repeatingDecriptors[pointer]).count; i++) {
        NSMutableArray *list = ((NSMutableArray *) repeatingDecriptors[pointer])[i];
        for (IWElementDescriptor *ed in list) {
            ed.repeatingIndex = i;
        }
        
        for (NSString *groupName in ((NSMutableDictionary *)((NSMutableArray *)repeatingRadioManagers[pointer])[i]).keyEnumerator) {
            IWRadioButtonManager *rbm = ((NSMutableDictionary *)((NSMutableArray *)repeatingRadioManagers[pointer])[i])[groupName];
            for (IWRadioButton *rb in rbm.radios.objectEnumerator) {
                rb.descriptor.repeatingIndex = i;
            }
        }
        
    }
    
    freeSpace += panel.rectArea.height;
    

    
    
}

- (void) handleRepeatingButtons {
    for (NSString *pointer in dynamicMinusButtons.keyEnumerator) {
        IWDynamicPanel *panel = panelPointers[pointer];
        BOOL minusAllowed = ((NSMutableArray *) dynamicMinusButtons[pointer]).count > 1;
        for (UIButton *b in (NSMutableArray *) dynamicMinusButtons[pointer]) {
            if (minusAllowed) {
                [b setEnabled:YES];
            } else {
                [b setEnabled:NO];
            }
            [b setNeedsDisplay];
        }
        BOOL plusAllowed = freeSpace >= panel.rectArea.height;
        for (UIButton *b in (NSMutableArray *) dynamicPlusButtons[pointer]) {
            if (plusAllowed) {
                [b setEnabled:YES];
            } else {
                [b setEnabled:NO];
            }
            
            [b setNeedsDisplay];
        }

        
    }
    
    
}

-(void) handlePanel:(IWDynamicPanel *)panel page:(IWPageDescriptor *) page panelledView:(CSLinearLayoutView *) panelledV panelView:(UIView *) panelView panelTop:(int) panelTop panelLeft:(int) panelLeft {
    [self handlePanel:panel page:page panelledView:panelledV panelView:panelView panelTop:panelTop panelLeft:panelLeft repeatingPanel:panel.repeatingPanel];
}

-(void) handlePanel:(IWDynamicPanel *)panel page:(IWPageDescriptor *) page panelledView:(CSLinearLayoutView *) panelledV panelView:(UIView *) panelView panelTop:(int) panelTop panelLeft:(int) panelLeft repeatingPanel:(BOOL) repeatingPanel {
    if (repeatingPanel) {
        [self handleRepeatingPanel:panel page:page panelledView:panelledV parentPanel:panelView panellLeft:panelLeft panelTop:panelTop panelIndex:0];
    } else {
        UIView *thisPanellView = nil;
        NSString *pointer = [NSString stringWithFormat:@"%p", panel];
        if (!panel.shouldMoveFieldsBelow) {
            thisPanellView = [[UIView alloc] initWithFrame:CGRectMake(panel.rectArea.x, panel.rectArea.y, panel.rectArea.width, panel.rectArea.height)];
            //[thisPanellView setBackgroundColor:[UIColor redColor]];
            //[self processPanelVisibility:panel];
            [thisPanellView setHidden:![panel shouldShowPanel]];
            [panelLayouts setObject:thisPanellView forKey:pointer];
            
            if (panelView) {
                thisPanellView.frame = CGRectMake(panel.rectArea.x - panelLeft, panel.rectArea.y - panelTop, panel.rectArea.width, panel.rectArea.height);
                if ([panelView isKindOfClass:[CSLinearLayoutItem class]]) {
                    panelView = [((CSLinearLayoutItem *)panelView) view];
                }
                [panelView addSubview:thisPanellView];

            } else {
                if (panelledV) {

                    [self addView:thisPanellView toPanelledView:panelledV];
                    
                } else {
                    [formCanvas addSubview:thisPanellView];
                    
                }
            }
            //panelLeft += thisPanellView.frame.origin.x;
            //panelTop += thisPanellView.frame.origin.y;
            panelLeft = panel.rectArea.x;
            panelTop = panel.rectArea.y;
        } else {
            panelLeft = 0;
            panelTop = panel.rectArea.y;
        }
        for (NSObject *o in panel.children) {
            if ([o isKindOfClass:[IWDynamicPanel class]]) {
                [self handlePanel:(IWDynamicPanel *)o page:page panelledView:panelledV panelView:panelLayouts[pointer] panelTop:panelTop panelLeft:panelLeft repeatingPanel:repeatingPanel];
                continue;
            }
            if ([o isKindOfClass:[IWLineDescriptor class]]) {
                UIView *v = [self getLine:(IWLineDescriptor *)o];
                if (thisPanellView) {
                    v.frame = CGRectMake(v.frame.origin.x - panelLeft, v.frame.origin.y - panelTop, v.frame.size.width, v.frame.size.height);
                    [thisPanellView addSubview:v];
                } else {
                    if (panelledV) {
                        [self addView:v toPanelledView:panelledV];
                    } else {
                        v.frame = CGRectMake(v.frame.origin.x - panelLeft, v.frame.origin.y - panelTop, v.frame.size.width , v.frame.size.height);
                        [thisPanellView addSubview:v];
                    }
                }
                continue;
            }
            if ([o isKindOfClass:[IWRoundedRectangleDescriptor class]]) {
                UIView *v = [self getRoundedRectangle:(IWRoundedRectangleDescriptor *)o];
                if (thisPanellView) {
                    v.frame = CGRectMake(v.frame.origin.x - panelLeft, v.frame.origin.y - panelTop, v.frame.size.width, v.frame.size.height);
                    [thisPanellView addSubview:v];
                } else {
                    if (panelledV) {
                        [self addView:v toPanelledView:panelledV];
                    } else {
                        v.frame = CGRectMake(v.frame.origin.x - panelLeft, v.frame.origin.y - panelTop, v.frame.size.width , v.frame.size.height);
                        [thisPanellView addSubview:v];
                    }
                }
                continue;
            }
            
            if ([o isKindOfClass:[IWCircleDescriptor class]]) {
                IWCircleView *v = [self getCircle:(IWCircleDescriptor *)o];
                if (thisPanellView) {
                    v.frame = CGRectMake(v.frame.origin.x - panelLeft, v.frame.origin.y - panelTop, v.frame.size.width, v.frame.size.height);
                    [thisPanellView addSubview:v];
                } else {
                    if (panelledV) {
                        [self addView:v toPanelledView:panelledV];
                    } else {
                        v.frame = CGRectMake(v.frame.origin.x - panelLeft, v.frame.origin.y - panelTop, v.frame.size.width , v.frame.size.height);
                        [thisPanellView addSubview:v];
                    }
                }
                continue;
            }
            
            if ([o isKindOfClass:[IWRectangleDescriptor class]]) {
                UIView *v = [self getRectangle:(IWRectangleDescriptor *)o];
                if (thisPanellView) {
                    v.frame = CGRectMake(v.frame.origin.x - panelLeft, v.frame.origin.y - panelTop, v.frame.size.width, v.frame.size.height);
                    [thisPanellView addSubview:v];
                } else {
                    if (panelledV) {
                        [self addView:v toPanelledView:panelledV];
                    } else {
                        v.frame = CGRectMake(v.frame.origin.x - panelLeft, v.frame.origin.y - panelTop, v.frame.size.width , v.frame.size.height);
                        [thisPanellView addSubview:v];
                    }
                }
                continue;
            }
            if ([o isKindOfClass:[IWImageDescriptor class]]) {
                UIView *v = [self getImageView:(IWImageDescriptor *)o];
                if (thisPanellView) {
                    v.frame = CGRectMake(v.frame.origin.x - panelLeft, v.frame.origin.y - panelTop, v.frame.size.width, v.frame.size.height);
                    [thisPanellView addSubview:v];
                } else {
                    if (panelledV) {
                        [self addView:v toPanelledView:panelledV];
                    } else {
                        v.frame = CGRectMake(v.frame.origin.x - panelLeft, v.frame.origin.y - panelTop, v.frame.size.width , v.frame.size.height);
                        [thisPanellView addSubview:v];
                    }
                }
                continue;
            
            }
            if ([o isKindOfClass:[IWTextLabelDescriptor class]]) {
                IWNonClippingLabel *v = [self getTextLabel:(IWTextLabelDescriptor *)o];
                if (thisPanellView) {
                    v.frame = CGRectMake(v.frame.origin.x - panelLeft, v.frame.origin.y - panelTop, v.frame.size.width, v.frame.size.height);
                    [thisPanellView addSubview:v];
                } else {
                    if (panelledV) {
                        [self addView:v toPanelledView:panelledV];
                    } else {
                        v.frame = CGRectMake(v.frame.origin.x - panelLeft, v.frame.origin.y - panelTop, v.frame.size.width , v.frame.size.height);
                        [thisPanellView addSubview:v];
                    }
                }
                continue;
                
            }
            if ([o isKindOfClass:[NSString class]]) {
                NSString *groupName = (NSString *)o;
                    NSArray *radios = [page.repeatingRadioGroups objectForKey:groupName];
                    IWRadioButtonManager *rbm = [[IWRadioButtonManager alloc] init];
                    
                    for (IWRadioButtonDescriptor *rbDesc in radios){
                        IWRadioButton *v = [self getRadioButton:rbDesc];
                        
                        [rbm addButton:v withId:rbDesc.fieldId];
                        
                        if (rbDesc.mandatory) {
                            v.layer.backgroundColor = [mandatoryRed CGColor];
                            if ([mandatoryRadioGroupManagers objectForKey:groupName] == nil) {
                                [mandatoryRadioGroupManagers setObject:rbm forKey:groupName];
                            }
                        }
                        
                        if (thisPanellView) {
                            v.frame = CGRectMake(v.frame.origin.x - panelLeft, v.frame.origin.y - panelTop, v.frame.size.width, v.frame.size.height);
                            [thisPanellView addSubview:v];
                        } else {
                            if (panelledV) {
                                [self addView:v toPanelledView:panelledV];
                            } else {
                                [formCanvas addSubview:v];
                            }
                        }
                        
                        
                        
                    }
                    
                    [radioGroupManagers setObject:rbm forKey:groupName];

                continue;
            }
            [self handleFieldDescriptor:(IWFieldDescriptor *)o page:page panelledView:panelledV panelView:thisPanellView panelTop:panelTop panelLeft:panelLeft];

            
        }
        
    }
    
    
}

- (void) renderCanvas{
    repeatingPanelId = @0;
    repeatingPanelIds = [NSMutableDictionary dictionary];
    repeatingPanelsLayouts = [NSMutableDictionary dictionary];
    //repeatingPanels = [NSMutableDictionary dictionary];
    repeatingDecriptors = [NSMutableDictionary dictionary];
    repeatingFields = [NSMutableDictionary dictionary];
    repeatingRadioManagers = [NSMutableDictionary dictionary];
    dynamicMinusButtons = [NSMutableDictionary dictionary];
    dynamicPlusButtons = [NSMutableDictionary dictionary];
    IWPageDescriptor *page = nil;
    for (IWPageDescriptor *pg in formDescriptor.pageDescriptors) {
        if ([pageServer getModdedPageNumber:pg.pageNumber-1] == pageToRender) {
            page = pg;
        }
    }
    //IWPageDescriptor *page = [formDescriptor.pageDescriptors objectAtIndex:pageToRender];
    CGRect pageRect = CGRectMake(0, 0, page.pageWidth, page.pageHeight);
    allViews = [NSMutableDictionary dictionary];
    radioGroupManagers = [NSMutableDictionary dictionary];
    formCanvas = [[UIView alloc] initWithFrame:pageRect];
    formCanvas.userInteractionEnabled = YES;
    formCanvas.backgroundColor = [UIColor whiteColor];
    panelledView = nil;
    if ([page.panels count] >0) {
        panelledView = [self getFormLayout:page];
        if (panelledView) {
            freeSpace = (int)page.pageHeight;
            
            if (repeatingPanels.count > 0) {
                freeSpace = freeSpace / 2;
            }
        }
        
    }
    
    for (IWShapeDescriptor *shapeDesc in page.shapeDescriptors){
        if ([shapeDesc isKindOfClass:[IWLineDescriptor class]]){
            UIView *v = [self getLine:((IWLineDescriptor *) shapeDesc)];
            if (panelledView) {
                [self addView:v toPanelledView:panelledView];
            } else {
                [formCanvas addSubview:v];
            }
        } else if ([shapeDesc isKindOfClass:[IWRoundedRectangleDescriptor class]]) {
            IWRectangleView *v = [self getRoundedRectangle:((IWRoundedRectangleDescriptor *)shapeDesc)];
            if (panelledView) {
                [self addView:v toPanelledView:panelledView];
            } else {
                [formCanvas addSubview:v];
            }

        } else if ([shapeDesc isKindOfClass:[IWRectangleDescriptor class]]){
            IWRectangleView *v = [self getRectangle:((IWRectangleDescriptor *)shapeDesc)];
            if (panelledView) {
                [self addView:v toPanelledView:panelledView];
            } else {
                [formCanvas addSubview:v];
            }
            
        } else if ([shapeDesc isKindOfClass:[IWCircleDescriptor class]]){
            IWCircleView *v = [self getCircle:((IWCircleDescriptor *)shapeDesc)];
            if (panelledView) {
                [self addView:v toPanelledView:panelledView];
            } else {
                [formCanvas addSubview:v];
            }
            
        }
    }
    
    for (IWImageDescriptor *imageDesc in page.imageDescriptors){
        UIImageView *v = [self getImageView:imageDesc];
        
        if (panelledView) {
            [self addView:v toPanelledView:panelledView];
        } else {
            [formCanvas addSubview:v];
        }
        [v setImage:v.image];

    }
    
    for (IWTextLabelDescriptor *labelDesc in page.textLabelDescriptors){
        IWNonClippingLabel *v = [self getTextLabel:labelDesc];
        if (panelledView) {
            [self addView:v toPanelledView:panelledView];
        } else {
            [formCanvas addSubview:v];
        }

    }
    
    int count = 0;
    for (IWFieldDescriptor *fieldDesc in page.fieldDescriptors){
        [self handleFieldDescriptor:fieldDesc page:page panelledView:panelledView panelView:nil panelTop:0 panelLeft:0];
        NSLog(@"Created %d fields...", ++count);
    }
    
    for (IWDynamicPanel *panel in page.panels) {
        [self handlePanel:panel page:page panelledView:panelledView panelView:nil panelTop:0 panelLeft:0];
    }
    
    
    for (NSString *groupName in page.radioGroups) {
        NSArray *radios = [page.radioGroups objectForKey:groupName];
        
        for (IWRadioButtonDescriptor *rbDesc in radios) {
            if (rbDesc.mandatory) {
                for (IWRadioButtonDescriptor *rbDesc2 in radios) {
                    rbDesc2.mandatory = YES;
                }
                break;
            }
        }
        
    }
    
    for (NSString *groupName in page.radioGroups){
        NSArray *radios = [page.radioGroups objectForKey:groupName];
        IWRadioButtonManager *rbm = [[IWRadioButtonManager alloc] init];
        
        for (IWRadioButtonDescriptor *rbDesc in radios){
            IWRadioButton *v = [self getRadioButton:rbDesc];
            
            [rbm addButton:v withId:rbDesc.fieldId];
            
            if (rbDesc.mandatory) {
                v.layer.backgroundColor = [mandatoryRed CGColor];
                if ([mandatoryRadioGroupManagers objectForKey:groupName] == nil) {
                    [mandatoryRadioGroupManagers setObject:rbm forKey:groupName];
                }
            }
            
            if (panelledView) {
                [self addView:v toPanelledView:panelledView];
            } else {
                [formCanvas addSubview:v];
            }

        }
        
        [radioGroupManagers setObject:rbm forKey:groupName];
    }
    
    if (currentTransaction != nil){
        //Form processing...
        
    }
    
    if (panelledView) {
        [formCanvas addSubview:panelledView];
        
    }
    formCanvasReady = YES;
    
    
    [self recalculateFields];
    
}

- (void) clearButtonClick: (id) sender {
    IWClearButton *cb = (IWClearButton *)sender;
    cb.drawingField.paths = [NSMutableArray array];
    
    [self triggerPanelField:cb.drawingField.descriptor.fdtFieldName value:NO];
    
    [cb.drawingField setNeedsDisplay];
}


- (int) pageCount{
    return (int)[formDescriptor.pageDescriptors count];
}

- (void)loadMandatoryFields:(NSDictionary *)pageInfo {
    NSString *procPage = [pageInfo objectForKey:@"proc"];
    NSString *strokePage = [pageInfo objectForKey:@"strokes"];
    NSError *error;
    TBXML *procXml = [[TBXML alloc] initWithXMLString:procPage error:&error];
    TBXML *strokeXml = [[TBXML alloc] initWithXMLString:strokePage error:&error];
    
    TBXMLElement *procRoot = procXml.rootXMLElement;
    TBXMLElement *strokesRoot = strokeXml.rootXMLElement;
    
    TBXMLElement *strokesElement = strokesRoot->firstChild;
    TBXMLElement *unassignedElement = strokesElement->firstChild;
    
    TBXMLElement *fieldsElement = procRoot->firstChild;
    
    TBXMLElement *fldElem = fieldsElement->firstChild;

    while (fldElem) {
        
        if ([[TBXML elementName:fldElem] isEqualToString:@"repeating"]) {
            
            IWDynamicPanel *panel;
            NSString *panelName = @"";
            TBXMLAttribute *att = fldElem->firstAttribute;
            while (att) {
                
                if ([[TBXML attributeName:att] isEqualToString:@"fieldid"]) {
                    panelName = [TBXML attributeValue:att];
                    break;
                }
                
                att = att->next;
            }
            
            for (NSString *pointer in panelPointers) {
                IWDynamicPanel *testPan = panelPointers[pointer];
                if ([testPan.fieldId isEqualToString:panelName]) {
                    panel = testPan;
                    break;
                }
            }
            
            TBXMLElement *instance = fldElem->firstChild;
            while (instance) {
                
                if (![[TBXML elementName:instance] isEqualToString:@"instance"]){
                    instance = instance->nextSibling;
                    continue;
                }
                
                TBXMLAttribute *instAtt = instance->firstAttribute;
                int instanceId = -1;
                while (instAtt) {
                    
                    if ([[TBXML attributeName:instAtt] isEqualToString:@"id"]) {
                        NSString *attVal = [TBXML attributeValue:instAtt];
                        instanceId = [attVal intValue];
                    }
                    
                    instAtt = instAtt->next;
                }
                
                TBXMLElement *repFldElem = instance->firstChild;
                while (repFldElem) {
                    
                    
                    TBXMLAttribute *fieldIdAtt = repFldElem->firstAttribute;
                    NSString *fieldId = [TBXML attributeValue:fieldIdAtt];
                    fieldId = [NSString stringWithFormat:@"%@_%d", fieldId, instanceId];
                    TBXMLElement *valueNode = repFldElem->firstChild;
                    if (valueNode == NULL) {
                        repFldElem = repFldElem->nextSibling;
                        continue;
                    }
                    NSString *val = [TBXML textForElement:valueNode];
                    if (val == nil) val = @"";
                    val = [val stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
                    val = [val stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
                    val = [val stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
                    val = [val stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                    
                    
                    BOOL tickedVal = NO;
                    BOOL tickable = NO;
                    TBXMLAttribute *tickedAtt = valueNode->firstAttribute;
                    while (tickedAtt){
                        NSString *attName = [TBXML attributeName:tickedAtt];
                        if ([attName isEqualToString:@"ticked"]){
                            NSString *attVal = [TBXML attributeValue:tickedAtt];
                            tickable = YES;
                            tickedVal = [attVal isEqualToString:@"true"];
                        }
                        tickedAtt = tickedAtt->next;
                    }
                    
                    [loadedFieldValues setObject:tickable? tickedVal ? val : @"" : val forKey:fieldId];
                    
                    repFldElem = repFldElem->nextSibling;
                }
                
                instance = instance->nextSibling;
            }
            
            
            fldElem = fldElem->nextSibling;
            continue;
        }
        
        TBXMLAttribute *fieldIdAtt = fldElem->firstAttribute;
        NSString *fieldId = [TBXML attributeValue:fieldIdAtt];
        
        TBXMLElement *valueNode = fldElem->firstChild;
        if (valueNode == NULL) {
            fldElem = fldElem->nextSibling;
            continue;
        }
        NSString *val = [TBXML textForElement:valueNode];
        if (val == nil) val = @"";
        val = [val stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        val = [val stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
        val = [val stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
        val = [val stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
        
        
        BOOL tickedVal = NO;
        BOOL tickable = NO;
        TBXMLAttribute *tickedAtt = valueNode->firstAttribute;
        while (tickedAtt){
            NSString *attName = [TBXML attributeName:tickedAtt];
            if ([attName isEqualToString:@"ticked"]){
                NSString *attVal = [TBXML attributeValue:tickedAtt];
                tickable = YES;
                tickedVal = [attVal isEqualToString:@"true"];
            }
            tickedAtt = tickedAtt->next;
        }
        
        [loadedFieldValues setObject:tickable? tickedVal ? val : @"" : val forKey:fieldId];
        NSString *fieldName = nil;
        for (IWPageDescriptor *pge in pageServer.pages.objectEnumerator) {
            for (IWFieldDescriptor *fld in pge.fieldDescriptors) {
                if ([fld.fieldId isEqualToString:fieldId]) {
                    fieldName = fld.fdtFieldName;
                    break;
                }
            }
            if (fieldName != nil) break;
            //check radios
            for (NSArray *list in pge.radioGroups.objectEnumerator) {
                for (IWRadioButtonDescriptor  *rbd in list) {
                    if ([rbd.fieldId isEqualToString:fieldId]) {
                        fieldName = rbd.fdtFieldName;
                        break;
                    }
                }
                if (fieldName != nil) break;
            }
        }
//        if (fieldName != nil) {
//            [self triggerPanelField:fieldName value:(tickable & tickedVal) || (!tickable && ![val isEqualToString:@""])];
//            [self.pageServer triggerField:fieldName with:(tickable & tickedVal) || !tickable];
//        }
        fldElem = fldElem->nextSibling;
    }
}

- (BOOL) loadPrepopDataWithPanel:(IWDynamicPanel *)panel field:(IWPrepopField *)fld {
    BOOL found = NO;
    for (NSObject *o in panel.children) {
        if ([o isKindOfClass:[IWDynamicPanel class]]) {
            found = [self loadPrepopDataWithPanel:(IWDynamicPanel *)o field:fld];
            if (found) break;
            continue;
        }
        if ([o isKindOfClass:[IWFieldDescriptor class]]) {
            //field descriptor.... check the name
            IWFieldDescriptor *field = (IWFieldDescriptor *)o;
            if ([field.fdtFieldName isEqualToString:fld.FieldName]) {
                [loadedFieldValues setObject:fld.FieldValue forKey:field.fieldId];
                found = YES;
                break;
            }
            continue;
        }
    }
    
    return found;
}

- (void) loadPrepopData {
    if ([IWInkworksService getInstance].currentPrepopItem == nil) return;
    IWSwiftDbHelper *swift = [IWInkworksService dbHelper];
    NSArray *fields = [swift getPrepopFields:[IWInkworksService getInstance].currentPrepopItem.ColumnIndex];
    
    
    for (IWPrepopField *fld in fields) {
        BOOL found = NO;
        for (IWPageDescriptor *page in pageServer.pages.objectEnumerator) {
            for (IWFieldDescriptor *field in page.fieldDescriptors) {
                if ([field.fdtFieldName isEqualToString:fld.FieldName]) {
                    [loadedFieldValues setObject:fld.FieldValue forKey:field.fieldId];
                    found = YES;
                    break;
                }
                for (IWDynamicPanel *panel in page.panels.objectEnumerator) {
                    found = [self loadPrepopDataWithPanel:panel field:fld];
                    if (found) break;
                }
                if (found) break;
            }
            if (found) break;
        }
    }
    
    for (IWPrepopField *field in fields) {
        
        NSString *val = field.FieldValue;
        NSString *fieldName = field.FieldName;
        
        UIView *fld = nil;
        for (NSString *key in allViews.keyEnumerator) {
            fld = (UIView *)allViews[key];
            
            if (fld) {
                if ([fld isKindOfClass:[IWDecimalFieldView class]]){
                    IWDecimalFieldView *decFld = (IWDecimalFieldView *)fld;
                    if (![decFld.descriptor.fdtFieldName isEqualToString:fieldName]) continue;
                    [self triggerPanelField:decFld.descriptor.fdtFieldName value:![val isEqualToString:@""]];
                    [self.pageServer triggerField:decFld.descriptor.fdtFieldName with:![val isEqualToString:@""]];
                    [decFld setValue:val];
                    [decFld setPrepop];
                } else if ([fld isKindOfClass:[IWDateTimeFieldView class]]){
                    IWDateTimeFieldView *dtFld = (IWDateTimeFieldView *)fld;
                    
                    if (![dtFld.descriptor.fdtFieldName isEqualToString:fieldName]) continue;
                    [self triggerPanelField:dtFld.descriptor.fdtFieldName value:![val isEqualToString:@""]];
                    [self.pageServer triggerField:dtFld.descriptor.fdtFieldName with:![val isEqualToString:@""]];
                    [dtFld setValue:val];
                    [dtFld setPrepop];
                } else if ([fld isKindOfClass:[IWIsoFieldView class]]){
                    IWIsoFieldView *isoFld = (IWIsoFieldView *)fld;
                    
                    if (![isoFld.descriptor.fdtFieldName isEqualToString:fieldName]) continue;
                    [isoFld setValue:val];
                    [isoFld setPrepop];
                    [self triggerPanelField:isoFld.descriptor.fdtFieldName value:![val isEqualToString:@""]];
                    [self.pageServer triggerField:isoFld.descriptor.fdtFieldName with:![val isEqualToString:@""]];
                } else if ([fld isKindOfClass:[IWTickBox class]]){
                    continue;
                } else if ([fld isKindOfClass:[IWDropDown class]]){
                    IWDropDown *dFld = (IWDropDown *)fld;
                    
                    if (![dFld.descriptor.fdtFieldName isEqualToString:fieldName]) continue;
                    dFld.selectedValue = val;
                    dFld.selLabel.text = dFld.selectedValue;
                    dFld.selText.text = dFld.selectedValue;
                    
                    [self triggerPanelField:dFld.descriptor.fdtFieldName value:![val isEqualToString:@""]];
                    [self.pageServer triggerField:dFld.descriptor.fdtFieldName with:![val isEqualToString:@""]];
                } else if ([fld isKindOfClass:[IWNotesView class]]){
                    IWNotesView *nFld = (IWNotesView *)fld;
                    
                    if (![nFld.descriptor.fdtFieldName isEqualToString:fieldName]) continue;
                    NSArray *split = [val componentsSeparatedByString:@"§§§"];
                    // 0 = nothing. 1 = limit. 2 = size. 3 = text;
                    if ([split count] > 2){
                        nFld.text = [split objectAtIndex:3];
                        
                        [self triggerPanelField:nFld.descriptor.fdtFieldName value:![[split objectAtIndex:3] isEqualToString:@""]];
                        [self.pageServer triggerField:nFld.descriptor.fdtFieldName with:![[split objectAtIndex:3] isEqualToString:@""]];
                    } else {
                        nFld.text = val;
                        [nFld setPrepop];
                        [self triggerPanelField:nFld.descriptor.fdtFieldName value:![val isEqualToString:@""]];
                        [self.pageServer triggerField:nFld.descriptor.fdtFieldName with:![val isEqualToString:@""]];
                    }
                }
            }
        }
        
        

    }
    
}

- (void)loadForm:(NSDictionary *)pageInfo {
    
    /*
     [((NSMutableArray *) repeatingPanelIds[pointer]) removeObjectAtIndex:panelIndex];
     [((NSMutableArray *) repeatingPanelsLayouts[pointer]) removeObjectAtIndex:panelIndex];
     [((CSLinearLayoutView *) repeatingPanels[pointer]) removeItem:((CSLinearLayoutView *) repeatingPanels[pointer]).items[panelIndex]];
     [((NSMutableArray *) repeatingDecriptors[pointer]) removeObjectAtIndex:panelIndex];
     [((NSMutableArray *) repeatingFields[pointer]) removeObjectAtIndex:panelIndex];
     [((NSMutableArray *) repeatingRadioManagers[pointer]) removeObjectAtIndex:panelIndex];
     [((NSMutableArray *) dynamicMinusButtons[pointer]) removeObjectAtIndex:panelIndex];
     [((NSMutableArray *) dynamicPlusButtons[pointer]) removeObjectAtIndex:panelIndex];
     */
    //self.shouldProcessVisibility = NO;
    
    NSString *procPage = [pageInfo objectForKey:@"proc"];
    NSString *strokePage = [pageInfo objectForKey:@"strokes"];
    NSError *error;
    TBXML *procXml = [[TBXML alloc] initWithXMLString:procPage error:&error];
    TBXML *strokeXml = [[TBXML alloc] initWithXMLString:strokePage error:&error];
    
    TBXMLElement *procRoot = procXml.rootXMLElement;
    TBXMLElement *strokesRoot = strokeXml.rootXMLElement;
    
    TBXMLElement *strokesElement = strokesRoot->firstChild;
    TBXMLElement *unassignedElement = strokesElement->firstChild;
    
    TBXMLElement *fieldsElement = procRoot->firstChild;
    
    TBXMLElement *fldElem = fieldsElement->firstChild;
    
    while (fldElem) {
        
        if ([[TBXML elementName:fldElem] isEqualToString:@"repeating"]) {
            IWDynamicPanel *panel;
            NSString *panelName = @"";
            TBXMLAttribute *att = fldElem->firstAttribute;
            while (att) {
                
                if ([[TBXML attributeName:att] isEqualToString:@"fieldid"]) {
                    panelName = [TBXML attributeValue:att];
                    break;
                }
                
                att = att->next;
            }
            
            for (NSString *pointer in panelPointers) {
                IWDynamicPanel *testPan = panelPointers[pointer];
                if ([testPan.fieldId isEqualToString:panelName]) {
                    panel = testPan;
                    break;
                }
            }
            
            TBXMLElement *instance = fldElem->firstChild;
            while (instance) {
                
                if (![[TBXML elementName:instance] isEqualToString:@"instance"]){
                    instance = instance->nextSibling;
                    continue;
                }
                
                TBXMLAttribute *instAtt = instance->firstAttribute;
                int instanceId = -1;
                while (instAtt) {
                    
                    if ([[TBXML attributeName:instAtt] isEqualToString:@"id"]) {
                        NSString *attVal = [TBXML attributeValue:instAtt];
                        instanceId = [attVal intValue];
                    }
                    
                    instAtt = instAtt->next;
                }
                
                NSString *pointer = [NSString stringWithFormat:@"%p", panel];
                if (((NSMutableArray *) repeatingDecriptors[pointer]).count - 1 < instanceId) {
                    [self handleRepeatingPanel:panel page:pageServer.pages[[NSNumber numberWithInt: pageToRender]] panelledView:panelledView parentPanel:nil panellLeft:0 panelTop:0 panelIndex:instanceId];
                }
                
                TBXMLElement *repFieldElem = instance->firstChild;
                while (repFieldElem) {
                    
                    TBXMLAttribute *fieldIdAtt = repFieldElem->firstAttribute;
                    NSString *fieldId = [TBXML attributeValue:fieldIdAtt];
                    
                    TBXMLElement *valueNode = repFieldElem->firstChild;
                    NSString *val = [TBXML textForElement:valueNode];
                    if (val == nil) val = @"";
                    val = [val stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
                    val = [val stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
                    val = [val stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
                    val = [val stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                    
                    
                    BOOL tickedVal = NO;
                    BOOL scanned = NO;
                    TBXMLAttribute *tickedAtt = valueNode->firstAttribute;
                    while (tickedAtt){
                        NSString *attName = [TBXML attributeName:tickedAtt];
                        if ([attName isEqualToString:@"ticked"]){
                            NSString *attVal = [TBXML attributeValue:tickedAtt];
                            tickedVal = [attVal isEqualToString:@"true"];
                        } else if ([attName isEqualToString:@"scanned"]) {
                            NSString *attVal = [TBXML attributeValue:tickedAtt];
                            scanned = [attVal isEqualToString:@"true"];
                        }
                        tickedAtt = tickedAtt->next;
                    }
                    
                    IWFieldDescriptor *fldDesc = nil;
                    for (IWFieldDescriptor *desc in repeatingDecriptors[pointer][instanceId]) {
                        if ([desc.fieldId isEqualToString:fieldId]) {
                            fldDesc = desc;
                            break;
                        }
                    }
                    
                    UIView *fld = repeatingFields[pointer][instanceId][[NSValue valueWithNonretainedObject:fldDesc]];
                    if (fld) {
                        if ([fld isKindOfClass:[IWTabletImageView class]]) {
                            IWTabletImageView *tiFld = (IWTabletImageView *)fld;
                            [self triggerPanelField:fieldId value:![val isEqualToString:@""]];
                            [self.pageServer triggerField:fieldId with:![val isEqualToString:@""]];
                            if ([val rangeOfString:@"{UUID}"].location != NSNotFound) {
                                NSString *uuidStr = [[val stringByReplacingOccurrencesOfString:@"{UUID}" withString:@""] stringByReplacingOccurrencesOfString:@"{/UUID}" withString:@""];
                                NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidStr];
                                [tiFld setImageFromUUID:uuid];
                                [[IWInkworksService getInstance].currentProcessor.embeddedPhotos addObject:tiFld];
                            } else if ([val rangeOfString:@"{PH}"].location != NSNotFound) {
                                NSString *localStr = [[val stringByReplacingOccurrencesOfString:@"{PH}" withString:@""] stringByReplacingOccurrencesOfString:@"{/PH}" withString:@""];
                                PHFetchOptions *opts = [[PHFetchOptions alloc] init];
                                opts.includeAssetSourceTypes = PHAssetSourceTypeCloudShared | PHAssetSourceTypeUserLibrary;
                                PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[localStr] options:opts];
                                if (result.count > 0) {
                                    PHAsset *asset = [result firstObject];
                                    [tiFld setImageFromAsset:asset];
                                    [[IWInkworksService getInstance].currentProcessor.embeddedPhotos addObject:tiFld];
                                }
                            }
                        } else if ([fld isKindOfClass:[IWDecimalFieldView class]]){
                            IWDecimalFieldView *decFld = (IWDecimalFieldView *)fld;
                            [self triggerPanelField:fieldId value:[val isEqualToString:@""]];
                            [self.pageServer triggerField:fieldId with:[val isEqualToString:@""]];
                            [decFld setValue:val];
                        } else if ([fld isKindOfClass:[IWDateTimeFieldView class]]){
                            IWDateTimeFieldView *dtFld = (IWDateTimeFieldView *)fld;
                            [self triggerPanelField:fieldId value:[val isEqualToString:@""]];
                            [self.pageServer triggerField:fieldId with:[val isEqualToString:@""]];
                            [dtFld setValue:val];
                        } else if ([fld isKindOfClass:[IWIsoFieldView class]]){
                            IWIsoFieldView *isoFld = (IWIsoFieldView *)fld;
                            [isoFld setValue:val];
                            [self triggerPanelField:fieldId value:[val isEqualToString:@""]];
                            [self.pageServer triggerField:fieldId with:[val isEqualToString:@""]];
                        } else if ([fld isKindOfClass:[IWTickBox class]]){
                            IWTickBox *tbFld = (IWTickBox *)fld;
                            if (tickedVal) {
                                [tbFld toggleOnOnly];
                                
                                [self triggerPanelField:fieldId value:YES];
//                                [self.pageServer triggerField:fieldId with:YES];
                            }
                        } else if ([fld isKindOfClass:[IWDropDown class]]){
                            IWDropDown *dFld = (IWDropDown *)fld;
                            dFld.selectedValue = val;
                            dFld.selLabel.text = dFld.selectedValue;
                            dFld.selText.text = dFld.selectedValue;
                            
                            [self triggerPanelField:fieldId value:[val isEqualToString:@""]];
                            [self.pageServer triggerField:fieldId with:[val isEqualToString:@""]];
                            if (dFld.descriptor.isCalc) {
                                [self recalculateFields];
                            }
                        } else if ([fld isKindOfClass:[IWNotesView class]]){
                            IWNotesView *nFld = (IWNotesView *)fld;
                            NSArray *split = [val componentsSeparatedByString:@"§§§"];
                            // 0 = nothing. 1 = limit. 2 = size. 3 = text;
                            if ([split count] > 2){
                                nFld.text = [split objectAtIndex:3];
                                NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:nFld.text];
                                [attString addAttribute:NSKernAttributeName value:@1.5 range:NSMakeRange(0, nFld.text.length)];
                                [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ArialMT" size:15] range:NSMakeRange(0, nFld.text.length)];
                                [attString addAttribute:NSForegroundColorAttributeName value:scanned? [UIColor redColor] :[UIColor blackColor] range:NSMakeRange(0, nFld.text.length)];
                                nFld.attributedText = attString;
                                [self triggerPanelField:fieldId value:[[split objectAtIndex:3] isEqualToString:@""]];
                                [self.pageServer triggerField:fieldId with:[[split objectAtIndex:3] isEqualToString:@""]];
                            } else {
                                nFld.text = val;
                                NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:nFld.text];
                                [attString addAttribute:NSKernAttributeName value:@1.5 range:NSMakeRange(0, nFld.text.length)];
                                [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ArialMT" size:15] range:NSMakeRange(0, nFld.text.length)];
                                [attString addAttribute:NSForegroundColorAttributeName value:scanned? [UIColor redColor] :[UIColor blackColor] range:NSMakeRange(0, nFld.text.length)];
                                nFld.attributedText = attString;
                                [self triggerPanelField:fieldId value:[val isEqualToString:@""]];
                                [self.pageServer triggerField:fieldId with:[val isEqualToString:@""]];
                            }
                            if (scanned) {
                                nFld.scanned = YES;
                            }
                        }
                    } else {
                        // could be a radio...
                        for (NSString *group in repeatingRadioManagers[pointer][instanceId]){
                            IWRadioButtonManager *rbm = [repeatingRadioManagers[pointer][instanceId] objectForKey:group];
                            fld = [rbm.radios objectForKey:fieldId];
                            if (fld != nil) break;
                            
                        }
                        if (fld != nil) {
                            IWRadioButton *rb = (IWRadioButton *)fld;
                            if (tickedVal) {
                                rb.isTicked = YES;
                                [rb.selector setHidden:NO];
                                
                                [self triggerPanelField:fieldId value:YES];
                                //[self.pageServer triggerField:fieldId with:YES];
                            }
                        }
                    }

                    
                    repFieldElem = repFieldElem->nextSibling;
                }
                
                instance = instance->nextSibling;
            }
            fldElem = fldElem->nextSibling;
            continue;
        }
        
        TBXMLAttribute *fieldIdAtt = fldElem->firstAttribute;
        NSString *fieldId = [TBXML attributeValue:fieldIdAtt];
        
        TBXMLElement *valueNode = fldElem->firstChild;
        NSString *val = [TBXML textForElement:valueNode];
        if (val == nil) val = @"";
        val = [val stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        val = [val stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
        val = [val stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
        val = [val stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
        
        
        BOOL tickedVal = NO;
        BOOL scanned = NO;
        BOOL isTickable = NO;
        TBXMLAttribute *tickedAtt = valueNode->firstAttribute;
        while (tickedAtt){
            NSString *attName = [TBXML attributeName:tickedAtt];
            if ([attName isEqualToString:@"ticked"]){
                NSString *attVal = [TBXML attributeValue:tickedAtt];
                tickedVal = [attVal isEqualToString:@"true"];
                isTickable = YES;
            } else if ([attName isEqualToString:@"scanned"]) {
                NSString *attVal = [TBXML attributeValue:tickedAtt];
                scanned = [attVal isEqualToString:@"true"];
            }
            tickedAtt = tickedAtt->next;
        }
        
        
        UIView *fld = [allViews objectForKey:fieldId];
        if (fld) {
            if ([fld isKindOfClass:[IWTabletImageView class]]) {
                IWTabletImageView *tiFld = (IWTabletImageView *)fld;
                [self triggerPanelField:fieldId value:![val isEqualToString:@""]];
                [self.pageServer triggerField:fieldId with:![val isEqualToString:@""]];
                if ([val rangeOfString:@"{UUID}"].location != NSNotFound) {
                    NSString *uuidStr = [[val stringByReplacingOccurrencesOfString:@"{UUID}" withString:@""] stringByReplacingOccurrencesOfString:@"{/UUID}" withString:@""];
                    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidStr];
                    [tiFld setImageFromUUID:uuid];
                    [[IWInkworksService getInstance].currentProcessor.embeddedPhotos addObject:tiFld];
                } else if ([val rangeOfString:@"{PH}"].location != NSNotFound) {
                    NSString *localStr = [[val stringByReplacingOccurrencesOfString:@"{PH}" withString:@""] stringByReplacingOccurrencesOfString:@"{/PH}" withString:@""];
                    PHFetchOptions *opts = [[PHFetchOptions alloc] init];
                    opts.includeAssetSourceTypes = PHAssetSourceTypeCloudShared | PHAssetSourceTypeUserLibrary;
                    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[localStr] options:opts];
                    if (result.count > 0) {
                        PHAsset *asset = [result firstObject];
                        [tiFld setImageFromAsset:asset];
                        [[IWInkworksService getInstance].currentProcessor.embeddedPhotos addObject:tiFld];
                    }
                }
            } else if ([fld isKindOfClass:[IWDecimalFieldView class]]){
                IWDecimalFieldView *decFld = (IWDecimalFieldView *)fld;
                [self triggerPanelField:decFld.descriptor.fdtFieldName value:![val isEqualToString:@""]];
                [self.pageServer triggerField:decFld.descriptor.fdtFieldName with:![val isEqualToString:@""]];
                [decFld setValue:val];
            } else if ([fld isKindOfClass:[IWDateTimeFieldView class]]){
                IWDateTimeFieldView *dtFld = (IWDateTimeFieldView *)fld;
                [self triggerPanelField:dtFld.descriptor.fdtFieldName value:![val isEqualToString:@""]];
                [self.pageServer triggerField:dtFld.descriptor.fdtFieldName with:![val isEqualToString:@""]];
                [dtFld setValue:val];
            } else if ([fld isKindOfClass:[IWIsoFieldView class]]){
                IWIsoFieldView *isoFld = (IWIsoFieldView *)fld;
                [isoFld setValue:val];
                [self triggerPanelField:isoFld.descriptor.fdtFieldName value:![val isEqualToString:@""]];
                [self.pageServer triggerField:isoFld.descriptor.fdtFieldName with:![val isEqualToString:@""]];
            } else if ([fld isKindOfClass:[IWTickBox class]]){
                IWTickBox *tbFld = (IWTickBox *)fld;
                if (tickedVal) {
                    [tbFld toggleOnOnly];
                
                    [self triggerPanelField:tbFld.descriptor.fdtFieldName value:YES];
//                    [self.pageServer triggerField:tbFld.descriptor.fdtFieldName with:YES];
                }
            } else if ([fld isKindOfClass:[IWDropDown class]]){
                IWDropDown *dFld = (IWDropDown *)fld;
                dFld.selectedValue = val;
                dFld.selLabel.text = dFld.selectedValue;
                dFld.selText.text = dFld.selectedValue;
                
                [self triggerPanelField:dFld.descriptor.fdtFieldName value:![val isEqualToString:@""]];
                [self.pageServer triggerField:dFld.descriptor.fdtFieldName with:![val isEqualToString:@""]];
                if (dFld.descriptor.isCalc) {
                    [self recalculateFields];
                }
            } else if ([fld isKindOfClass:[IWNotesView class]]){
                IWNotesView *nFld = (IWNotesView *)fld;
                NSArray *split = [val componentsSeparatedByString:@"§§§"];
                // 0 = nothing. 1 = limit. 2 = size. 3 = text;
                if ([split count] > 3){
                    nFld.text = [split objectAtIndex:3];
                    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:nFld.text];
                    [attString addAttribute:NSKernAttributeName value:@1.5 range:NSMakeRange(0, nFld.text.length)];
                    [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ArialMT" size:15] range:NSMakeRange(0, nFld.text.length)];
                    [attString addAttribute:NSForegroundColorAttributeName value:scanned ? [UIColor redColor] : [UIColor blackColor] range:NSMakeRange(0, nFld.text.length)];
                    nFld.attributedText = attString;
                    [self triggerPanelField:nFld.descriptor.fdtFieldName value:![[split objectAtIndex:3] isEqualToString:@""]];
                    [self.pageServer triggerField:nFld.descriptor.fdtFieldName with:![[split objectAtIndex:3] isEqualToString:@""]];
                } else {
                    nFld.text = val;
                    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:nFld.text];
                    [attString addAttribute:NSKernAttributeName value:@1.5 range:NSMakeRange(0, nFld.text.length)];
                    [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ArialMT" size:15] range:NSMakeRange(0, nFld.text.length)];
                    [attString addAttribute:NSForegroundColorAttributeName value:scanned? [UIColor redColor]: [UIColor blackColor] range:NSMakeRange(0, nFld.text.length)];
                    nFld.attributedText = attString;
                    [self triggerPanelField:nFld.descriptor.fdtFieldName value:![val isEqualToString:@""]];
                    [self.pageServer triggerField:nFld.descriptor.fdtFieldName with:![val isEqualToString:@""]];
                }
                if (scanned) {
                    nFld.scanned = YES;
                }
            }
        } else {
            // could be a radio...
            for (NSString *group in radioGroupManagers){
                IWRadioButtonManager *rbm = [radioGroupManagers objectForKey:group];
                fld = [rbm.radios objectForKey:fieldId];
                if (fld != nil) break;
                
            }
            if (fld != nil) {
                IWRadioButton *rb = (IWRadioButton *)fld;
                if (tickedVal) {
                    rb.isTicked = YES;
                    [rb.selector setHidden:NO];
                    
                    [self triggerPanelField:rb.descriptor.fdtFieldName value:YES];
                    //[self.pageServer triggerField:rb.descriptor.fdtFieldName with:YES];
                }
            } else {
                NSString *fieldName = formDescriptor.allFieldIds[fieldId];
                //loadedFieldTriggers[fieldName] = [NSString stringWithFormat:@"%@%@", !isTickable ? @"" : tickedVal ? @"{YES}" : @"{NO}", val];
                if (isTickable) {
                    if (tickedVal) {
                        if (fieldName) {
                            [self triggerPanelField:fieldName value:YES];
                        }
                    }
                }
            }
            
            
            
        }
        
        fldElem = fldElem->nextSibling;
    }
    
    TBXMLElement *stroke = unassignedElement->firstChild;
    while (stroke) {
        
        TBXMLAttribute *att = stroke->firstAttribute;
        NSString *fieldId = @"";
        while (att) {
            NSString *attName = [TBXML attributeName:att];
            if ([attName isEqualToString:@"fieldid"]){
                fieldId = [TBXML attributeValue:att];
            }
            att = att->next;
        }
        
        if (fieldId == nil) fieldId = @"";
        IWDrawingField *drawField = nil;
        if ([fieldId rangeOfString:@"_"].location == NSNotFound) {
            drawField = [allViews objectForKey:fieldId];
            
        } else {
            //repeating field...
            
            NSArray *split = [fieldId componentsSeparatedByString:@"_"];
            NSString *fieldIdName = split[0];
            NSString *index = split[1];
            int ind = [index intValue];
            
            for (NSString *p in repeatingDecriptors) {
                if (((NSArray *)repeatingDecriptors[p]).count > ind) {
                    for (IWFieldDescriptor *fld in repeatingDecriptors[p][ind]) {
                        if (![fld isKindOfClass:[IWDrawingFieldDescriptor class]] && ![fld isKindOfClass:[IWNoteFieldDescriptor class]]) continue;
                        if ([fld isKindOfClass:[IWDrawingFieldDescriptor class]]) {
                            if ([[((IWDrawingFieldDescriptor *)fld) repeatingFieldId] isEqualToString:fieldId]) {
                                IWDrawingFieldDescriptor *fieldDesc = (IWDrawingFieldDescriptor *)fld;
                                drawField = repeatingFields[p][ind][[NSValue valueWithNonretainedObject:fieldDesc]];
                                break;
                            }
                        } else {
                            if ([[((IWNoteFieldDescriptor *)fld) repeatingFieldId] isEqualToString:fieldId]) {
                                IWNoteFieldDescriptor *fieldDesc = (IWNoteFieldDescriptor *)fld;
                                drawField = repeatingFields[p][ind][[NSValue valueWithNonretainedObject:fieldDesc]];
                                break;
                            }
                        }
                        
                    }
                }
                
            }
            
        }
        
        IWCustomPath *path = [[IWCustomPath alloc] initWithOrigin:drawField.frame.origin];
        CGPoint ori = drawField.origin;
        TBXMLElement *sample = stroke->firstChild;
        while (sample){
            
            NSString *xVal = @"";
            NSString *yVal = @"";
            
            TBXMLAttribute *att = sample->firstAttribute;
            while (att) {
                NSString *attName = [TBXML attributeName:att];
                if ([attName isEqualToString:@"x"]){
                    xVal = [TBXML attributeValue:att];
                } else if ([attName isEqualToString:@"y"]) {
                    yVal = [TBXML attributeValue:att];
                }
                
                att = att->next;
            }
            
            float x = [xVal floatValue];
            float y = [yVal floatValue];
            
            
            
            if ([path.xArray count] == 0){
                [path moveTo:CGPointMake(x - ori.x, y - ori.y)];
            } else {
                [path pathTo:CGPointMake(x - ori.x, y - ori.y)];
            }
            
            sample = sample->nextSibling;
        }
        [drawField.paths addObject:path];
        stroke = stroke->nextSibling;
    }
    self.shouldProcessVisibility = YES;
    
    IWPageDescriptor *currPage = nil;
    for (IWPageDescriptor *pg in formDescriptor.pageDescriptors) {
        if ([pageServer getModdedPageNumber:pg.pageNumber-1] == pageToRender) {
            currPage = pg;
        }
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        for (IWDynamicPanel *panel in currPage.panels) {
            [self processPanelVisibility:panel];
        }
    });
    [self recalculateFields];
}

#pragma mark new fucntions for dynamic update

-(void)setNegatedOnPanel:(IWDynamicPanel *) panel field:(NSString *) fieldName value:(BOOL) negated {
    [panel setField:fieldName negated:negated];
    for (NSObject *o in panel.children) {
        if (![o isKindOfClass:[IWDynamicPanel class]])  {
            continue;
        }
        
        IWDynamicPanel *subPanel = (IWDynamicPanel *) o;
        [self setNegatedOnPanel:subPanel field:fieldName value:negated];
        
    }
    
}


-(void)setField:(NSString *) fieldName negated:(BOOL)negated {
    for (IWPageDescriptor *page in pageServer.pages.objectEnumerator) {
        for (IWDynamicPanel *panel in page.panels) {
            [self setNegatedOnPanel:panel field:fieldName value:negated];
        }
    }

}

-(void)negateSubTriggers:(IWDynamicPanel *) panel forPage:(IWPageDescriptor *) page {
    
    for (NSObject *o in panel.children) {
        if ([o isKindOfClass:[IWDynamicPanel class]]) {
            [self negateSubTriggers:(IWDynamicPanel *)o forPage:page];
            continue;
        }
        
        if ([o isKindOfClass:[IWImageDescriptor class]]
            || [o isKindOfClass:[IWLineDescriptor class]]
            || [o isKindOfClass:[IWRectangleDescriptor class]]
            || [o isKindOfClass:[IWRoundedRectangleDescriptor class]]
            || [o isKindOfClass:[IWTextLabelDescriptor class]]) {
            continue;
        }
        if ([o isKindOfClass:[NSString class]]) {
            NSMutableDictionary *radioButtonGroups = page.repeatingRadioGroups;
            NSString *groupName = (NSString *) o;
            if (!radioButtonGroups[groupName]) continue;
            for (IWRadioButtonDescriptor *rbd in radioButtonGroups[groupName]) {
                [self setField:rbd.fdtFieldName negated:YES];
            }
            continue;
        }
        IWElementDescriptor *element = (IWElementDescriptor *) o;
        [self setField:element.fdtFieldName negated:YES];
    }
    
}

-(void)unNegateSubTriggers:(IWDynamicPanel *) panel forPage:(IWPageDescriptor *) page {
    for (NSObject *o in panel.children) {
        if ([o isKindOfClass:[IWDynamicPanel class]]) {
            IWDynamicPanel *p = (IWDynamicPanel *) o;
            if (p.shouldShowPanel) {
                [self unNegateSubTriggers:p forPage:page];
            } else {
                [self negateSubTriggers:p forPage:page];
            }
            continue;
        }
        
        if ([o isKindOfClass:[IWImageDescriptor class]]
            || [o isKindOfClass:[IWLineDescriptor class]]
            || [o isKindOfClass:[IWRectangleDescriptor class]]
            || [o isKindOfClass:[IWRoundedRectangleDescriptor class]]
            || [o isKindOfClass:[IWTextLabelDescriptor class]]) {
            continue;
        }
        if ([o isKindOfClass:[NSString class]]) {
            NSMutableDictionary *radioButtonGroups = page.repeatingRadioGroups;
            NSString *groupName = (NSString *) o;
            if (!radioButtonGroups[groupName]) continue;
            for (IWRadioButtonDescriptor *rbd in radioButtonGroups[groupName]) {
                [self setField:rbd.fdtFieldName negated:NO];
            }
            continue;
        }
        IWElementDescriptor *element = (IWElementDescriptor *) o;
        [self setField:element.fdtFieldName negated:NO];
    }

    
    
    
}

-(void) triggerPanelField: (NSString *) fieldName value: (BOOL) triggerOn {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    
        for (IWPageDescriptor *page in pageServer.pages.objectEnumerator) {
            for (IWDynamicPanel *panel in page.panels) {
                if (panel.panelTriggers[fieldName]) {
                    [panel.panelTriggers setObject:[NSNumber numberWithBool:triggerOn] forKey:fieldName];
                }
                for (NSObject *o in panel.children) {
                    if (![o isKindOfClass:[IWDynamicPanel class]]) {
                        continue;
                    }
                    IWDynamicPanel *child = (IWDynamicPanel *) o;
                    [self triggerPanelField:fieldName value:triggerOn parentPanel:child];
                }
            }
            
        }
        for (IWPageDescriptor *page in pageServer.pages.objectEnumerator) {
            for (IWDynamicPanel *panel in page.panels) {
                //Could use panel.shouldShowPanel
                if ([panel shouldShowPanel]) {
                    [self unNegateSubTriggers:panel forPage:page];
                } else {
                    [self negateSubTriggers:panel forPage:page];
                }
            }
        }
        for (IWPageDescriptor *page in pageServer.pages.objectEnumerator) {
            for (IWDynamicPanel *panel in page.panels) {
                [self processPanelVisibility:panel];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [pageServer triggerField:fieldName with:triggerOn];
            
            [self recalculateFields];
        });
    
        
    });
}

-(void) triggerPanelField: (NSString *) fieldName value: (BOOL) triggerOn parentPanel:(IWDynamicPanel *) parent {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        BOOL triggered = NO;
        if (parent.panelTriggers[fieldName]) {
            triggered = YES;
            [parent.panelTriggers setObject:[NSNumber numberWithBool:triggerOn] forKey:fieldName];
        }
        for (NSObject *o in parent.children) {
            if (![o isKindOfClass:[IWDynamicPanel class]]) {
                continue;
            }
            IWDynamicPanel *child = (IWDynamicPanel *) o;
            [self triggerPanelField:fieldName value:triggerOn parentPanel:child];
        }
        [self processPanelVisibility:parent];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [formCanvas setNeedsDisplay];
        });
        
    });
}

- (void) recalculateFields {
    if (recalcing) {
        return;
    }
    recalcing = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    
        for (IWCalcList *calc in formDescriptor.formCalcFields) {
            
            // do Sum(...) first
            NSString *calcForm = [[calc.descriptor.calc stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"] stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
            NSError *error;
            NSRegularExpressionOptions options = NSRegularExpressionCaseInsensitive;
            NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"(?<SumFunction>[sS]um\\(\\s*#\\s*(?<CategoryField>[A-Za-z0-9]*)\\s*(?:\\s*:\\s*(?<ValueOrKey>\\w*))?\\s*#\\s*\\=\\s*\\'?(?<ValueToCompareTo>[A-Za-z0-9]*)\\'?\\s*,\\s*#(?<FieldToSumOver>[A-Za-z0-9]*)#\\s*\\))" options:options error:&error];
            NSArray *result = [regex matchesInString:calcForm options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, calcForm.length)];
            if (result.count > 0) {
                //go BACKWARDS - we will be replacing the text in this loop if we find a sum so don't want to break multiple Sums!
                for (int k = result.count - 1; k >= 0; k--) {
                    NSTextCheckingResult *res = result[k];
                    //loop each result string, replacing what's needed
                    
                    NSRange sumFunctionR = [res rangeAtIndex:1];
                    NSRange fieldNameR = [res rangeAtIndex:2];
                    NSRange fieldSubR = [res rangeAtIndex:3];
                    NSRange compareKeyR = [res rangeAtIndex:4];
                    NSRange sumFieldR = [res rangeAtIndex:5];
                    
                    NSString *sumFunction = [calcForm substringWithRange:sumFunctionR];
                    NSString *fieldName = [calcForm substringWithRange:fieldNameR];
                    NSString *fieldSub = nil;
                    if (fieldSubR.location != NSNotFound) {
                        fieldSub = [calcForm substringWithRange:fieldSubR];
                    }
                    NSString *compareKey = [calcForm substringWithRange:compareKeyR];
                    NSString *sumField = [calcForm substringWithRange:sumFieldR];
                    
                    //grab the fields required
                    NSMutableDictionary *fields = [NSMutableDictionary dictionary];
                    [fields setObject:[NSMutableArray array] forKey:fieldName];
                    [fields setObject:[NSMutableArray array] forKey:sumField];
                    for (NSString *pointer in repeatingCalcFields) {
                        BOOL found = NO;
                        for (NSString *fldName in repeatingCalcFields[pointer][0]) {
                            if ([fldName isEqualToString:fieldName]) {
                                //found the panel
                                
                                for (int i = 0; i < ((NSMutableArray *)repeatingCalcFields[pointer]).count; i++) {
                                    NSMutableDictionary *inputs = repeatingCalcFields[pointer][i];
                                    UIView *f = inputs[fieldName];
                                    if (f != nil) {
                                        [((NSMutableArray *)fields[fieldName]) addObject:f];
                                    }
                                    UIView *v = inputs[sumField];
                                    if (v != nil) {
                                        [((NSMutableArray *)fields[sumField]) addObject:v];
                                    }
                                }
                                found = YES;
                                break;
                            }
                        }
                        if (found) break;
                    }
                    
                    //should have inputs now...
                    double total = 0.0;
                    for (int i = 0; i < ((NSMutableArray *)fields[fieldName]).count; i++) {
                        IWDropDown *fld = ((NSMutableArray *)fields[fieldName])[i];
                        NSString *compare = fieldSub == nil ? [fld selectedValue] : [fld getVal];
                        if (![compare isEqualToString:compareKey]) {
                            continue;
                        }
                        
                        //comparison checks out, add this value!
                        double val = 0.0;
                        if (((NSMutableArray *)fields[sumField]).count > 0) {
                            if ([((NSMutableArray *)fields[sumField])[i] isKindOfClass:[IWIsoFieldView class]]) {
                                if (![[((NSMutableArray *)fields[sumField])[i] getValue] isEqualToString:@""]) {
                                    val = [[((NSMutableArray *)fields[sumField])[i] getValue] doubleValue];
                                }
                            } else if ([((NSMutableArray *)fields[sumField])[i] isKindOfClass:[IWDropDown class]]) {
                                if (![((IWDropDown *)((NSMutableArray *)fields[sumField])[i]).selectedValue isEqualToString:@""]) {
                                    bool status;
                                    NSScanner *scanner;
                                    NSString *testString = ((IWDropDown *)((NSMutableArray *)fields[sumField])[i]).selectedValue;
                                    double result;
                                    scanner = [NSScanner scannerWithString:testString];
                                    status = [scanner scanDouble:&result];
                                    status = status && scanner.scanLocation == testString.length;
                                    if (status) {
                                        val = result;
                                    }
                                    
                                }
                            }
                        }
                        total += val;
                    }
                    //all values checked and added, replace the sum with this now
                    calcForm = [calcForm stringByReplacingOccurrencesOfString:sumFunction withString:[NSString stringWithFormat:@"%f", total]];
                }
            }
            
            
            NSRegularExpression *regex2 = [[NSRegularExpression alloc] initWithPattern:@"(?<SumFunction>[sS]um\\(\\s*#(?<FieldToSumOver>[A-Za-z0-9]*)#\\s*\\))" options:options error:&error];
            NSArray *result2 = [regex2 matchesInString:calcForm options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, calcForm.length)];
            if (result2.count > 0) {
                //go BACKWARDS - we will be replacing the text in this loop if we find a sum so don't want to break multiple Sums!
                for (int k = result2.count - 1; k >= 0; k--) {
                    NSTextCheckingResult *res = result2[k];
                    //loop each result string, replacing what's needed
                    
                    NSRange sumFunctionR = [res rangeAtIndex:1];
                    
                    NSRange sumFieldR = [res rangeAtIndex:2];
                    
                    NSString *sumFunction = [calcForm substringWithRange:sumFunctionR];
                    NSString *sumField = [calcForm substringWithRange:sumFieldR];
                    
                    //grab the fields required
                    NSMutableDictionary *fields = [NSMutableDictionary dictionary];
                    [fields setObject:[NSMutableArray array] forKey:sumField];
                    for (NSString *pointer in repeatingCalcFields) {
                        BOOL found = NO;
                        for (NSString *fldName in repeatingCalcFields[pointer][0]) {
                            if ([fldName isEqualToString:sumField]) {
                                //found the panel
                                
                                for (int i = 0; i < ((NSMutableArray *)repeatingCalcFields[pointer]).count; i++) {
                                    NSMutableDictionary *inputs = repeatingCalcFields[pointer][i];
                                    UIView *v = inputs[sumField];
                                    if (v != nil) {
                                        [((NSMutableArray *)fields[sumField]) addObject:v];
                                    }
                                }
                                found = YES;
                                break;
                            }
                        }
                        if (found) break;
                    }
                    
                    //should have inputs now...
                    double total = 0.0;
                    for (int i = 0; i < ((NSMutableArray *)fields[sumField]).count; i++) {
                        
                        //comparison checks out, add this value!
                        double val = 0.0;
                        if (((NSMutableArray *)fields[sumField]).count > 0) {
                            if ([((NSMutableArray *)fields[sumField])[i] isKindOfClass:[IWIsoFieldView class]]) {
                                if (![[((NSMutableArray *)fields[sumField])[i] getValue] isEqualToString:@""]) {
                                    val = [[((NSMutableArray *)fields[sumField])[i] getValue] doubleValue];
                                }
                            } else if ([((NSMutableArray *)fields[sumField])[i] isKindOfClass:[IWDropDown class]]) {
                                if (![((IWDropDown *)((NSMutableArray *)fields[sumField])[i]).selectedValue isEqualToString:@""]) {
                                    bool status;
                                    NSScanner *scanner;
                                    NSString *testString = ((IWDropDown *)((NSMutableArray *)fields[sumField])[i]).selectedValue;
                                    double result;
                                    scanner = [NSScanner scannerWithString:testString];
                                    status = [scanner scanDouble:&result];
                                    status = status && scanner.scanLocation == testString.length;
                                    if (status) {
                                        val = result;
                                    }
                                    
                                }
                            }
                        }
                        total += val;
                    }
                    //all values checked and added, replace the sum with this now
                    calcForm = [calcForm stringByReplacingOccurrencesOfString:sumFunction withString:[NSString stringWithFormat:@"%f", total]];
                }
            }

            
            if (calc.fieldView == nil) {
                //could be repeating...
                BOOL isRepeating = false;
                for (NSString *pointer in repeatingCalcs) {
                    for (NSString *fldName in repeatingCalcs[pointer][0]) {
                        if ([fldName isEqualToString: calc.fieldName]) {
                            //found repeating...
                            isRepeating = true;
                            
                            for (int i = 0; i < ((NSMutableArray *)repeatingCalcs[pointer]).count; i++) {
                                NSMutableDictionary *possibleInputs = repeatingCalcFields[pointer][i];
                                IWIsoFieldView *actualView = repeatingCalcs[pointer][i][calc.fieldName];
                                NSMutableDictionary *inputs = [NSMutableDictionary dictionary];
                                for (NSString *fieldName in calc.inputs) {
                                    IWIsoFieldView *view = possibleInputs[fieldName];
                                    if (view != nil) {
                                        [inputs setObject:view forKey:fieldName];
                                    } else {
                                        view = calcInputs[fieldName];
                                        if (view != nil) {
                                            [inputs setObject:calcInputs[fieldName] forKey:fieldName];
                                        } else {
                                            [inputs setObject:@"0.0" forKey:fieldName];
                                        }
                                    }
                                }
                                
                                //got all inputs...
                                NSString *formula = calcForm;
                                for (NSString *fieldName in inputs) {
                                    NSString *hashField = [NSString stringWithFormat:@"#%@#", fieldName];
                                    double val = 0.0;
                                    if ([inputs[fieldName] isKindOfClass:[NSString class]]){
                                        val = 0.0;
                                        
                                        formula = [formula stringByReplacingOccurrencesOfString:hashField withString:[NSString stringWithFormat:@"%f", val]];
                                        //just in case...
                                        NSString *hashFieldValue =[NSString stringWithFormat:@"#%@:value#", fieldName];
                                        formula = [formula stringByReplacingOccurrencesOfString:hashFieldValue withString:[NSString stringWithFormat:@"%f", val]];
                                    } else if ([inputs[fieldName] isKindOfClass:[IWDropDown class]]) {
                                        NSString *hashFieldVal = [NSString stringWithFormat:@"#%@:value#", fieldName];
                                        NSString *hashFieldVal2 = [NSString stringWithFormat:@"#%@#", fieldName];
                                        
                                        IWDropDown *dd = (IWDropDown *)inputs[fieldName];
                                        NSString *ddVal = [dd getVal];
                                        if ([ddVal isEqualToString:@""]) {
                                            ddVal = @"0.0000";
                                        }
                                        NSString *ddText = @"0.0000";
                                        bool status;
                                        NSScanner *scanner;
                                        NSString *testString = dd.selectedValue;
                                        double result;
                                        scanner = [NSScanner scannerWithString:testString];
                                        status = [scanner scanDouble:&result];
                                        status = status && scanner.scanLocation == testString.length;
                                        if (status) {
                                            ddText = dd.selectedValue;
                                        }
                                        
                                        formula = [formula stringByReplacingOccurrencesOfString:hashFieldVal withString:ddVal];
                                        formula = [formula stringByReplacingOccurrencesOfString:hashFieldVal2 withString:ddText];
                                    } else {
                                        
                                        if ([[inputs[fieldName] getValue] isEqualToString:@""]) {
                                            val = 0.0;
                                        } else {
                                            val = [[inputs[fieldName] getValue] doubleValue];
                                        }
                                        
                                        formula = [formula stringByReplacingOccurrencesOfString:hashField withString:[NSString stringWithFormat:@"%f", val]];
                                    }
                                }
                                formula = [formula stringByReplacingOccurrencesOfString:@" " withString:@""];
                                if ([formula rangeOfString:@"/0.0"].location != NSNotFound) {
                                    //divide by 0!
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [actualView setValue:@""];
                                    });
                                } else {
                                    NSExpression *expression = [NSExpression expressionWithFormat:formula];
                                    NSNumber *result = [expression expressionValueWithObject:nil context:nil];
                                    NSNumber *max = [NSNumber numberWithDouble:0.0];
                                    if ([actualView isKindOfClass:[IWDecimalFieldView class]]) {
                                        IWDecimalFieldView *v = (IWDecimalFieldView *)actualView;
                                        NSArray *listArray = [v.descriptor.fdtListArray componentsSeparatedByString:@"|"];
                                        NSString *maxStr = @"";
                                        int firstNum = [listArray[0] intValue];
                                        int secondNum = 0;
                                        if (listArray.count > 1) {
                                            secondNum = [listArray[1] intValue];
                                        }
                                        for (int i = 0; i < firstNum; i++) {
                                            maxStr = [maxStr stringByAppendingString:@"9"];
                                        }
                                        if (secondNum > 0) {
                                            maxStr = [maxStr stringByAppendingString:@"."];
                                            for (int i = 0; i < secondNum; i++) {
                                                maxStr = [maxStr stringByAppendingString:@"9"];
                                            }
                                        }
                                        max = [NSNumber numberWithDouble:[maxStr doubleValue]];
                                        if (floor([result doubleValue]) > [max doubleValue]) {
                                            v.rawValue = [result doubleValue];
                                            v.calcErrored = YES;
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                
                                                [actualView setValue:[maxStr stringByReplacingOccurrencesOfString:@"9" withString:@"#"]];
                                            });
                                            continue;
                                        }
                                        v.calcErrored = NO;
                                        
                                    }
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        
                                        [actualView setValue:[NSString stringWithFormat:@"%@",result]];
                                    });
                                }
                                
                            }
                            
                            break;
                        }
                        if (isRepeating) break;
                    }
                    if (isRepeating) break;
                }
                
                continue;
            }
            NSMutableDictionary *inputs = [NSMutableDictionary dictionary];
            for (NSString *fieldName in calc.inputs) {
                IWIsoFieldView *view = calcInputs[fieldName];
                if (view != nil) {
                    [inputs setObject:view forKey:fieldName];
                } else {
                    IWDropDown *ddv = calcInputs[fieldName];
                    if (ddv != nil) {
                        [inputs setObject:ddv forKey:fieldName];
                    } else {
                        [inputs setObject:@"0.0" forKey:fieldName];
                    }
                }
            }
            
            //got all inputs...
            NSString *formula = calcForm;
            for (NSString *fieldName in inputs) {
                NSString *hashField = [NSString stringWithFormat:@"#%@#", fieldName];
                double val = 0.0;
                double hashVal = 0.0;
                if ([inputs[fieldName] isKindOfClass:[NSString class]]){
                    val = 0.0;
                } else if ([inputs[fieldName] isKindOfClass:[IWDropDown class]]) {
                    val = 0.0;
                    IWDropDown *ddv = (IWDropDown *)inputs[fieldName];
                    if (![ddv.selectedValue isEqualToString:@""]) {
                        hashVal = [[ddv getVal] doubleValue];
                        bool status;
                        NSScanner *scanner;
                        NSString *testString = ddv.selectedValue;
                        double result;
                        scanner = [NSScanner scannerWithString:testString];
                        status = [scanner scanDouble:&result];
                        status = status && scanner.scanLocation == testString.length;
                        if (status) {
                            val = result;
                        }
                    }
                } else {
                    if ([[inputs[fieldName] getValue] isEqualToString:@""]) {
                        val = 0.0;
                    } else {
                        if (((IWDecimalFieldView *)inputs[fieldName]).calcErrored) {
                            val = ((IWDecimalFieldView *)inputs[fieldName]).rawValue;
                        } else {
                            val = [[inputs[fieldName] getValue] doubleValue];
                        }
                    }
                }
                formula = [formula stringByReplacingOccurrencesOfString:hashField withString:[NSString stringWithFormat:@"%f", val]];
                //just in case
                NSString *hashFieldVal =[NSString stringWithFormat:@"#%@:value#", fieldName];
                formula = [formula stringByReplacingOccurrencesOfString:hashFieldVal withString:[NSString stringWithFormat:@"%f", hashVal]];
            }
            formula = [formula stringByReplacingOccurrencesOfString:@" " withString:@""];
            if ([formula rangeOfString:@"/0.0"].location != NSNotFound) {
                //divide by 0!
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                [calc.fieldView setValue:@""];
                });
            } else {
                if (calc.inputs.count == 1) {
                    NSString *inputName = [((NSString *)calc.inputs[0]) stringByReplacingOccurrencesOfString:@"#" withString:@""];
                    NSString *panelPointer = nil;
                    for (NSString *pointer in repeatingCalcFields) {
                        for (NSString *fldName in repeatingCalcFields[pointer][0]) {
                            if ([fldName isEqualToString:inputName]) {
                                panelPointer = pointer;
                                break;
                            }
                            if (panelPointer != nil) break;
                        }
                    }
                    if (panelPointer != nil) {
                        formula = @"";
                        for (int i = 0; i < ((NSMutableArray *)repeatingCalcFields[panelPointer]).count; i++) {
                            double val = 0.0;
                            
                            if ([[repeatingCalcFields[panelPointer][i][inputName] getValue] isEqualToString:@""]) {
                                val = 0.0;
                            } else {
                                if (((IWDecimalFieldView *)repeatingCalcFields[panelPointer][i][inputName]).calcErrored) {
                                    val = ((IWDecimalFieldView *)repeatingCalcFields[panelPointer][i][inputName]).rawValue;
                                } else {
                                    val = [[repeatingCalcFields[panelPointer][i][inputName] getValue] doubleValue];
                                }
                                
                                
                            }
                            
                            
                            formula = [formula stringByAppendingFormat:@"%@+", [NSString stringWithFormat:@"%f", val]];
                        }
                        formula = [formula stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"+"]];
                    }
                }
                NSRegularExpressionOptions opts = NSRegularExpressionCaseInsensitive;
                NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:@"sum\\(([^)]*)\\)" options:opts error:nil];
                NSArray *res = [reg matchesInString:formula options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0,formula.length)];
                if (res.count > 0) {
                    for (int k = res.count-1; k >= 0; k--) {
                        NSTextCheckingResult *match = res[k];
                        NSString *ma = [formula substringWithRange:[match rangeAtIndex:0]];
                        NSString *fo = [formula substringWithRange:[match rangeAtIndex:1]];
                        formula = [formula stringByReplacingOccurrencesOfString:ma withString:fo];
                    }
                }
                NSExpression *expression = [NSExpression expressionWithFormat:formula];
                NSNumber *result = [expression expressionValueWithObject:nil context:nil];
                NSNumber *max = [NSNumber numberWithDouble:0.0];
                if ([calc.fieldView isKindOfClass:[IWDecimalFieldView class]]) {
                    IWDecimalFieldView *v = (IWDecimalFieldView *)calc.fieldView;
                    NSArray *listArray = [v.descriptor.fdtListArray componentsSeparatedByString:@"|"];
                    NSString *maxStr = @"";
                    int firstNum = [listArray[0] intValue];
                    int secondNum = 0;
                    if (listArray.count > 1) {
                        secondNum = [listArray[1] intValue];
                    }
                    for (int i = 0; i < firstNum; i++) {
                        maxStr = [maxStr stringByAppendingString:@"9"];
                    }
                    if (secondNum > 0) {
                        maxStr = [maxStr stringByAppendingString:@"."];
                        for (int i = 0; i < secondNum; i++) {
                            maxStr = [maxStr stringByAppendingString:@"9"];
                        }
                    }
                    max = [NSNumber numberWithDouble:[maxStr doubleValue]];
                    if (floor([result doubleValue]) > [max doubleValue]) {
                        v.rawValue = [result doubleValue];
                        v.calcErrored = YES;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [calc.fieldView setValue:[maxStr stringByReplacingOccurrencesOfString:@"9" withString:@"#"]];
                        });
                        continue;
                    }
                    v.calcErrored = NO;
                    v.rawValue = [result doubleValue];
                }
                [calc.fieldView performSelectorOnMainThread:@selector(setValue:) withObject:[NSString stringWithFormat:@"%@",result] waitUntilDone:YES];
                //[calc.fieldView setValue:[NSString stringWithFormat:@"%@",result]];
                
            }
        }

        recalcing = NO;
    
    });
    
}

-(void) processPanelVisibility: (IWDynamicPanel *) panel {
    if (!self.shouldProcessVisibility) {
        return;
    }
    for (NSObject *o in panel.children) {
        if ([o isKindOfClass:[IWDynamicPanel class]]) {
            IWDynamicPanel *child = (IWDynamicPanel *) o;
            [self processPanelVisibility:child];
            
        }
    }
    NSString *pointer = [NSString stringWithFormat:@"%p", panel];
    UIView *panelLayout = panelLayouts[pointer];
    if ([panelLayout isKindOfClass:[CSLinearLayoutItem class]]) {
        panelLayout = ((CSLinearLayoutItem *)panelLayout).view;
    }
    if (panelLayout) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [panelLayout setHidden:![panel shouldShowPanel]];
            if (panel.shouldMoveFieldsBelow) {
                panelLayout.frame = CGRectMake(panelLayout.frame.origin.x, panelLayout.frame.origin.y, panelLayout.frame.size.width, [panel shouldShowPanel] ? panel.repeatingPanel ? ((NSMutableArray *)repeatingPanelsLayouts[pointer]).count * panel.rectArea.height : panel.rectArea.height : 0);
            }
        });
    }
    
    
}

@end
