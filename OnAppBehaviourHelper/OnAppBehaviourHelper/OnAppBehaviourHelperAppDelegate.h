//
//  OnAppBehaviourHelperAppDelegate.h
//  OnAppBehaviourHelper
//
//  Created by Yuri Yuriev on 11.04.11.
//  Copyright 2011 Yuri Yuriev. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface OnAppBehaviourHelperAppDelegate : NSObject <NSApplicationDelegate>
{
    NSArray *preferences;
}


- (void)loadPreferences:(NSNotification *)notification;
- (void)preformScriptOnApp:(NSRunningApplication *)app forKey:(NSString *)key;


@end
