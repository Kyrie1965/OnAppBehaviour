//
//  AppCell.m
//  OnAppBehaviour
//
//  Created by Yuri Yuriev on 07.04.11.
//  Copyright 2011 Yuri Yuriev. All rights reserved.
//

#import "AppCell.h"


#define IMAGE_INSET 5.0
#define TITLE_HEIGHT 17.0


@implementation AppCell


@synthesize image;
@synthesize title;
@synthesize subtitle;


- (id)init
{
    self = [super init];
    
    image = nil;
    title = nil;
    subtitle = nil;
    
    return self;
}


- (void)dealloc
{
    if (image) [image release];
    if (title) [title release];
    if (subtitle) [subtitle release];
    
    [super dealloc];
}


- (id)copyWithZone:(NSZone *)zone
{
    AppCell *cell = [super copyWithZone:zone];
    
    cell->title = nil;
    cell->subtitle = nil;
    cell->image = nil;
    
    cell.title = self.title;
    cell.subtitle = self.subtitle;
    cell.image = self.image;
    
    return cell;
}


- (NSRect)titleRectForBounds:(NSRect)inBounds
{
    NSRect imageRect = [self imageRectForBounds:inBounds];
	
    NSRect rect = NSInsetRect(inBounds,IMAGE_INSET,IMAGE_INSET);
    rect.origin.x = NSMaxX(imageRect) + IMAGE_INSET;
    rect.size.width = NSMaxX(inBounds) - IMAGE_INSET - NSWidth(imageRect) - IMAGE_INSET;
    rect.size.height = TITLE_HEIGHT;
    
    return rect;
}


- (NSRect)subtitleRectForBounds:(NSRect)inBounds
{
	NSRect rect = [self titleRectForBounds:inBounds];
	rect.origin.y = NSMaxY(rect);
	rect.size.height = NSHeight(inBounds) - IMAGE_INSET - TITLE_HEIGHT - IMAGE_INSET;
    
    return rect;
}


- (NSRect)imageRectForBounds:(NSRect)inBounds
{
    NSRect rect = NSInsetRect(inBounds,IMAGE_INSET,IMAGE_INSET);
    rect.size.width = rect.size.height;
    
    return rect;
}


- (NSRect)imageRectForFrame:(NSRect)inImageFrame imageWidth:(CGFloat)inWidth imageHeight:(CGFloat)inHeight
{
	CGFloat f = 1.0;
	if (inWidth > inImageFrame.size.width || inHeight > inImageFrame.size.height)
	{
		CGFloat fx		 = inImageFrame.size.width / inWidth;
		CGFloat fy		 = inImageFrame.size.height / inHeight;
				f		 = MIN(fx,fy);
	}
	
	CGFloat x0		 = NSMidX(inImageFrame);
	CGFloat y0		 = NSMidY(inImageFrame);
	CGFloat width	 = f * inWidth;
	CGFloat height	 = f * inHeight;
	
	NSRect rect;
	rect.origin.x	 = round(x0 - 0.5*width);
	rect.origin.y	 = round(y0 - 0.5*height);
	rect.size.width  = round(width);
	rect.size.height = round(height);
	
	return rect;
}


- (void)drawInteriorWithFrame:(NSRect)inCellFrame inView:(NSView*)inView
{
	NSRect imageRect = [self imageRectForBounds:inCellFrame];
	NSRect titleRect = [self titleRectForBounds:inCellFrame];
	NSRect subtitleRect = [self subtitleRectForBounds:inCellFrame];
    
	NSMutableParagraphStyle* paragraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
	[paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	
	if (title)
    {
        NSColor *titleColor   = [self isHighlighted] ? [NSColor alternateSelectedControlTextColor] : [NSColor textColor];
        
        NSDictionary *titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys: titleColor, NSForegroundColorAttributeName, [NSFont systemFontOfSize:13], NSFontAttributeName, paragraphStyle, NSParagraphStyleAttributeName, nil];	
        
        [title drawInRect:titleRect withAttributes:titleTextAttributes];
        
    }
	
	if (subtitle)
    {
        NSColor *subtitleColor   = [self isHighlighted] ? [NSColor alternateSelectedControlTextColor] : [NSColor disabledControlTextColor];
        
        NSDictionary *subtitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys: subtitleColor, NSForegroundColorAttributeName, [NSFont systemFontOfSize:10], NSFontAttributeName, paragraphStyle, NSParagraphStyleAttributeName, nil];	
        
        [subtitle drawInRect:subtitleRect withAttributes:subtitleTextAttributes];
        
    }
    
    if (image)
    {
        NSRect rect = [self imageRectForFrame:imageRect imageWidth:[image size].width imageHeight:[image size].height];
        
        [[NSGraphicsContext currentContext] saveGraphicsState];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];	
        
        [image drawInRect:rect
                 fromRect:NSZeroRect
                operation:NSCompositeSourceOver 
                 fraction:1.0f 
           respectFlipped:[inView isFlipped] 
                    hints:nil];    

        
        [[NSGraphicsContext currentContext] restoreGraphicsState];
    }
}



@end
