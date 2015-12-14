//
//  ViewController.h
//  Fission 3.0
//
//  Created by Luke Hill on 10/11/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

//#import "ShaderHelper.h"

enum{
    DRAW_MODE_ONE_STAGE,
    DRAW_MODE_TWO_STAGE,//1. Draw scene to texture, 2. Apply wave physics and lighting.
};//Drawing mode
enum{
    RENDER_MODE_DEFAULT,
    RENDER_MODE_TWO_STAGE,
    RENDER_MODE_TWO_STAGE_BLUR,
    RENDER_MODE_PING_PONG
};
enum{
    TEXTURE_BACKGROUND,
    TEXTURE_COLOR,
    TEXTURE_LUT,
    //TEXTURE_OFFSCREEN_TARGET_A,
    //TEXTURE_OFFSCREEN_TARGET_B,
    NUM_TEXTURES
};//Render texture targets. Two offscreen textures allows the ping-pong between renders (if required)
enum{
    TEXTURE_OFFSCREEN_TARGET_0,
    TEXTURE_OFFSCREEN_TARGET_1,
    TEXTURE_OFFSCREEN_TARGET_2,
    NUM_RENDER_TEXTURES
};//Render Textures
enum{
    FRAMEBUFFER_OFFSCREEN_RENDER_0,
    FRAMEBUFFER_OFFSCREEN_RENDER_1,
    FRAMEBUFFER_OFFSCREEN_RENDER_2,
    FRAMEBUFFER_DEFAULT,   //!!Keep this framebuffer as the second to last index. Default framebuffer index is last.
    NUM_FRAMEBUFFERS
};//Frame buffer index
enum{
    RENDERBUFFER_TARGET_0,
    RENDERBUFFER_TARGET_1,
    RENDERBUFFER_TARGET_2,
    NUM_RENDERBUFFERS
};//Renderbuffer index
enum{
    program_texture_shader,
    program_particle,
    program_alpha_shader,
    NUM_SHADER_PROGRAMS
};//Shader Program index

typedef struct _ScreenInfo{
    GLfloat view_width;
    GLfloat view_height;
    GLfloat view_scale_factor;
    GLfloat offscreen_scale_factor;
    GLfloat width_over_height;
    GLfloat render_texture_width;
    GLfloat render_texture_height;
    GLfloat render_texture_x_texcoord;
    GLfloat render_texture_y_texcoord;
    GLfloat updates_per_frame;
    bool even_frame;
}ScreenInfo;
typedef struct _verticesInfo{
    uint fissionPoints;
    uint num_screen_quad_vertices;
    uint num_render_quad_vertices;
    uint num_total_vertices;
    uint offset_fissionPoints;
    uint offset_screen_quad;
    uint offset_render_quad;
}VerticesInfo;
typedef struct _Point2D{
    GLfloat x,y,z;
    GLfloat tx,ty;
    GLfloat tx2,ty2;
    //GLfloat nx,ny,nz;
    //GLubyte r,g,b,a; //No color for now. Use textures
}Point2D;
@interface GLViewController : GLKViewController{
@public
    ScreenInfo screen_info;
    Point2D *vertices;
    VerticesInfo vertices_info;
    struct _Point2D *v;
    NSMutableArray *programs;
    GLuint vertexArray, vertexBuffer, indexBuffer;
    GLKMatrix4 baseOrthogonalProjection;
    GLKMatrix4 offScreenOrthogonalProjection;
    
    GLuint *uniforms;
    GLuint *index_framebuffers;//Num framebuffers describes the amount to create. Extra location is added for the default buffer.
    GLuint *index_renderbuffers;
    GLuint *index_textures;
    GLuint *index_textures_render;
    CVPixelBufferRef renderTarget;
    
    GLuint NUM_OFFSCREEN_FRAMEBUFFERS;
    bool USE_OFFSCREEN_DEPTH_BUFFER;
    bool USE_OFFSCREEN_TEXTURE_CACHE;
}

@end

