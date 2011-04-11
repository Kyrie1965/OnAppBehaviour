//
//  PopUpButton.m
//  testtv
//
//  Created by Yuri Yuriev on 08.04.11.
//  Copyright 2011 Yuri Yuriev. All rights reserved.
//

#import "PopUpButton.h"


@implementation PopUpButton


@synthesize delegate;


- (void)mouseDown:(NSEvent *)event
{
    if([delegate respondsToSelector:@selector(menuForPopUp)])
    {
        [self setMenu:[delegate menuForPopUp]];
    }
    
    [super mouseDown:event];
}


@end
