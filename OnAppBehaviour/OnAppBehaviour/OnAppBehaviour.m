//
//  OnAppBehaviour.m
//  OnAppBehaviour
//
//  Created by Yuri Yuriev on 07.04.11.
//  Copyright 2011 Yuri Yuriev. All rights reserved.
//

#import "OnAppBehaviour.h"


@implementation NSImage (PNGExport)


- (NSData *)PNGData
{
    [self lockFocus];
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, [self size].width, [self size].height)];
    [self unlockFocus];
    
    NSData *PNGData = [rep representationUsingType:NSPNGFileType properties:nil];
    [rep release];
    
    return PNGData;
}


@end
        
        
@implementation OnAppBehaviour


#pragma mark -
#pragma mark Init


- (void)mainViewDidLoad
{
    [textFieldInfo setStringValue:NSLocalizedStringFromTableInBundle(@"ChooseApplication", nil, [self bundle], @"")];
    
    [textFieldDidLaunch setStringValue:NSLocalizedStringFromTableInBundle(@"DidLaunch", nil, [self bundle], @"")];
    [textFieldDidTerminate setStringValue:NSLocalizedStringFromTableInBundle(@"DidTerminate", nil, [self bundle], @"")];
    [textFieldDidHide setStringValue:NSLocalizedStringFromTableInBundle(@"DidHide", nil, [self bundle], @"")];
    [textFieldDidUnhide setStringValue:NSLocalizedStringFromTableInBundle(@"DidUnhide", nil, [self bundle], @"")];
    [textFieldDidActivate setStringValue:NSLocalizedStringFromTableInBundle(@"DidActivate", nil, [self bundle], @"")];
    [textFieldDidDeactivate setStringValue:NSLocalizedStringFromTableInBundle(@"DidDeactivate", nil, [self bundle], @"")];
    
    [self helperRun];
    [self loadPreferences];    
    
    NSTableColumn* column = [[appTable tableColumns] objectAtIndex:0];    
	[[column headerCell] setStringValue:NSLocalizedStringFromTableInBundle(@"Applications", nil, [self bundle], @"")];
    [appTable reloadData];

    addButton = [[PopUpButton alloc] initWithFrame:NSMakeRect(20, 19, 23, 22) pullsDown:YES];
    addButton.delegate = self;
    
    NSString *imagePath = [[self bundle] pathForImageResource:@"Add.png"];
    NSImage *buttonImage = [[[NSImage alloc] initWithContentsOfFile:imagePath] autorelease];
    
    [addButton setCell:[[[PopUpCell alloc] initWithimage:buttonImage] autorelease]];
    [addButton setMenu:[self menuForPopUp]];
    [[self mainView] addSubview:addButton];

    imagePath = [[self bundle] pathForImageResource:@"Remove.png"];
    buttonImage = [[[NSImage alloc] initWithContentsOfFile:imagePath] autorelease];
    
	removeButton = [[NSButton alloc] initWithFrame:NSMakeRect(43, 19, 22, 22)];
	[removeButton setButtonType:NSMomentaryChangeButton];
	[removeButton setImage:buttonImage];
	[removeButton setImagePosition:NSImageOnly];
	[removeButton setBordered:NO];
	[removeButton setTarget:self];
	[removeButton setAction:@selector(removeButtonAction:)];
    [[self mainView] addSubview:removeButton];
    
    [self setViewToRow:-1];    
}


#pragma mark -
#pragma mark Unselect and Dealloc


- (void)willUnselect
{
    [self saveCurrentData];
}


- (void)dealloc
{
    if (menu) [menu release];
    if (tableDataSource) [tableDataSource release];
    if (addButton) addButton.delegate = nil, [addButton release];
    if (removeButton) [addButton release];
    
    [super dealloc];
}


#pragma mark -
#pragma mark Helper


- (void)helperNotify
{
    NSString *observedObject = @"info.yuriev.OnAppBehaviourHelper";
    NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
    [center postNotificationName:@"OABReloadScripts" object:observedObject userInfo:nil deliverImmediately:YES];
}


- (void)helperRun
{
    NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications];
    BOOL found = NO;
    
    for (int i = 0; i < [apps count]; i++)
    {
        if ([[apps objectAtIndex:i] bundleIdentifier])
        {
            if ([[[apps objectAtIndex:i] bundleIdentifier] isEqualToString:@"info.yuriev.OnAppBehaviourHelper"])
            {
                found = YES;
                break;
            }
        }
    }

    NSString *helperPath = [[[self bundle] resourcePath] stringByAppendingPathComponent:@"OnAppBehaviourHelper.app"];
    
    if (!found)
    {
        [[NSWorkspace sharedWorkspace] launchApplicationAtURL:[NSURL fileURLWithPath:helperPath] options:NSWorkspaceLaunchDefault configuration:nil error:NULL];        
    }
    
    [LoginItems removeApplication:helperPath];
    [LoginItems addApplication:helperPath];
}


#pragma mark -
#pragma mark Add and Remove Buttons, PopUp Menu


- (void)removeButtonAction:(id)sender
{
    [tableDataSource removeObjectAtIndex:[appTable selectedRow]];
    [appTable deselectAll:self];
    [appTable reloadData];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];    
    [self savePreferences];
    [self setViewToRow:-1];
}


- (NSMenu *)menuForPopUp
{
    if (menu) [menu release];
    menu = [[NSMutableArray alloc] initWithCapacity:100];
    
    NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications];
    
    for (int i = 0; i < [apps count]; i++)
    {
        if (([[apps objectAtIndex:i] localizedName] && [[apps objectAtIndex:i] bundleIdentifier] && [[apps objectAtIndex:i] icon]) &&
            (([[[apps objectAtIndex:i] localizedName] length] > 0) && ([[[apps objectAtIndex:i] bundleIdentifier] length] > 0)))
        {
            NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithCapacity:3];
            [tmpDict setObject:[[apps objectAtIndex:i] localizedName] forKey:@"name"];
            [tmpDict setObject:[[apps objectAtIndex:i] bundleIdentifier] forKey:@"ID"];
            [tmpDict setObject:[[apps objectAtIndex:i] icon] forKey:@"icon"];
            
            [menu addObject:tmpDict];
        }
    }
    
    NSSortDescriptor *desc = [[[NSSortDescriptor alloc]
                               initWithKey:@"name"
                               ascending:YES
                               selector:@selector(caseInsensitiveCompare:)] autorelease];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:desc, nil];
    
    [menu sortUsingDescriptors:sortDescriptors];
    
    NSMenu *newMenu;
    NSMenuItem *newItem;
    
    newMenu = [[NSMenu allocWithZone:[NSMenu menuZone]] initWithTitle:@"menu"];
    newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"root" action:NULL keyEquivalent:@""];
    [newMenu addItem:newItem];
    [newItem release];
    
    if ([menu count] == 0)
    {
        newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"" action:NULL keyEquivalent:@""];
        [newMenu addItem:newItem];
        [newItem release];        
    }
    
    for (int i = 0; i < [menu count]; i++)
    {
        newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:[[menu objectAtIndex:i] objectForKey:@"name"] action:NULL keyEquivalent:@""];
        [newItem setImage:[[menu objectAtIndex:i] objectForKey:@"icon"]];
        newItem.tag = 1000 + i;
        [newItem setTarget:self];
        [newItem setAction:@selector(selectApplicationFromPopUp:)];
        [newMenu addItem:newItem];
        [newItem release];
    }
    
    return [newMenu autorelease];
}


- (void)selectApplicationFromPopUp:(id)sender
{
    NSMenuItem *item = (NSMenuItem *)sender;
    
    NSDictionary *appDict = [menu objectAtIndex:(item.tag - 1000)];
    
    int index = -1;
    
    for (int i = 0; i < [tableDataSource count]; i++)
    {
        if ([[appDict objectForKey:@"ID"] isEqualToString:[[tableDataSource objectAtIndex:i] objectForKey:@"ID"]])
        {
            index = i;
            break;
        }
    }
    
    [self saveCurrentData];
    
    if (index != -1)
    {
        [appTable selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
        [self setViewToRow:index];
        [appTable scrollRowToVisible:index];        
    }
    else
    {
        NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithDictionary:appDict];
        
        [tmpDict setObject:@"" forKey:@"DidLaunch"];
        [tmpDict setObject:@"" forKey:@"DidTerminate"];
        [tmpDict setObject:@"" forKey:@"DidHide"];
        [tmpDict setObject:@"" forKey:@"DidUnhide"];
        [tmpDict setObject:@"" forKey:@"DidActivate"];
        [tmpDict setObject:@"" forKey:@"DidDeactivate"];
        
        [tableDataSource addObject:tmpDict];
        
        NSSortDescriptor *desc = [[[NSSortDescriptor alloc]
                                   initWithKey:@"name"
                                   ascending:YES
                                   selector:@selector(caseInsensitiveCompare:)] autorelease];
        
        NSArray *sortDescriptors = [NSArray arrayWithObjects:desc, nil];
        
        [tableDataSource sortUsingDescriptors:sortDescriptors];
        
        [appTable deselectAll:self];
        [appTable reloadData];
        
        for (int i = 0; i < [tableDataSource count]; i++)
        {
            if ([tableDataSource objectAtIndex:i] == tmpDict)
            {
                [appTable selectRowIndexes:[NSIndexSet indexSetWithIndex:i] byExtendingSelection:NO];
                [self setViewToRow:i];
                [appTable scrollRowToVisible:i];        
                
                break;
            }
        }        
    }
    
    [[[self mainView] window] makeFirstResponder:appTable];    
}


#pragma mark -
#pragma mark Scripts View


- (void)setViewToRow:(NSInteger)row
{
    saved = YES;
    
    if (row != -1)
    {
        [textFieldInfo setHidden:YES];
        
        [textFieldDidLaunch setHidden:NO];
        [textFieldDidTerminate setHidden:NO];
        [textFieldDidHide setHidden:NO];
        [textFieldDidUnhide setHidden:NO];
        [textFieldDidActivate setHidden:NO];
        [textFieldDidDeactivate setHidden:NO];
        
        [[textViewDidLaunch enclosingScrollView] setHidden:NO];
        [[textViewDidTerminate enclosingScrollView] setHidden:NO];
        [[textViewDidHide enclosingScrollView] setHidden:NO];
        [[textViewDidUnhide enclosingScrollView] setHidden:NO];
        [[textViewDidActivate enclosingScrollView] setHidden:NO];
        [[textViewDidDeactivate enclosingScrollView] setHidden:NO]; 
        
        NSDictionary *dict = [tableDataSource objectAtIndex:row];        
        NSRange zeroRange = NSMakeRange(0, 0);
        
        [textViewDidLaunch setString:[dict objectForKey:@"DidLaunch"]];
        [textViewDidLaunch scrollRangeToVisible:zeroRange];
        [textViewDidTerminate setString:[dict objectForKey:@"DidTerminate"]];
        [textViewDidTerminate scrollRangeToVisible:zeroRange];
        [textViewDidHide setString:[dict objectForKey:@"DidHide"]];
        [textViewDidHide scrollRangeToVisible:zeroRange];
        [textViewDidUnhide setString:[dict objectForKey:@"DidUnhide"]];
        [textViewDidUnhide scrollRangeToVisible:zeroRange];
        [textViewDidActivate setString:[dict objectForKey:@"DidActivate"]];
        [textViewDidActivate scrollRangeToVisible:zeroRange];
        [textViewDidDeactivate setString:[dict objectForKey:@"DidDeactivate"]];
        [textViewDidDeactivate scrollRangeToVisible:zeroRange];
        
        [removeButton setEnabled:YES];
    }
    else
    {
        [textFieldInfo setHidden:NO];
        
        [textFieldDidLaunch setHidden:YES];
        [textFieldDidTerminate setHidden:YES];
        [textFieldDidHide setHidden:YES];
        [textFieldDidUnhide setHidden:YES];
        [textFieldDidActivate setHidden:YES];
        [textFieldDidDeactivate setHidden:YES];
        
        [[textViewDidLaunch enclosingScrollView] setHidden:YES];
        [[textViewDidTerminate enclosingScrollView] setHidden:YES];
        [[textViewDidHide enclosingScrollView] setHidden:YES];
        [[textViewDidUnhide enclosingScrollView] setHidden:YES];
        [[textViewDidActivate enclosingScrollView] setHidden:YES];
        [[textViewDidDeactivate enclosingScrollView] setHidden:YES];
        
        [removeButton setEnabled:NO];        
    }
}


#pragma mark -
#pragma mark Save and Load Preferences


- (void)saveCurrentData
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if (saved) return;
    saved = YES;
    
    NSInteger selectedRow = [appTable selectedRow];
    
    if (selectedRow != -1)
    {
        NSDictionary *dict = [tableDataSource objectAtIndex:selectedRow];
        NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        
        [tmpDict setObject:[NSString stringWithString:[[textViewDidLaunch textStorage] string]] forKey:@"DidLaunch"];
        [tmpDict setObject:[NSString stringWithString:[[textViewDidTerminate textStorage] string]] forKey:@"DidTerminate"];
        [tmpDict setObject:[NSString stringWithString:[[textViewDidHide textStorage] string]] forKey:@"DidHide"];
        [tmpDict setObject:[NSString stringWithString:[[textViewDidUnhide textStorage] string]] forKey:@"DidUnhide"];
        [tmpDict setObject:[NSString stringWithString:[[textViewDidActivate textStorage] string]] forKey:@"DidActivate"];
        [tmpDict setObject:[NSString stringWithString:[[textViewDidDeactivate textStorage] string]] forKey:@"DidDeactivate"];
        
        [tableDataSource replaceObjectAtIndex:selectedRow withObject:tmpDict];
        
        [self savePreferences];
    }
}


- (void)savePreferences
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES); 
	NSString *appSupportPath = [paths objectAtIndex:0];
    NSString *prefDir = [appSupportPath stringByAppendingPathComponent:@"info.yuriev.OnAppBehaviour"];
	NSString *prefPath = [prefDir stringByAppendingPathComponent:@"preferences.plist"];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    [fileManager removeItemAtPath:prefDir error:NULL];
    [fileManager createDirectoryAtPath:prefDir withIntermediateDirectories:YES attributes:nil error:NULL];
    
    NSMutableArray *saveArray = [NSMutableArray arrayWithCapacity:[tableDataSource count]];
    
    for (int i = 0; i < [tableDataSource count]; i++)
    {
        NSDictionary *dict = [tableDataSource objectAtIndex:i];
        
        NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithDictionary:dict];        
        NSString *path = [prefDir stringByAppendingPathComponent:[[tmpDict objectForKey:@"ID"] stringByAppendingPathExtension:@"png"]];
        [[[tmpDict objectForKey:@"icon"] PNGData] writeToFile:path atomically:YES];
        [tmpDict removeObjectForKey:@"icon"];
        
        [saveArray addObject:tmpDict];
    }
    
    [saveArray writeToFile:prefPath atomically:YES];
    
    [self helperNotify];
    
    [pool release];
}


- (void)loadPreferences
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES); 
	NSString *appSupportPath = [paths objectAtIndex:0];
    NSString *prefDir = [appSupportPath stringByAppendingPathComponent:@"info.yuriev.OnAppBehaviour"];
	NSString *prefPath = [prefDir stringByAppendingPathComponent:@"preferences.plist"];
    
    NSArray *tmpArray = [NSMutableArray arrayWithContentsOfFile:prefPath];
    if (!tmpArray) tmpArray = [NSArray array];
    
    tableDataSource = [[NSMutableArray alloc] initWithCapacity:100];
    
    for (int i = 0; i < [tmpArray count]; i++)
    {
        NSDictionary *dict = [tmpArray objectAtIndex:i];
        
        NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        NSString *path = [prefDir stringByAppendingPathComponent:[[tmpDict objectForKey:@"ID"] stringByAppendingPathExtension:@"png"]];
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:path];
        
        if (image)
        {
            [tmpDict setObject:image forKey:@"icon"];
            [image release];
            
            [tableDataSource addObject:tmpDict];
        }
    }
}


#pragma mark -
#pragma mark NSTableView Delegates


- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [tableDataSource count];
}


- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 44;
}

- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    AppCell* cell = [[[AppCell alloc] init] autorelease];
    [cell setEditable:NO];
    cell.title = [[tableDataSource objectAtIndex:row] objectForKey:@"name"];
    cell.subtitle = [[tableDataSource objectAtIndex:row] objectForKey:@"ID"];
    cell.image = [[tableDataSource objectAtIndex:row] objectForKey:@"icon"];
    
    return cell;
}


- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    [self setViewToRow:[appTable selectedRow]];
}


- (NSIndexSet *)tableView:(NSTableView *)tableView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes
{
    [self saveCurrentData];
    
    return proposedSelectionIndexes;
}


#pragma mark -
#pragma mark NSTextView Delegates


- (void)textDidChange:(NSNotification *)aNotification
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(saveCurrentData) withObject:nil afterDelay:3.0];
    
    saved = NO;
}


#pragma mark -

@end
