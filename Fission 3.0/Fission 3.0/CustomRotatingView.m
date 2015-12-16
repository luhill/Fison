//
//  CustomRotatingView.m
//  Fission 3.0
//
//  Created by Luke Hill on 8/12/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

#import "CustomRotatingView.h"
#import "SeeThroughView.h"
@interface CustomRotatingView ()

@end

@implementation CustomRotatingView

-(BOOL)shouldAutorotate{
    return YES;
}
//When a window rotates it adds a view with a black frame to mask the edges with black bars. This method hides views that dont belong to the project
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    UIWindow* window = self.view.window;
    for (UIView* view in [window subviews]) {
        [self recursiveViewSearch:view];
    }
}
-(void)recursiveViewSearch:(UIView*)v{
    if ([v isKindOfClass:[SeeThroughView class]]) {
        return;
    }else{
        for (UIView* subview in [v subviews]) {
            [self recursiveViewSearch:subview];
        }
        v.hidden = YES;
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
