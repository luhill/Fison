//
//  VC_Texture.h
//  Fission 3.0
//
//  Created by Luke Hill on 12/11/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GL_ViewController.h"

@interface GL_ViewController (GL_Texture){
    
}
-(void)initializeTextures;
-(void)bindTexture:(int)tex_index;
-(void)bindTextureRender:(int)tex_index;
-(void)setColorMap:(NSString*)texName;
-(void)setBackGroundImage:(UIImage*)image;
@end
