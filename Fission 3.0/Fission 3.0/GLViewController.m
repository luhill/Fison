//
//  ViewController.m
//  Fission 3.0
//
//  Created by Luke Hill on 10/11/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

#import "GLViewController.h"
#import "AppDelegate.h"
#import "GlobalAccess.h"
#import "VC_OpenGL.h"
//////////////////////////////////

@interface GLViewController (){}
@property (strong, nonatomic) EAGLContext *context;
@end

@implementation GLViewController
GlobalAccess *data;

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
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    data = appDelegate.global;
    //menuView = appDelegate->menu;
    
    
    [self launchOpenGL];
    
    NSLog(@"Loaded View Controller");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
