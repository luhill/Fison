//
//  SeeThroughView.m
//  Fission 3.0
//
//  Created by Luke Hill on 11/11/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

#import "SeeThroughView.h"

@implementation SeeThroughView
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    
    for (UIView *view in [self subviews]){
        //Here you can compare each view frame with touch location
        if(CGRectContainsPoint(view.frame, point) && !view.hidden){
            //NSLog(@"Touch is in see through view");
            return YES;
        }
    }
    return NO;
}

@end
