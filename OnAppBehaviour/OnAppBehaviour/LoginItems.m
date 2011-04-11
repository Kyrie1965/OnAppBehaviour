//
//  LoginItems.m
//  OnAppBehaviour
//
//  Created by Yuri Yuriev on 08.04.11.
//  Copyright 2011 Yuri Yuriev. All rights reserved.
//

#import "LoginItems.h"


@implementation LoginItems


+ (void)addApplication:(NSString *)path
{
	LSSharedFileListRef loginItemsRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
	if (loginItemsRef)
    {
		LSSharedFileListItemRef itemRef = LSSharedFileListInsertItemURL(loginItemsRef, kLSSharedFileListItemLast, NULL, NULL, (CFURLRef)[NSURL fileURLWithPath:path], NULL, NULL);
        if (itemRef) CFRelease(itemRef);
        CFRelease(loginItemsRef); 
	}	
}


+ (void)removeApplication:(NSString *)path
{
    CFURLRef appURL = (CFURLRef)[NSURL fileURLWithPath:path];
	LSSharedFileListRef loginItemsRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    if (loginItemsRef)
    {
        UInt32 seedValue;
        NSArray  *loginItems = (NSArray *)LSSharedFileListCopySnapshot(loginItemsRef, &seedValue);
        
        for(id loginItem in loginItems)
        {
            LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)loginItem;
            CFURLRef URL = NULL;
            OSStatus err = LSSharedFileListItemResolve(itemRef, 0, &URL, NULL);
            
            if (err == noErr)
            {
                if (CFEqual(appURL, URL)) LSSharedFileListItemRemove(loginItemsRef,itemRef);
                CFRelease(URL);
            }
        }
        
        [loginItems release];
        CFRelease(loginItemsRef);
    }
}


+ (BOOL)findApplication:(NSString *)path
{   
    CFURLRef appURL = (CFURLRef)[NSURL fileURLWithPath:path];
	LSSharedFileListRef loginItemsRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    if (loginItemsRef)
    {
        BOOL found = NO;
        UInt32 seedValue;
        NSArray  *loginItems = (NSArray *)LSSharedFileListCopySnapshot(loginItemsRef, &seedValue);
        
        for(id loginItem in loginItems)
        {
            LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)loginItem;
            CFURLRef URL = NULL;
            OSStatus err = LSSharedFileListItemResolve(itemRef, 0, &URL, NULL);
            
            if (err == noErr)
            {
                found = CFEqual(appURL, URL);
                CFRelease(URL);
                
                break;
            }
        }
	
        [loginItems release];
        CFRelease(loginItemsRef);
        
        return found;
    }
    
    return NO;
}


@end
