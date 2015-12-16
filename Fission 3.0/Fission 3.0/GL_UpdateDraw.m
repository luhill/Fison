//
//  VC_UpdateDraw.m
//  Fission 3.0
//
//  Created by Luke Hill on 12/11/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

#import "GL_UpdateDraw.h"
#import "GL_OpenGL.h"
#import "GL_Texture.h"

@implementation GL_ViewController (GL_UpdateDraw)
-(void)update{
    [fission updateIntro];
    [self readPixels];
    [fission update];
    [self pushData];
    [self pushElements];
}
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    if (fission->USING_INTRO) {
        [self setBufferDrawMode:FRAMEBUFFER_DEFAULT];
        glClear(GL_COLOR_BUFFER_BIT);
        //glActiveTexture(GL_TEXTURE0);
        //[self bindTextureRender:TEXTURE_OFFSCREEN_TARGET_1];
        [self useShaderProgram:program_intro_shader];
        glDrawArrays(GL_TRIANGLES, vertices_info.offset_screen_quad, vertices_info.num_screen_quad_vertices);
    }else{
        switch (draw_mode) {
            case DRAW_MODE_REGULAR:{
                [self standardDraw];
                [self displayStandardLines];
                break;}
            case DRAW_MODE_DEBUG:{
                //NSLog(@"Debug Draw");
                [self standardDraw];
                [self displayCollisionMap];
                break;}
            case DRAW_MODE_POINTS:{
                //NSLog(@"Debug Draw");
                [self standardDraw];
                [self displayPoints];
                break;}
            default:{
                break;}
        }
    }
}
-(void)standardDraw{
    [self setBufferDrawMode:FRAMEBUFFER_OFFSCREEN_RENDER_1];
    glEnable(GL_BLEND);
    glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ZERO, GL_ONE_MINUS_SRC_ALPHA);
    [self blur];
    
    if (fission->COLOR_MODE_IMAGE==YES) {
        glDisable(GL_BLEND);
        [self drawParticleLines_image];
        glEnable(GL_BLEND);
    }else{
        glBlendFunc(GL_SRC_ALPHA, GL_ONE);
        if (fission->RENDER_MODE_SPRITE==YES) {
            [self drawActiveSprites];
        }else{
            [self drawParticleLines];
        }
    }
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    [self drawPassiveSprites];
    glColorMask(1.0, 1.0, 0.0, 0.0);
    [self setBufferDrawMode:FRAMEBUFFER_OFFSCREEN_RENDER_2];
    glBlendFunc(GL_ONE, GL_ONE);
    glDisable(GL_BLEND);
    glColorMask(0.0, 1.0, 0.0, 0.0);
    [self drawCollisions_passive];
    glColorMask(1.0, 0.0, 0.0, 0.0);
    [self drawCollisions_active];
    
    glColorMask(1.0, 0.0, 0.0, 0.0);
    [self setBufferDrawMode:FRAMEBUFFER_OFFSCREEN_RENDER_0];
    [self drawMap];
    glColorMask(1.0, 1.0, 1.0, 1.0);
}
-(void)blur{
    [self useShaderProgram:program_blur_shader];
    glDrawArrays(GL_TRIANGLES, vertices_info.offset_screen_quad, vertices_info.num_screen_quad_vertices);
}
-(void)drawParticleLines_image{
    [self useShaderProgram:program_line_image_shader];
    glActiveTexture(GL_TEXTURE0);
    [self bindTexture:TEXTURE_BACKGROUND];
    glLineWidth(fission->particleSize);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexLineBuffer);
    glDrawElements(GL_LINES, fission->NUM_ACTIVE, GL_UNSIGNED_INT, (void*)0);
}
-(void)drawParticleLines{
    [self useShaderProgram:program_particle_shader];
    glActiveTexture(GL_TEXTURE0);
    [self bindTexture:TEXTURE_COLOR];
    glLineWidth(fission->particleSize);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexLineBuffer);
    glDrawElements(GL_LINES, fission->NUM_ACTIVE, GL_UNSIGNED_INT, (void*)0);
}
-(void)drawActiveSprites{
    [self useShaderProgram:program_sprite_basic_shader];
    glActiveTexture(GL_TEXTURE0);
    [self bindTexture:TEXTURE_SPRITE_ACTIVE];
    glActiveTexture(GL_TEXTURE1);
    [self bindTexture:TEXTURE_COLOR];
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexPointBuffer);
    glDrawElements(GL_POINTS, fission->NUM_ACTIVE/2, GL_UNSIGNED_INT, (void*)(fission->NUM_PASSIVE*sizeof(GLuint)));
}
-(void)drawPassiveSprites{
    [self useShaderProgram:program_sprite_shader];
    glActiveTexture(GL_TEXTURE0);
    [self bindTexture:TEXTURE_SPRITE_PASSIVE];
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexPointBuffer);
    glDrawElements(GL_POINTS, fission->NUM_PASSIVE_GROUPS, GL_UNSIGNED_INT, (void*)0);
}
-(void)drawCollisions_passive{
    [self useShaderProgram:program_point_shader];
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexPointBuffer);
    glDrawElements(GL_POINTS, fission->NUM_PASSIVE/*vertices_info.num_point_indices*/, GL_UNSIGNED_INT, (void*)0);
}
-(void)drawCollisions_active{
    [self useShaderProgram:program_line_shader];
    glLineWidth(fission->collisionSize);
    //glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexLineBuffer);
    //draw lines
    //glDrawElements(GL_LINES, fission->NUM_ACTIVE, GL_UNSIGNED_INT, (void*)0);
    //glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexPointBuffer);
    //draw points
    glDrawElements(GL_POINTS, fission->NUM_ACTIVE/2, GL_UNSIGNED_INT, (void*)(fission->NUM_PASSIVE*sizeof(GLuint)));
}
-(void)drawMap{
    [self useShaderProgram:program_collisionMap_shader];
    glActiveTexture(GL_TEXTURE0);
    [self bindTextureRender:TEXTURE_OFFSCREEN_TARGET_2];
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexPointBuffer);
    glDrawElements(GL_POINTS, fission->NUM_PARTICLES, GL_UNSIGNED_INT, (void*)0);
}
-(void)displayStandardLines{
    [self setBufferDrawMode:FRAMEBUFFER_DEFAULT];
    glActiveTexture(GL_TEXTURE0);
    [self bindTextureRender:TEXTURE_OFFSCREEN_TARGET_1];
    //glActiveTexture(GL_TEXTURE1);
    //[self bindTexture:TEXTURE_BACKGROUND];
    [self renderToScreen];
}
-(void)displayCollisionMap{
    [self setBufferDrawMode:FRAMEBUFFER_DEFAULT];
    glActiveTexture(GL_TEXTURE0);
    [self bindTextureRender:TEXTURE_OFFSCREEN_TARGET_0];
    [self renderToScreen];
}
-(void)displayPoints{
    [self setBufferDrawMode:FRAMEBUFFER_DEFAULT];
    glActiveTexture(GL_TEXTURE0);
    [self bindTextureRender:TEXTURE_OFFSCREEN_TARGET_2];
    [self renderToScreen];
}
-(void)renderToScreen{
    [self useShaderProgram:program_texture_shader];
    glDrawArrays(GL_TRIANGLES, vertices_info.offset_screen_quad, vertices_info.num_screen_quad_vertices);
}

@end
