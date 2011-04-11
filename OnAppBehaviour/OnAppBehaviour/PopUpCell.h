//
//  PopUpCell.h
//  OnAppBehaviour
//
//  Created by Yuri Yuriev on 08.04.11.
//  Copyright 2011 Yuri Yuriev. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PopUpCell : NSPopUpButtonCell
{
    NSButtonCell *buttonCell;
}


- (id)initWithimage:(NSImage *)image;


@end
