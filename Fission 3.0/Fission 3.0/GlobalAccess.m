//
//  GlobalAccess.m
//  Fission 3.0
//
//  Created by Luke Hill on 10/11/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

#import "GlobalAccess.h"

@implementation GlobalAccess

@synthesize glView, menuView, introView, instructionsView;

static GlobalAccess *instance = nil;

+(GlobalAccess *)getInstance{
    @synchronized(self){
        if(instance==nil){
            instance= [GlobalAccess new];
        }
    }
    return instance;
}
//to access this Global class from anywhere use this code:
// GlobalAccess *obj=[GlobalAccess getInstance];
@end
