//
//  AppCell.h
//  OnAppBehaviour
//
//  Created by Yuri Yuriev on 07.04.11.
//  Copyright 2011 Yuri Yuriev. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppCell : NSTextFieldCell
{
	NSImage *image;
	NSString *title;
	NSString *subtitle;
}


@property (retain) NSImage *image;
@property (retain) NSString *title;
@property (retain) NSString *subtitle;


@end