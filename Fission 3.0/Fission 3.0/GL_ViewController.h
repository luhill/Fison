//
//  GL_ViewController.h
//  Fission 3.0
//
//  Created by Luke Hill on 12/11/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

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

#import "ShaderHelper.h"
#import "Fission.h"
#import "Fission_Interface.h"
#define M_PIx2 6.2831853072
enum{
    DRAW_MODE_REGULAR,
    DRAW_MODE_DEBUG,
    DRAW_MODE_POINTS//1. Draw scene to texture, 2. Apply wave physics and lighting.
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
    TEXTURE_SPRITE_PASSIVE,
    TEXTURE_SPRITE_ACTIVE,
    //TEXTURE_OFFSCREEN_TARGET_A,
    //TEXTURE_OFFSCREEN_TARGET_B,
    NUM_TEXTURES
};//Render texture targets. Two offscreen textures allows the ping-pong between renders (if required)
enum{
    TEXTURE_OFFSCREEN_TARGET_0,
    //TEXTURE_OFFSCREEN_TARGET_1,
    TEXTURE_OFFSCREEN_TARGET_2,
    NUM_RENDER_TEXTURES
};//Render Textures
enum{
    FRAMEBUFFER_OFFSCREEN_RENDER_0,
    //FRAMEBUFFER_OFFSCREEN_RENDER_1,
    FRAMEBUFFER_OFFSCREEN_RENDER_2,
    FRAMEBUFFER_DEFAULT,   //!!Keep this framebuffer as the second to last index. Default framebuffer index is last.
    NUM_FRAMEBUFFERS
};//Frame buffer index
enum{
    RENDERBUFFER_TARGET_0,
    //RENDERBUFFER_TARGET_1,
    RENDERBUFFER_TARGET_2,
    NUM_RENDERBUFFERS
};//Renderbuffer index
enum{
    program_intro_shader,
    program_intro_shader_landscape,
    program_texture_shader,
    program_particle_shader,
    program_blur_shader,
    program_collisionMap_shader,
    program_point_shader,
    program_line_shader,
    program_sprite_shader,
    program_sprite_basic_shader,
    program_line_image_shader,
    NUM_SHADER_PROGRAMS
};//Shader Program index

typedef struct _ScreenInfo{
    GLfloat view_width;
    GLfloat view_height;
    GLfloat view_scale_factor;
    GLfloat offscreen_scale_factor0;
    GLfloat offscreen_scale_factor1;
    GLfloat offscreen_scale_factor2;
    GLfloat width_over_height;
    GLfloat render_texture0_width;
    GLfloat render_texture0_height;
    GLfloat render_texture1_width;
    GLfloat render_texture1_height;
    GLfloat render_texture2_width;
    GLfloat render_texture2_height;
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
    uint num_point_indices;
    uint num_line_indices;
}VerticesInfo;
typedef struct _Point2D{
    GLfloat x,y;//position
    GLushort t, a;//time, alfa
    GLshort xi,yi;//x index, y index
}Point2D;

@interface GL_ViewController : GLKViewController{
@public
    bool isLandscape;
    ScreenInfo screen_info;
    Point2D *vertices;
    GLuint *point_indices;
    GLuint *line_indices;
    VerticesInfo vertices_info;
    struct _Point2D *v;
    NSMutableArray *programs;
    GLuint vertexArray, vertexBuffer, indexPointBuffer, indexLineBuffer;
    GLKMatrix4 baseOrthogonalProjection;
    GLKMatrix4 offScreenOrthogonalProjection0;
    GLKMatrix4 offScreenOrthogonalProjection1;
    GLKMatrix4 offScreenOrthogonalProjection2;
    GLKVector2 projection_screen;
    GLKVector2 projection_offScreen0;
    GLKVector2 projection_offScreen1;
    GLKVector2 projection_offScreen2;
    
    GLuint *uniforms;
    GLuint *index_framebuffers;//Num framebuffers describes the amount to create. Extra location is added for the default buffer.
    GLuint *index_renderbuffers;
    GLuint *index_textures;
    GLuint *index_textures_render;
    CVPixelBufferRef renderTarget;
    
    GLuint NUM_OFFSCREEN_FRAMEBUFFERS;
    bool USE_OFFSCREEN_DEPTH_BUFFER0;
    bool USE_OFFSCREEN_DEPTH_BUFFER2;
    bool USE_OFFSCREEN_TEXTURE0_CACHE;
    bool USE_OFFSCREEN_TEXTURE2_CACHE;
    int draw_mode;
    
    Fission* fission;
    bool reset;
    float ptSize;
    CFMutableDictionaryRef touchDictionary;
}

@end

