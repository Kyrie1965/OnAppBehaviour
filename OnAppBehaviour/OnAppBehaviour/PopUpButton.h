//
//  PopUpButton.h
//  testtv
//
//  Created by Yuri Yuriev on 08.04.11.
//  Copyright 2011 Yuri Yuriev. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol PopUpDelegate <NSObject>
@optional
- (NSMenu *)menuForPopUp;
@end


@interface PopUpButton : NSPopUpButton
{
	id<PopUpDelegate> delegate;    
}


@property (assign) id delegate;


@end
