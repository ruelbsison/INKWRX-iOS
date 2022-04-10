//
//  IWDropDown.m
//  Inkworks
//
//  Created by Jamie Duggan on 19/05/2014.
//  Copyright (c) 2014 Destiny Wireless. All rights reserved.
//

#import "IWDropDown.h"
#import "IWDataChangeHandler.h"
#import "IWInkworksService.h"
#import "IWFormRenderer.h"
#import <QuartzCore/QuartzCore.h>

@implementation IWDropDown

@synthesize lexicon, strokeColor, selectedValue, popController, selLabel, descriptor, selText, table, shortLexicon, values;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
bool enabled = YES;
- (id) initWithFrame:(CGRect)frame andLexicon:(NSArray *)lex andStrokeColor:(UIColor *)stroke descriptor:(IWDropdownDescriptor *)desc{
    self = [super initWithFrame:frame];
    if (self){
        
        values = [NSMutableDictionary dictionary];
        NSMutableArray *items = [NSMutableArray array];
        for (NSString *item in lex) {
            if ([item rangeOfString:@"="].location == NSNotFound) {
                [values setObject:@"" forKey:item];
                [items addObject:item];
            } else {
                NSRange loc = [item rangeOfString:@"="];
                NSString *key = [[item substringToIndex:loc.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString *val = [[item substringFromIndex:loc.location+1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                [items addObject:key];
                [values setObject:val forKey:key];
            }
        }
        [items addObject:@""];
        items = items.reverseObjectEnumerator.allObjects.mutableCopy;
        NSMutableArray *shortLex = [NSMutableArray array];
        [shortLex addObjectsFromArray:lex];
        [shortLex addObject:@""];
        shortLex = shortLex.reverseObjectEnumerator.allObjects.mutableCopy;
        self.lexicon = items;
        self.shortLexicon = shortLex;
        self.descriptor = desc;
        self.strokeColor = stroke;
        selectedValue = @"";
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderColor = [strokeColor CGColor];
        self.layer.borderWidth = 1.5;
        self.layer.backgroundColor = [[UIColor whiteColor] CGColor];
        
        
        selText = [[UITextField alloc] initWithFrame:CGRectMake(2, 2, frame.size.width - frame.size.height - 2, frame.size.height - 2)];
        [selText setDelegate:self];
        [selText addTarget:self action:@selector(editingStarted:) forControlEvents:UIControlEventEditingDidBegin];
        [selText addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        
        selLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 2, frame.size.width - frame.size.height - 2, frame.size.height - 2)];
        [selLabel setText:@""];
        [selLabel setHidden:YES];
        [self addSubview:selLabel];
        [self addSubview:selText];
        
        UIView *b = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width - frame.size.height, 0, frame.size.height, frame.size.height)];
        b.backgroundColor = [UIColor clearColor];
        b.layer.backgroundColor = [[UIColor whiteColor] CGColor];
        b.layer.borderColor = [self.strokeColor CGColor];
        b.layer.borderWidth = 1.5;
        
        NSString *arrow = @"▽";
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, b.frame.size.width, b.frame.size.height)];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:self.strokeColor];
        [label setText:arrow];
        
        [b addSubview:label];
        [self addSubview:b];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu)];
        [tap setDelegate:self];
        [b addGestureRecognizer:tap];
        
        UITapGestureRecognizer *maintap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editStart)];
        [maintap setDelegate:self];
        [selText addGestureRecognizer:maintap];
        
        
        
        UIView *popOverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height*10)];
        
        CGRect tableFrame = CGRectMake(popOverView.frame.origin.x, popOverView.frame.origin.y, popOverView.frame.size.width, popOverView.frame.size.height - 10);
        
        table = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
        table.separatorInset = UIEdgeInsetsZero;
        
        [table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        
        [table setDelegate:self];
        [table setDataSource:self];
        
        
        table.separatorColor = [UIColor whiteColor];
        table.transform = CGAffineTransformMakeScale(1, -1);
        
        [popOverView addSubview:table];
        
        UIViewController *popoverViewController = [[UIViewController alloc] init];
        popoverViewController.view = popOverView;
        
        popController = [[UIPopoverController alloc] initWithContentViewController:popoverViewController];
        
        //28628E
        popController.delegate = self;
        popController.backgroundColor = [UIColor colorWithRed:40 green:98 blue:142 alpha:1];
        popController.popoverContentSize = popOverView.frame.size;
        
        
    }
    
    return self;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [IWInkworksService getInstance].popController = nil;
}

- (void) editStart {
    if (!enabled) return;
    //[self.superview endEditing:YES];
    shortLexicon = [NSMutableArray array];
    for (NSString *sub in lexicon) {
        if ([sub isEqualToString:@""]) continue;
        [shortLexicon addObject:sub];
    }
    [shortLexicon addObject:@""];
    [table reloadData];

        [IWInkworksService getInstance].activeView = self.selText;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //if ([IWInkworksService getInstance].doReopenDropdwon) {
            [IWInkworksService getInstance].doReopenDropdwon = NO;
            [IWInkworksService getInstance].popController = popController;
            [popController presentPopoverFromRect:self.frame inView:self.superview permittedArrowDirections:UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown animated:NO];
            __weak UIView *popOverView = popController.contentViewController.view;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                CGRect tableFrame = CGRectMake(popOverView.frame.origin.x, popOverView.frame.origin.y, popOverView.frame.size.width, popOverView.frame.size.height - 10);
                table.frame = tableFrame;
                
                
            });
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:shortLexicon.count - 1 inSection:0];
            [table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:false];
            //            } else {
            //                __weak UIView *popOverView = popController.contentViewController.view;
            //                CGRect tableFrame = CGRectMake(popOverView.frame.origin.x, popOverView.frame.origin.y, popOverView.frame.size.width, popOverView.frame.size.height - 10);
            //                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //                    table.frame = tableFrame;
            //                });
            //}
        });
    

}

- (void) editingStarted: (UITextField *) textField {
    
}



- (void) showMenuAuto {
    if (!enabled) return;
    //[self.superview endEditing:YES];
    [IWInkworksService getInstance].popController = popController;
    [popController presentPopoverFromRect:self.frame inView:self.superview permittedArrowDirections:UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown animated:YES];
    __weak UIView *popOverView = popController.contentViewController.view;
    CGRect tableFrame = CGRectMake(popOverView.frame.origin.x, popOverView.frame.origin.y, popOverView.frame.size.width, popOverView.frame.size.height - 10);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        table.frame = tableFrame;
    });
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:shortLexicon.count - 1 inSection:0];
    [table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:false];
}

- (void) showMenu{
    if (!enabled) return;
    //[self.superview endEditing:YES];
    shortLexicon = [NSMutableArray array];
    for (NSString *sub in lexicon) {
        if ([sub isEqualToString:@""]) continue;
        [shortLexicon addObject:sub];
    }
    [shortLexicon addObject:@""];
    [table reloadData];
    [IWInkworksService getInstance].popController = popController;
    [popController presentPopoverFromRect:self.frame inView:self.superview permittedArrowDirections:UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown animated:YES];
    __weak UIView *popOverView = popController.contentViewController.view;
    CGRect tableFrame = CGRectMake(popOverView.frame.origin.x, popOverView.frame.origin.y, popOverView.frame.size.width, popOverView.frame.size.height - 10);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        table.frame = tableFrame;
    });
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:shortLexicon.count - 1 inSection:0];
    [table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:false];
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [IWDataChangeHandler getInstance].dataChanged = YES;
    selectedValue = [shortLexicon objectAtIndex:indexPath.row];
    [selLabel setText:selectedValue];
    [selText setText:selectedValue];
    [popController dismissPopoverAnimated:YES];
    if ([self.selectedValue isEqualToString: @""]) {
        [[IWInkworksService getInstance].currentRenderer triggerPanelField:descriptor.fdtFieldName value:NO];
    } else {
        [[IWInkworksService getInstance].currentRenderer triggerPanelField:descriptor.fdtFieldName value:YES];
    }
}
- (void) setPrepop {
    selLabel.textColor = [UIColor colorWithRed:40.0/255.0 green:98.0/255.0 blue:142.0/255.0 alpha:255.0/255.0];
    selText.textColor = [UIColor colorWithRed:40.0/255.0 green:98.0/255.0 blue:142.0/255.0 alpha:255.0/255.0];
    [selText setEnabled:NO];
    enabled = NO;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iw_ios7_launch_image_1024x768"]];
    [cell setSelectedBackgroundView:bgView];
    [cell.textLabel setText:[shortLexicon objectAtIndex:indexPath.row]];
    [cell.textLabel setTextColor:[UIColor blackColor]];
    cell.transform = CGAffineTransformMakeScale(1, -1);
    return cell;
    
    
}

- (void) textFieldChanged: (UITextField *) target {
    NSString *newText = selText.text;
    selLabel.text = @"";
    if ([newText isEqualToString:@""]) {
        shortLexicon = [NSMutableArray array];
        for (NSString *sub in lexicon) {
            if ([sub isEqualToString:@""]) continue;
            [shortLexicon addObject:sub];
        }
        
        [shortLexicon addObject:@""];
        [table reloadData];
        
        if (![popController isPopoverVisible]) {
            [self showMenuAuto];
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:shortLexicon.count - 1 inSection:0];
        [table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:false];
        return;
    }
    shortLexicon = [NSMutableArray array];
    for (NSString *sub in lexicon) {
        if ([sub isEqualToString:@""]) {
            continue;
        }
        if ([[sub lowercaseString] rangeOfString:[[newText lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]].location != NSNotFound) {
            [shortLexicon addObject:sub];
        }
    }
    
    [shortLexicon addObject:@""];
    [table reloadData];
    if (![popController isPopoverVisible]) {
        [self showMenuAuto];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:shortLexicon.count - 1 inSection:0];
    [table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:false];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [shortLexicon count];
}

- (NSString *)getVal {
    if ([selectedValue isEqualToString:@""]) {
        return @"";
    }
    
    if ([values objectForKey:selectedValue] == nil) {
        return @"";
    }
    
    return [values objectForKey:selectedValue];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    return true;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [selLabel setText:selectedValue];
    [selText setText:selectedValue];
}

-(BOOL)resignFirstResponder {
    
    [selLabel setText:selectedValue];
    
    return true;
}

@end
