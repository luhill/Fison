//
//  GL_ViewController.m
//  Fission 3.0
//
//  Created by Luke Hill on 12/11/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//



#import "GL_ViewController.h"
#import "GL_OpenGL.h"

//#import "AppDelegate.h"
//#import "GlobalAccess.h"
//////////////////////////////////

@interface GL_ViewController (){}
@property (strong, nonatomic) EAGLContext *context;
@end

@implementation GL_ViewController
//GlobalAccess *data;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    self.preferredFramesPerSecond = 60;
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormatNone;
    //view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGB565;
    [EAGLContext setCurrentContext:self.context];//-----!!!!This must be performed early on or you will end up smashing your head into the computer!!!!!//
    
    //AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    //data = appDelegate.global;
    //menuView = appDelegate->menu;
    
    [self launchOpenGL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)shouldAutorotate{
    return NO;
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    NSLog(@"Rotating");
}

@end