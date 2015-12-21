//
//  VC_OpenGL.h
//  Fission 3.0
//
//  Created by Luke Hill on 12/11/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GL_ViewController.h"
@interface GL_ViewController (GL_OpenGL){
    
}
-(void)launchOpenGL;
-(void)pushData:(int)count;
-(void)pushElements_point:(int)count;
-(void)pushElements_line:(int)count;
-(void)setBufferDrawMode:(int)buffer_index;
-(void)useShaderProgram:(int)program;
-(void)readPixels;
-(void)readPixelsSimulator;
-(void)clearFramebuffers;
@end
