//
//  OnAppBehaviourHelperAppDelegate.m
//  OnAppBehaviourHelper
//
//  Created by Yuri Yuriev on 11.04.11.
//  Copyright 2011 Yuri Yuriev. All rights reserved.
//

#import "OnAppBehaviourHelperAppDelegate.h"


@implementation OnAppBehaviourHelperAppDelegate



- (void)dealloc
{
    if (preferences) [preferences release];
    
    [super dealloc];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self loadPreferences:nil];
    
    NSNotificationCenter *notificationCenter = [[NSWorkspace sharedWorkspace] notificationCenter];
    
    [notificationCenter addObserver:self selector:@selector(didLaunchApplication:) name:NSWorkspaceDidLaunchApplicationNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(didTerminateApplication:) name:NSWorkspaceDidTerminateApplicationNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(didHideApplication:) name:NSWorkspaceDidHideApplicationNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(didUnhideApplication:) name:NSWorkspaceDidUnhideApplicationNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(didActivateApplication:) name:NSWorkspaceDidActivateApplicationNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(didDeactivateApplication:) name:NSWorkspaceDidDeactivateApplicationNotification object:nil];
    
    NSString *observedObject = @"info.yuriev.OnAppBehaviourHelper";
    NSDistributedNotificationCenter *dNotificationCenter = [NSDistributedNotificationCenter defaultCenter];
    
    [dNotificationCenter addObserver: self selector: @selector(loadPreferences:) name:@"OABReloadScripts" object:observedObject];
}


- (void)loadPreferences:(NSNotification *)notification
{
    if (preferences) [preferences release];
    
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES); 
	NSString *appSupportPath = [paths objectAtIndex:0];
    NSString *prefDir = [appSupportPath stringByAppendingPathComponent:@"info.yuriev.OnAppBehaviour"];
	NSString *prefPath = [prefDir stringByAppendingPathComponent:@"preferences.plist"];
    
    preferences = [NSArray arrayWithContentsOfFile:prefPath];
    if (!preferences) preferences = [NSArray array];
    
    [preferences retain];
}


- (void)preformScriptOnApp:(NSRunningApplication *)app forKey:(NSString *)key
{
    if ((!app) || (![app bundleIdentifier])) return;
    
    NSString *bundleID = [app bundleIdentifier];
    
    for (int i = 0; i < [preferences count]; i++)
    {
        if ([[[preferences objectAtIndex:i] objectForKey:@"ID"] isEqualToString:bundleID])
        {
            NSString *script = [[preferences objectAtIndex:i] objectForKey:key];
            
            if (script && ([script length] > 0))
            {
                NSAppleScript *AScript = [[NSAppleScript alloc] initWithSource:script];
                [AScript executeAndReturnError:NULL];
                [AScript release];
            }
            
            break;
        }
    }
    
}


-(void)didLaunchApplication:(NSNotification *)notification
{
    [self preformScriptOnApp:[[notification userInfo] objectForKey:@"NSWorkspaceApplicationKey"] forKey:@"DidLaunch"];
}


-(void)didTerminateApplication:(NSNotification *)notification
{
    [self preformScriptOnApp:[[notification userInfo] objectForKey:@"NSWorkspaceApplicationKey"] forKey:@"DidTerminate"];    
}


-(void)didHideApplication:(NSNotification *)notification
{
    [self preformScriptOnApp:[[notification userInfo] objectForKey:@"NSWorkspaceApplicationKey"] forKey:@"DidHide"];        
}


-(void)didUnhideApplication:(NSNotification *)notification
{
    [self preformScriptOnApp:[[notification userInfo] objectForKey:@"NSWorkspaceApplicationKey"] forKey:@"DidUnhide"];        
}


-(void)didActivateApplication:(NSNotification *)notification
{
    [self preformScriptOnApp:[[notification userInfo] objectForKey:@"NSWorkspaceApplicationKey"] forKey:@"DidActivate"];        
}


-(void)didDeactivateApplication:(NSNotification *)notification
{
    [self preformScriptOnApp:[[notification userInfo] objectForKey:@"NSWorkspaceApplicationKey"] forKey:@"DidDeactivate"];    
}


@end
