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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = NO;
    // Do any additional setup after loading the view.
}
-(BOOL)shouldAutorotate{
    return YES;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //[self orientationChanged:NO];
}
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    UIWindow* window = self.view.window;
    for (UIView* view in [window subviews]) {
        if (!CGRectIntersectsRect(window.bounds, view.frame)) {
            view.hidden = YES;
        }
        for (UIView* view_ in [view subviews]) {
            CGRect frame = [view_ convertRect:view_.frame toView:window];
            if (!CGRectIntersectsRect(window.bounds, frame)) {
                if (![view isKindOfClass:[SeeThroughView class]]) {
                    view_.hidden = YES;
                }
            }
        }
    }
}
/*
-(void)orientationChanged:(BOOL)animated{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    CGRect landscape, portrait, mainScreen, current;
    BOOL orientationChanged;
    orientationChanged = YES;
    mainScreen = [[UIScreen mainScreen] bounds];
    portrait = mainScreen;//default is portrait;
    landscape.size.height = portrait.size.width;
    landscape.size.width = portrait.size.height;
    CGFloat angle = 0.0f;
    
    switch (orientation) {
        case UIDeviceOrientationPortrait:{
            NSLog(@"%@:Portrait Up",viewDescription);
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
            angle = 0.0f;
            current = portrait;
            break;}
        case UIDeviceOrientationPortraitUpsideDown:{
            NSLog(@"%@:Portrait Down",viewDescription);
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortraitUpsideDown animated:NO];
            angle = M_PI;
            current = portrait;
            break;}
        case UIDeviceOrientationLandscapeRight:{
            NSLog(@"%@:Landscape Right",viewDescription);
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:NO];
            angle = -M_PI_2;
            current = landscape;
            break;}
        case UIDeviceOrientationLandscapeLeft:{
            NSLog(@"%@:Landscape Left",viewDescription);
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
            angle = M_PI_2;
            current = landscape;
            break;}
        default:{//flat or other
            NSLog(@"%@:Flat or unknown",viewDescription);
            orientationChanged = NO;
            break;}
    }
 
    if (orientationChanged) {
        if (animated) {
            [UIView animateWithDuration:0.3f animations:^{
                self.view.transform = CGAffineTransformMakeRotation(angle);
                self.view.bounds = current;
                [self.view layoutSubviews];
                [self.view setNeedsUpdateConstraints];
            }];
        }else{
            self.view.transform = CGAffineTransformMakeRotation(angle);
            self.view.bounds = current;
            [self.view layoutSubviews];
            [self.view setNeedsUpdateConstraints];
        }
    }
    //NSLog(@"Origin X:%f, Y:%f, width:%f, height:%f",self.view.bounds.origin.x,self.view.bounds.origin.y,self.view.bounds.size.width, self.view.bounds.size.height);
}
*/
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
