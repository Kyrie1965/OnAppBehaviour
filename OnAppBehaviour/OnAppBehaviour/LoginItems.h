//
//  LoginItems.h
//  OnAppBehaviour
//
//  Created by Yuri Yuriev on 08.04.11.
//  Copyright 2011 Yuri Yuriev. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LoginItems : NSObject
{
    
}


+ (void)addApplication:(NSString *)path;
+ (void)removeApplication:(NSString *)path;
+ (BOOL)findApplication:(NSString *)path;


@end
