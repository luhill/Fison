//
//  AppDelegate.h
//  Fission 3.0
//
//  Created by Luke Hill on 10/11/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalAccess.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
@public
    GlobalAccess *global;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) GlobalAccess *global;

@end

