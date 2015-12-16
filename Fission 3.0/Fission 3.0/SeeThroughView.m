//
//  SeeThroughView.m
//  Fission 3.0
//
//  Created by Luke Hill on 11/11/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

#import "SeeThroughView.h"
#import "AppDelegate.h"
#import "GlobalAccess.h"
@implementation SeeThroughView

-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView* targetView = [super hitTest:point withEvent:event];
    if ([targetView isKindOfClass:[SeeThroughView class]]) {
        if (glView==nil) {
            [self getGlHandle];
        }
        return glView.view;
    }else{
        return targetView;
    }
}
-(void)getGlHandle{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    GlobalAccess *data = appDelegate.global;
    glView = data->glView;
}
@end
