//
//  GlobalAccess.h
//  Fission 3.0
//
//  Created by Luke Hill on 10/11/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GL_ViewController.h"
#import "MenuViewController.h"
#import "IntroViewController.h"
#import "InstructionsViewController.h"
@interface GlobalAccess : NSObject{
@public
    GL_ViewController *glView;
    MenuViewController *menuView;
    IntroViewController *introView;
    InstructionsViewController *instructionsView;
}
@property(nonatomic,retain)GL_ViewController *glView;
@property(nonatomic,retain)MenuViewController *menuView;
@property(nonatomic,retain)IntroViewController *introView;
@property(nonatomic,retain)InstructionsViewController *instructionsView;
+(GlobalAccess*)getInstance;
@end
