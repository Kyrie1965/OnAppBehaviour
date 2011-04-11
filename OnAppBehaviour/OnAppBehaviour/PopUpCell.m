//
//  PopUpCell.m
//  OnAppBehaviour
//
//  Created by Yuri Yuriev on 08.04.11.
//  Copyright 2011 Yuri Yuriev. All rights reserved.
//

#import "PopUpCell.h"


@implementation PopUpCell


- (id)initWithimage:(NSImage *)image
{
    self = [super initTextCell:@"" pullsDown:YES];
    
    buttonCell = [[NSButtonCell alloc] initImageCell:image];
    [buttonCell setButtonType:NSPushOnPushOffButton];
    [buttonCell setImagePosition:NSImageOnly];
    [buttonCell setImageDimsWhenDisabled:YES];
    [buttonCell setBordered:NO];
    
    return self;
}


- (void)dealloc
{
	[buttonCell release];
	
	[super dealloc];
}


- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[buttonCell drawWithFrame:cellFrame inView:controlView];
}


- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[buttonCell highlight:flag withFrame:cellFrame inView:controlView];
}


@end