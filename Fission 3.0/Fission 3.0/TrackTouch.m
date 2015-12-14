//
//  TrackTouch.m
//  Fission 3.0
//
//  Created by Luke Hill on 30/11/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

#import "TrackTouch.h"

@implementation TrackTouch
-(TrackTouch*)init{
    [self setInitialValues];
    return self;
}
-(void)setInitialValues{
    p0 = CGPointMake(-100.0,-100.0);
    p1 = p0;
    touchTimer = NULL;
}
@end
