//
//  OnAppBehaviour.h
//  OnAppBehaviour
//
//  Created by Yuri Yuriev on 07.04.11.
//  Copyright 2011 Yuri Yuriev. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>
#import "AppCell.h"
#import "PopUpCell.h"
#import "PopUpButton.h"
#import "LoginItems.h"

@interface OnAppBehaviour : NSPreferencePane
{
    IBOutlet NSTableView *appTable;

    IBOutlet NSTextField *textFieldInfo;
    
    IBOutlet NSTextField *textFieldDidLaunch;
    IBOutlet NSTextField *textFieldDidTerminate;
    IBOutlet NSTextField *textFieldDidHide;
    IBOutlet NSTextField *textFieldDidUnhide;
    IBOutlet NSTextField *textFieldDidActivate;
    IBOutlet NSTextField *textFieldDidDeactivate;
    
    IBOutlet NSTextView *textViewDidLaunch;
    IBOutlet NSTextView *textViewDidTerminate;
    IBOutlet NSTextView *textViewDidHide;
    IBOutlet NSTextView *textViewDidUnhide;
    IBOutlet NSTextView *textViewDidActivate;
    IBOutlet NSTextView *textViewDidDeactivate;
    
    PopUpButton *addButton;
    NSButton *removeButton;
    
    NSMutableArray *menu;
    NSMutableArray *tableDataSource;
    
    BOOL saved;
}


- (void)mainViewDidLoad;
- (NSMenu *)menuForPopUp;
- (void)savePreferences;
- (void)loadPreferences;
- (void)helperNotify;
- (void)helperRun;
- (void)setViewToRow:(NSInteger)row;
- (void)saveCurrentData;

@end
