//
//  VC_Texture.m
//  Fission 3.0
//
//  Created by Luke Hill on 12/11/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

#import "GL_Texture.h"

@implementation GL_ViewController (GL_Texture)

-(void)bindTexture:(int)tex_index{
    glBindTexture(GL_TEXTURE_2D, index_textures[tex_index]);
}
-(void)bindTextureRender:(int)tex_index{
    glBindTexture(GL_TEXTURE_2D, index_textures_render[tex_index]);
}
-(void)setBackGroundImage:(UIImage*)image{
    glBindTexture(GL_TEXTURE_2D, index_textures[TEXTURE_BACKGROUND]);
    [self attachImageToBoundedTexture:image orName:nil];
}
-(void)setColorMap:(NSString*)texName{
    glBindTexture(GL_TEXTURE_2D, index_textures[TEXTURE_COLOR]);
    [self attachImageToBoundedTexture:nil orName:texName];
}
- (void)initializeTextures{
    glEnable(GL_TEXTURE_2D);
    glActiveTexture(GL_TEXTURE0);
    glGenTextures(NUM_TEXTURES, index_textures);
    //Background
    glBindTexture(GL_TEXTURE_2D, index_textures[TEXTURE_BACKGROUND]);
    [self setTextureParameters];
    //[self attachImageToBoundedTexture:nil orName:@"background"];
    
    //glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, index_textures[TEXTURE_COLOR]);
    [self setTextureParameters];
    [self attachImageToBoundedTexture:nil orName:@"1"];
    
    //glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, index_textures[TEXTURE_SPRITE_PASSIVE]);
    [self setTextureParameters];
    [self attachImageToBoundedTexture:nil orName:@"spritePassive"];
    
    glBindTexture(GL_TEXTURE_2D, index_textures[TEXTURE_SPRITE_ACTIVE]);
    [self attachImageToBoundedTexture:nil orName:@"spriteActive"];
    [self setTextureParameters];

    glActiveTexture(GL_TEXTURE0);
    glGenTextures(NUM_RENDER_TEXTURES, index_textures_render);
    if (USE_OFFSCREEN_TEXTURE0_CACHE==NO) {
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, index_textures_render[TEXTURE_OFFSCREEN_TARGET_0]);
        [self setTextureParameters];
        [self buildTextureForScreenDimensions:screen_info.render_texture0_width andHeight:screen_info.render_texture0_height highPrecision:NO];
    }
    /*
    if (USE_OFFSCREEN_TEXTURE1_CACHE==NO) {
        //glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, index_textures_render[TEXTURE_OFFSCREEN_TARGET_1]);
        [self setTextureParameters];
        [self buildTextureForScreenDimensions:screen_info.render_texture1_width andHeight:screen_info.render_texture1_height highPrecision:NO];
    }*/
     
    if (USE_OFFSCREEN_TEXTURE2_CACHE==NO) {
        //glActiveTexture(GL_TEXTURE2);
        glBindTexture(GL_TEXTURE_2D, index_textures_render[TEXTURE_OFFSCREEN_TARGET_2]);
        [self setTextureParameters];
        [self buildTextureForScreenDimensions:screen_info.render_texture2_width andHeight:screen_info.render_texture2_height highPrecision:YES];
    }
    glFinish();
}
-(void)setTextureParametersMipMap{
    glGenerateMipmap(GL_TEXTURE_2D);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST_MIPMAP_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST_MIPMAP_LINEAR);
}
-(void)setTextureParametersLinear{
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    //glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);//Cannot use repeat for non power of two textures (size of render buffer is npot)
    //glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
}
-(void)setTextureParameters{
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    //glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);//Cannot use repeat for non power of two textures (size of render buffer is npot)
    //glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
}
-(void)attachImageToBoundedTexture:(UIImage*)image orName:(NSString*)imageName{
    if (image==nil) {
        image = [UIImage imageNamed:imageName];
    }
    if (image == nil)
        NSLog(@"Do real error checking here");
    
    GLuint w = (GLuint)CGImageGetWidth(image.CGImage);
    GLuint h = (GLuint)CGImageGetHeight(image.CGImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc( h * w * 4 );
    CGContextRef cont = CGBitmapContextCreate( imageData, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
    CGColorSpaceRelease( colorSpace );
    CGContextClearRect( cont, CGRectMake( 0, 0, w, h ) );
    CGContextTranslateCTM( cont, 0, h );
    CGContextScaleCTM(cont, 1.0f, -1.0f);
    CGContextDrawImage( cont, CGRectMake( 0, 0, w, h), image.CGImage );
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    glFlush();
    glFinish();
    CGContextRelease(cont);
    
    free(imageData);
}
-(void)buildTextureForScreenDimensions:(GLfloat)w andHeight:(GLfloat)h highPrecision:(bool)highP{
    //Texture dimensions must be a power of two and must be at least as large as the screen.
    //glTexImage2D(<#GLenum target#>, <#GLint level#>, <#GLint internalformat#>, <#GLsizei width#>, <#GLsizei height#>, <#GLint border#>, <#GLenum format#>, <#GLenum type#>, <#const GLvoid *pixels#>);
    if (highP) {
        //glTexImage2D(<#GLenum target#>, <#GLint level#>, <#GLint internalformat#>, <#GLsizei width#>, <#GLsizei height#>, <#GLint border#>, <#GLenum format#>, <#GLenum type#>, <#const GLvoid *pixels#>)
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, w, h, 0, GL_RGB,GL_UNSIGNED_SHORT_5_6_5, NULL);
    }else{
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0, GL_RGBA,GL_UNSIGNED_BYTE, NULL);
    }
}
@end
