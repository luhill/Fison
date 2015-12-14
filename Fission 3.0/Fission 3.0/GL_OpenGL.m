//
//  VC_OpenGL.m
//  Fission 3.0
//
//  Created by Luke Hill on 12/11/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

#import "GL_OpenGL.h"
#import "GL_Texture.h"
@implementation GL_ViewController (GL_OpenGL)

-(void)launchOpenGL{
    NUM_OFFSCREEN_FRAMEBUFFERS = 3;//If only default, set to 0
    USE_OFFSCREEN_DEPTH_BUFFER0 = NO;//Attach depth buffer to offscreen framebuffer
    USE_OFFSCREEN_DEPTH_BUFFER1 = NO;
    USE_OFFSCREEN_DEPTH_BUFFER2 = NO;
    USE_OFFSCREEN_TEXTURE0_CACHE = YES;//useful if need to frequently access a texture rendered by opengly
    USE_OFFSCREEN_TEXTURE1_CACHE = NO;//useful if need to frequently access a texture rendered by opengly
    USE_OFFSCREEN_TEXTURE2_CACHE = NO;
    uniforms = (GLuint*)malloc(NUM_UNIFORMS*sizeof(GLuint));
    index_framebuffers = (GLuint*)malloc(NUM_OFFSCREEN_FRAMEBUFFERS*sizeof(GLuint));
    index_renderbuffers = (GLuint*)malloc(NUM_RENDERBUFFERS*sizeof(GLuint));
    index_textures_render = (GLuint*)malloc(NUM_RENDER_TEXTURES*sizeof(GLuint));
    index_textures = (GLuint*)malloc(NUM_TEXTURES*sizeof(GLuint));
    
    //determine screen size
    screen_info.view_height = self.view.bounds.size.height;
    screen_info.view_width = self.view.bounds.size.width;
    //self.view.contentScaleFactor = 2.0;//Performance Issues if 2x
    screen_info.view_scale_factor = self.view.contentScaleFactor;
    screen_info.offscreen_scale_factor1 = 1.0f;
    screen_info.offscreen_scale_factor2 = 1.0/4.0f;
    screen_info.width_over_height = screen_info.view_width/screen_info.view_height;
    screen_info.render_texture1_height = /*nextPOT*/(screen_info.view_height*screen_info.view_scale_factor)*screen_info.offscreen_scale_factor1;//some shader operations may require POT textures.
    screen_info.render_texture1_width = /*nextPOT*/(screen_info.view_width*screen_info.view_scale_factor)*screen_info.offscreen_scale_factor1;
    screen_info.render_texture2_height = (screen_info.view_height*screen_info.view_scale_factor)*screen_info.offscreen_scale_factor2;
    screen_info.render_texture2_width =  (screen_info.view_width*screen_info.view_scale_factor)*screen_info.offscreen_scale_factor2;
    screen_info.render_texture_y_texcoord = screen_info.view_height*screen_info.view_scale_factor/(screen_info.render_texture1_height/screen_info.offscreen_scale_factor1);
    screen_info.render_texture_x_texcoord = screen_info.view_width*screen_info.view_scale_factor/(screen_info.render_texture1_width/screen_info.offscreen_scale_factor1);
    screen_info.even_frame = YES;
    screen_info.updates_per_frame = 1.0f;
    
    
    screen_info.render_texture0_height = 256;
    screen_info.render_texture0_width = 256;
    vertices_info.num_point_indices = screen_info.render_texture0_height*screen_info.render_texture0_width;
    vertices_info.num_line_indices = vertices_info.num_point_indices*2;
    
    vertices_info.fissionPoints = vertices_info.num_point_indices*2;
    //screen_info.render_texture0_height = screen_info.render_texture1_height;
    //screen_info.render_texture0_width = screen_info.render_texture1_width;
    
    vertices_info.num_screen_quad_vertices = 6;
    vertices_info.num_render_quad_vertices = 6;
    
    vertices_info.num_total_vertices = vertices_info.fissionPoints+vertices_info.num_screen_quad_vertices+vertices_info.num_render_quad_vertices;
    //Define the offset for locating different quads in the vertex array;
    
    vertices_info.offset_fissionPoints = 0;
    vertices_info.offset_screen_quad = vertices_info.offset_fissionPoints+vertices_info.fissionPoints;
    vertices_info.offset_render_quad = vertices_info.offset_screen_quad+vertices_info.num_screen_quad_vertices;
    
    
    draw_mode = DRAW_MODE_REGULAR;
    reset = NO;
    ptSize = 1.0;
    [self allocateVertices];//Reserve memory for all of the points.
    
    
    [self initializeTextures];//must be called before framebuffers
    [self initializeFrameBuffers];//Create the framebuffers
    
    [self setupGL];
    
    [self buildScreenQuad];
    [self buildRenderQuad];
    
    
    fission = [[Fission alloc] initWithPoints:vertices_info.fissionPoints andPointer:self];
}
-(void)allocateVertices{
    vertices = malloc(sizeof(Point2D)*vertices_info.num_total_vertices);
    memset(vertices, 0, sizeof(Point2D)*vertices_info.num_total_vertices);
    point_indices = malloc(sizeof(GLuint)*vertices_info.num_point_indices);
    line_indices = malloc(sizeof(GLuint)*vertices_info.num_line_indices);
    programs = [[NSMutableArray alloc] initWithCapacity:NUM_SHADER_PROGRAMS];
}
-(void)setBufferDrawMode:(int)buffer_index{
    switch (buffer_index) {
        case FRAMEBUFFER_DEFAULT:{
            glClearColor(0.0, 0.0, 0.0, 1.0);
            [(GLKView *)self.view bindDrawable]; //Bind drawable appears to set framebuffer and viewport
            //glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT); //glClear is only necessary if not drawing to the entire framebuffer each frame. In this app a quad is drawn over the screen each frame so there is no need to clear it.
            break;}
        case FRAMEBUFFER_OFFSCREEN_RENDER_0:{//collision framebuffer
            glBindFramebuffer(GL_FRAMEBUFFER, index_framebuffers[FRAMEBUFFER_OFFSCREEN_RENDER_0]);
            glViewport(0, 0, screen_info.render_texture0_width, screen_info.render_texture0_height);
            //Each pixel in this framebuffer represents a particle in fission. Relevant particles are rendered each frame with no blending so a glClear is not required.
            break;}
        case FRAMEBUFFER_OFFSCREEN_RENDER_1:{//offscreen render target for display
            glBindFramebuffer(GL_FRAMEBUFFER, index_framebuffers[FRAMEBUFFER_OFFSCREEN_RENDER_1]);
            //glViewport(0, 0, screen_info.render_texture1_width, screen_info.render_texture1_height);
            //glClearDepthf(0.0);
            //glClear(GL_DEPTH_BUFFER_BIT);
            //This framebuffer uses additive blending for leaving motion trails. glClear would have undesired results
            break;}
        case FRAMEBUFFER_OFFSCREEN_RENDER_2:{//collision render target
            glBindFramebuffer(GL_FRAMEBUFFER, index_framebuffers[FRAMEBUFFER_OFFSCREEN_RENDER_2]);
            glViewport(0, 0, screen_info.render_texture2_width, screen_info.render_texture2_height);
            //This framebuffer stores a low resolution drawing of all the particles but as points instead of lines. It is used to detect collisions and has blending enabled to show when particles overlap. glClear must be used each frame so that only current particle positions are examined.
            glClearColor(0.0, 0.0, 0.0, 0.0);
            glClear(GL_COLOR_BUFFER_BIT);
            break;}
        default:
            break;
    }
}
-(void)useShaderProgram:(int)program{
    
    ShaderHelper* pro = programs[program];
    GLuint index =pro->programIndex;
    glUseProgram(index);
    
    switch (program) {
        case program_intro_shader:{
            glUniform1f(pro->uniforms[UNIFORM_BLUR], fission->introTimer);
            glUniform1f(pro->uniforms[UNIFORM_POINT_SIZE], fission->introCountDown);
            glUniform2f(pro->uniforms[UNIFORM_PROJECTION_2D_A], projection_screen.x, projection_screen.y);
            break;}
        case program_texture_shader:{
            glUniform1i(pro->uniforms[UNIFORM_TEXTURE0], 0);
            glUniform2f(pro->uniforms[UNIFORM_PROJECTION_2D_A], projection_screen.x, projection_screen.y);
            break;}
        case program_particle_shader:{
            glUniform1i(pro->uniforms[UNIFORM_TEXTURE0],0);
            glUniform2f(pro->uniforms[UNIFORM_PROJECTION_2D_A], projection_screen.x, projection_screen.y);
            break;}
        case program_blur_shader:{
            glUniform1f(pro->uniforms[UNIFORM_BLUR], 1.0-fission->blur);
            glUniformMatrix4fv(pro->uniforms[UNIFORM_PROJECTION], 1, 0, baseOrthogonalProjection.m);
            glUniform2f(pro->uniforms[UNIFORM_PROJECTION_2D_A], projection_screen.x, projection_screen.y);
            break;}
        case program_collisionMap_shader:{
            glUniform1i(pro->uniforms[UNIFORM_TEXTURE0],0);
            glUniform2f(pro->uniforms[UNIFORM_PROJECTION_2D_A], projection_screen.x, projection_screen.y);
            glUniform2f(pro->uniforms[UNIFORM_PROJECTION_2D_B], projection_offScreen2.x, projection_offScreen2.y);
            glUniform2f(pro->uniforms[UNIFORM_PROJECTION_2D_C], projection_offScreen0.x, projection_offScreen0.y);
            break;}
        case program_point_shader:{
            glUniform2f(pro->uniforms[UNIFORM_PROJECTION_2D_A], projection_screen.x, projection_screen.y);
            glUniform2f(pro->uniforms[UNIFORM_PROJECTION_2D_B], projection_offScreen2.x, projection_offScreen2.y);
            glUniform1f(pro->uniforms[UNIFORM_POINT_SIZE], fission->collisionSize);
            break;}
        case program_line_shader:{
            glUniform2f(pro->uniforms[UNIFORM_PROJECTION_2D_A], projection_screen.x, projection_screen.y);
            glUniform2f(pro->uniforms[UNIFORM_PROJECTION_2D_B], projection_offScreen2.x, projection_offScreen2.y);
            glUniform1f(pro->uniforms[UNIFORM_POINT_SIZE], fission->collisionSize);
            break;}
        case program_sprite_shader:{
            glUniform1i(pro->uniforms[UNIFORM_TEXTURE0],0);
            glUniform2f(pro->uniforms[UNIFORM_PROJECTION_2D_A], projection_screen.x, projection_screen.y);
            glUniform1f(pro->uniforms[UNIFORM_POINT_SIZE], fission->particleSize);
            break;}
        case program_sprite_basic_shader:{
            glUniform1i(pro->uniforms[UNIFORM_TEXTURE0],0);
            glUniform1i(pro->uniforms[UNIFORM_TEXTURE1],1);
            glUniform2f(pro->uniforms[UNIFORM_PROJECTION_2D_A], projection_screen.x, projection_screen.y);
            glUniform1f(pro->uniforms[UNIFORM_POINT_SIZE], fission->particleSize);
            break;}
        case program_line_image_shader:{
            glUniform1i(pro->uniforms[UNIFORM_TEXTURE0], 0);
            glUniform2f(pro->uniforms[UNIFORM_PROJECTION_2D_A], projection_screen.x, projection_screen.y);
            break;}
        default:
            break;
    }
}
-(void)setupGL{
    [self setGLStates];
    [self loadShaders];
    [self setupProjectionMatrix];
    
    glGenVertexArraysOES(1, &vertexArray);
    glBindVertexArrayOES(vertexArray);//If more than one ArrayOES it must be binded before each draw call
    //Generate a buffer for the vertex data
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Point2D)*vertices_info.num_total_vertices, vertices, GL_DYNAMIC_DRAW);
    //Many of the vertices are used more than once (triangle strips above and below). The index buffer holds a list of the vertex indices to draw and repeat. Using an index buffer improves performance.
    
    glGenBuffers(1, &indexPointBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexPointBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLuint)*vertices_info.num_point_indices, point_indices, GL_DYNAMIC_DRAW);
    glGenBuffers(1, &indexLineBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexLineBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLuint)*vertices_info.num_line_indices, line_indices, GL_DYNAMIC_DRAW);
    
    //The vertices can have many attributes. In this case we will only use position (x/y coordinates), texture coordinates, and normal.
    glEnableVertexAttribArray(ATTRIBUTE_POSITION);
    glVertexAttribPointer(ATTRIBUTE_POSITION, 2, GL_FLOAT, GL_FALSE, sizeof(Point2D), (void*)offsetof(Point2D, x));
    
    glEnableVertexAttribArray(ATTRIBUTE_TEXTURE_SHORT);
    glVertexAttribPointer(ATTRIBUTE_TEXTURE_SHORT, 2, GL_UNSIGNED_SHORT, GL_FALSE, sizeof(Point2D), (void*)offsetof(Point2D, t));
    
    glEnableVertexAttribArray(ATTRIBUTE_POSITION_GRID);
    glVertexAttribPointer(ATTRIBUTE_POSITION_GRID, 2, GL_SHORT, GL_FALSE, sizeof(Point2D), (void*)offsetof(Point2D, xi));
    
    glBindVertexArrayOES(0);
    glBindVertexArrayOES(vertexArray);
    
}
-(void)setGLStates{
    glDisable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);//Blend function of GL_ONE,GL_ONE_MINUS_SRC_ALPHA does not work properly with blur.
    glLineWidth(1.0f);
    glDisable(GL_DEPTH_TEST);
    //glDepthFunc(GL_GEQUAL);
    //glDepthMask(GL_TRUE);
}
-(void)setupProjectionMatrix{
    float left, right, top, bottom, near, far;
    left = 0.0f;//-screen_info.view_width/2.0f;
    right = screen_info.view_width;
    bottom = 0.0f;//-screen_info.view_height/2.0f;
    top = screen_info.view_height;
    near = -20.0f;
    far = 20.0f;
    
    baseOrthogonalProjection = GLKMatrix4MakeOrtho(left, right, bottom, top, near, far);
    
    right /= screen_info.offscreen_scale_factor1;
    top /= screen_info.offscreen_scale_factor1;
    offScreenOrthogonalProjection1 = GLKMatrix4MakeOrtho(left, right, bottom, top, near, far);
    right = screen_info.render_texture0_width;
    top = screen_info.render_texture0_height;
    offScreenOrthogonalProjection0 = GLKMatrix4MakeOrtho(left, right, bottom, top, near, far);
    right = screen_info.render_texture2_width;
    top = screen_info.render_texture2_height;
    offScreenOrthogonalProjection2 = GLKMatrix4MakeOrtho(left, right, bottom, top, near, far);
    projection_screen = GLKVector2Make(screen_info.view_width, screen_info.view_height);
    projection_offScreen0 = GLKVector2Make(screen_info.render_texture0_width, screen_info.render_texture0_height);
    projection_offScreen1 = GLKVector2Make(screen_info.render_texture1_width, screen_info.render_texture1_height);
    projection_offScreen2 = GLKVector2Make(screen_info.render_texture2_width, screen_info.render_texture2_height);
}

-(void)buildScreenQuad{
    int i = vertices_info.offset_screen_quad;
    float l = 0.0f;
    float r = screen_info.view_width;
    float t = screen_info.view_height;
    float b = 0.0f;
    float tx = 1.0;//screen_info.render_texture_x_texcoord;
    float ty = 1.0;//screen_info.render_texture_y_texcoord;
    //float tx2 = tx*scale;
    //float ty2 = ty*scale;
    /*bottom left */ v = &vertices[i+0]; v->x = l;  v->y = b;   v->t = 0.0f; v->a = 0.0f;  //v->tx2 = 0.0f;  v->ty2 = 0.0f;
    /*bottom Right*/ v = &vertices[i+1]; v->x = r;  v->y = b;   v->t = tx;   v->a = 0.0f;  //v->tx2 = tx2;  v->ty2 = ty2;
    /*top left    */ v = &vertices[i+2]; v->x = l;  v->y = t;   v->t = 0.0f; v->a = ty;    //v->tx2 = 0.0f; v->ty2 = ty;
    /*top left    */ v = &vertices[i+3]; v->x = l;  v->y = t;   v->t = 0.0f; v->a = ty;    //v->tx2 = 0.0f; v->ty2 = ty;
    /*bottom right*/ v = &vertices[i+4]; v->x = r;  v->y = b;   v->t = tx;   v->a = 0.0f;  //v->tx2 = tx;   v->ty2 = 0.0f;
    /*top right   */ v = &vertices[i+5]; v->x = r;  v->y = t;   v->t = tx;   v->a = ty;    //v->tx2 = tx;   v->ty2 = ty;
    [self pushData];
}
-(void)buildRenderQuad{
    int i = vertices_info.offset_render_quad;
    float l = 0.0f;
    float r = screen_info.render_texture1_width/screen_info.view_scale_factor;
    float t = screen_info.render_texture1_height/screen_info.view_scale_factor;
    float b = 0.0f;
    float tx = 1.0;//screen_info.render_texture_x_texcoord;
    float ty = 1.0f;//screen_info.render_texture_y_texcoord;
    /*bottom left */ v = &vertices[i+0]; v->x = l;  v->y = b;   v->t = 0.0f; v->a = 0.0f;
    /*bottom Right*/ v = &vertices[i+1]; v->x = r;  v->y = b;   v->t = tx;   v->a = 0.0f;
    /*top left    */ v = &vertices[i+2]; v->x = l;  v->y = t;   v->t = 0.0f; v->a = ty;
    /*top left    */ v = &vertices[i+3]; v->x = l;  v->y = t;   v->t = 0.0f; v->a = ty;
    /*bottom right*/ v = &vertices[i+4]; v->x = r;  v->y = b;   v->t = tx;   v->a = 0.0f;
    /*top right   */ v = &vertices[i+5]; v->x = r;  v->y = t;   v->t = tx;   v->a = ty;
    [self pushData];
}
-(void)pushData{
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferSubData(GL_ARRAY_BUFFER, 0, vertices_info.num_total_vertices*sizeof(Point2D), vertices);
}
-(void)pushElements{
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexPointBuffer);
    glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, 0, vertices_info.num_point_indices*sizeof(GLuint), point_indices);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexLineBuffer);
    glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, 0, vertices_info.num_line_indices*sizeof(GLuint), line_indices);
}
-(void)loadShaders{
    //Order of shaders made here must match program enum order
    ShaderHelper *tempShader = [[ShaderHelper alloc] initWithVertexFileName:@"shader_intro" andFragFileName:@"shader_intro" andDescription:@"Intro shader"];
    [programs addObject:tempShader];
    tempShader->useUniform[UNIFORM_PROJECTION_2D_A]=YES;
    tempShader->useUniform[UNIFORM_BLUR]=YES;
    tempShader->useUniform[UNIFORM_POINT_SIZE]=YES;
    tempShader->useAttribute[ATTRIBUTE_POSITION] = YES;
    [tempShader load];
    
    tempShader = [[ShaderHelper alloc] initWithVertexFileName:@"shader_texture" andFragFileName:@"shader_texture" andDescription:@"Texture_shader_no_lighting"];
    [programs addObject:tempShader];
    tempShader->useUniform[UNIFORM_PROJECTION_2D_A]=YES;
    tempShader->useUniform[UNIFORM_TEXTURE0]=YES;
    tempShader->useUniform[UNIFORM_TEXTURE1]=YES;
    tempShader->useAttribute[ATTRIBUTE_POSITION] = YES;
    tempShader->useAttribute[ATTRIBUTE_TEXTURE_SHORT] = YES;
    [tempShader load];
    
    tempShader = [[ShaderHelper alloc] initWithVertexFileName:@"shader_particle" andFragFileName:@"shader_particle" andDescription:@"Particle_shader"];
    [programs addObject:tempShader];
    tempShader->useUniform[UNIFORM_PROJECTION_2D_A]=YES;
    tempShader->useUniform[UNIFORM_TEXTURE0]=YES;
    tempShader->useAttribute[ATTRIBUTE_POSITION] = YES;
    tempShader->useAttribute[ATTRIBUTE_TEXTURE_SHORT] = YES;
    [tempShader load];
    
    
    tempShader = [[ShaderHelper alloc] initWithVertexFileName:@"shader_blur" andFragFileName:@"shader_blur" andDescription:@"Blur_shader"];
    [programs addObject:tempShader];
    tempShader->useUniform[UNIFORM_PROJECTION_2D_A]=YES;
    tempShader->useAttribute[ATTRIBUTE_POSITION] = YES;
    tempShader->useUniform[UNIFORM_BLUR]=YES;
    [tempShader load];
    
    tempShader = [[ShaderHelper alloc] initWithVertexFileName:@"shader_collision" andFragFileName:@"shader_collision" andDescription:@"Collision_shader"];
    [programs addObject:tempShader];
    tempShader->useUniform[UNIFORM_PROJECTION_2D_A]=YES;
    tempShader->useUniform[UNIFORM_PROJECTION_2D_B]=YES;
    tempShader->useUniform[UNIFORM_PROJECTION_2D_C]=YES;
    tempShader->useUniform[UNIFORM_TEXTURE0]=YES;
    tempShader->useAttribute[ATTRIBUTE_POSITION_GRID] = YES;
    tempShader->useAttribute[ATTRIBUTE_POSITION] = YES;
    [tempShader load];
    
    tempShader = [[ShaderHelper alloc] initWithVertexFileName:@"shader_point" andFragFileName:@"shader_point" andDescription:@"Point_shader"];
    [programs addObject:tempShader];
    tempShader->useUniform[UNIFORM_PROJECTION_2D_A]=YES;
    tempShader->useUniform[UNIFORM_PROJECTION_2D_B]=YES;
    tempShader->useUniform[UNIFORM_POINT_SIZE]=YES;
    tempShader->useAttribute[ATTRIBUTE_POSITION] = YES;
    [tempShader load];
    
    tempShader = [[ShaderHelper alloc] initWithVertexFileName:@"shader_line" andFragFileName:@"shader_line" andDescription:@"Line_shader"];
    [programs addObject:tempShader];
    tempShader->useUniform[UNIFORM_PROJECTION_2D_A]=YES;
    tempShader->useUniform[UNIFORM_PROJECTION_2D_B]=YES;
    tempShader->useUniform[UNIFORM_POINT_SIZE]=YES;
    tempShader->useAttribute[ATTRIBUTE_POSITION] = YES;
    [tempShader load];
    
    tempShader = [[ShaderHelper alloc] initWithVertexFileName:@"shader_sprite" andFragFileName:@"shader_sprite" andDescription:@"Sprite_shader"];
    [programs addObject:tempShader];
    tempShader->useUniform[UNIFORM_TEXTURE0]=YES;
    tempShader->useUniform[UNIFORM_PROJECTION_2D_A]=YES;
    tempShader->useUniform[UNIFORM_POINT_SIZE]=YES;
    tempShader->useAttribute[ATTRIBUTE_POSITION] = YES;
    tempShader->useAttribute[ATTRIBUTE_TEXTURE_SHORT] = YES;
    [tempShader load];
    
    tempShader = [[ShaderHelper alloc] initWithVertexFileName:@"shader_sprite_basic" andFragFileName:@"shader_sprite_basic" andDescription:@"Sprite_shader_basic"];
    [programs addObject:tempShader];
    tempShader->useUniform[UNIFORM_TEXTURE0]=YES;
    tempShader->useUniform[UNIFORM_TEXTURE1]=YES;
    tempShader->useUniform[UNIFORM_PROJECTION_2D_A]=YES;
    tempShader->useUniform[UNIFORM_POINT_SIZE]=YES;
    tempShader->useAttribute[ATTRIBUTE_POSITION] = YES;
    tempShader->useAttribute[ATTRIBUTE_TEXTURE_SHORT] = YES;
    [tempShader load];
    
    tempShader = [[ShaderHelper alloc] initWithVertexFileName:@"shader_line_image" andFragFileName:@"shader_line_image" andDescription:@"Line_Image_Shader"];
    [programs addObject:tempShader];
    tempShader->useUniform[UNIFORM_PROJECTION_2D_A]=YES;
    tempShader->useUniform[UNIFORM_TEXTURE0]=YES;
    tempShader->useAttribute[ATTRIBUTE_POSITION] = YES;
    [tempShader load];
}
-(void)clearFramebuffers{
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glBindFramebuffer(GL_FRAMEBUFFER, index_framebuffers[FRAMEBUFFER_OFFSCREEN_RENDER_0]);
    glClear(GL_COLOR_BUFFER_BIT);
    glBindFramebuffer(GL_FRAMEBUFFER, index_framebuffers[FRAMEBUFFER_OFFSCREEN_RENDER_1]);
    glClear(GL_COLOR_BUFFER_BIT);
    glClearDepthf(0.0);
    glClear(GL_DEPTH_BUFFER_BIT);
    glBindFramebuffer(GL_FRAMEBUFFER, index_framebuffers[FRAMEBUFFER_OFFSCREEN_RENDER_2]);
    glClear(GL_COLOR_BUFFER_BIT);
    NSLog(@"Clearing Buff");
}
- (void)initializeFrameBuffers{
   
    if (NUM_OFFSCREEN_FRAMEBUFFERS==0) {//Only Default Framebuffer
    }
    if (NUM_OFFSCREEN_FRAMEBUFFERS>0) {//Single Offscreen Buffer
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, index_textures[TEXTURE_BACKGROUND]);//unbind target textures for the
        glGenFramebuffers(NUM_OFFSCREEN_FRAMEBUFFERS, index_framebuffers);
        
        glBindFramebuffer(GL_FRAMEBUFFER, index_framebuffers[FRAMEBUFFER_OFFSCREEN_RENDER_0]);
        
        if (USE_OFFSCREEN_TEXTURE0_CACHE) {
            [self TextureCache];
        }else{
            glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D, index_textures_render[TEXTURE_OFFSCREEN_TARGET_0], 0);
        }
        if (USE_OFFSCREEN_DEPTH_BUFFER0) {
            glGenRenderbuffers(1, index_renderbuffers);
            glBindRenderbuffer(GL_RENDERBUFFER, index_renderbuffers[RENDERBUFFER_TARGET_0]);
            glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, screen_info.render_texture0_width, screen_info.render_texture0_height);
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, index_renderbuffers[RENDERBUFFER_TARGET_0]);
            glDepthFunc(GL_LEQUAL);
            glEnable(GL_DEPTH_TEST);
         }
        //glClearColor(0.0, 0.0, 0.0, 0.0);
        //glBindFramebuffer(GL_FRAMEBUFFER, index_framebuffers[FRAMEBUFFER_OFFSCREEN_RENDER_0]);
        //glClear(GL_COLOR_BUFFER_BIT);
         GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER) ;
         if(status != GL_FRAMEBUFFER_COMPLETE) {
             NSLog(@"Failed to make complete framebuffer object: First offscreen Buffer %x", status);
         }
        glBindTexture(GL_TEXTURE_2D, index_textures_render[TEXTURE_OFFSCREEN_TARGET_0]);//unbind target textures for the
     }
    if (NUM_OFFSCREEN_FRAMEBUFFERS>1) {//Dual Offscreen Buffer
        glBindFramebuffer(GL_FRAMEBUFFER, index_framebuffers[FRAMEBUFFER_OFFSCREEN_RENDER_1]);
        
        glBindRenderbuffer(GL_RENDERBUFFER, index_renderbuffers[RENDERBUFFER_TARGET_1]);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA, screen_info.render_texture1_width, screen_info.render_texture1_height);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, index_renderbuffers[RENDERBUFFER_TARGET_1]);
        
        //Attach the texture target. When drawing to framebuffer, results will be rendered to this texture
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D, index_textures_render[TEXTURE_OFFSCREEN_TARGET_1], 0);
        
        if (USE_OFFSCREEN_DEPTH_BUFFER1) {
            glGenRenderbuffers(2, index_renderbuffers);
            glBindRenderbuffer(GL_RENDERBUFFER, index_renderbuffers[RENDERBUFFER_TARGET_1]);
            glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, screen_info.render_texture1_width, screen_info.render_texture1_height);
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, index_renderbuffers[RENDERBUFFER_TARGET_1]);
            //glDepthFunc(GL_LEQUAL);
            glEnable(GL_DEPTH_TEST);
        }
        GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER) ;
        if(status != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"Failed to make complete framebuffer object: Second offscreen Buffer %x", status);
        }
    }
    if (NUM_OFFSCREEN_FRAMEBUFFERS>2) {//Triple Offscreen Buffer
        glBindFramebuffer(GL_FRAMEBUFFER, index_framebuffers[FRAMEBUFFER_OFFSCREEN_RENDER_2]);
        
        glBindRenderbuffer(GL_RENDERBUFFER, index_renderbuffers[RENDERBUFFER_TARGET_2]);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_RGB, screen_info.render_texture2_width, screen_info.render_texture2_height);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, index_renderbuffers[RENDERBUFFER_TARGET_2]);
        
        //Attach the texture target. When drawing to framebuffer, results will be rendered to this texture
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D, index_textures_render[TEXTURE_OFFSCREEN_TARGET_2], 0);
        
        if (USE_OFFSCREEN_DEPTH_BUFFER2) {
            glBindRenderbuffer(GL_RENDERBUFFER, index_renderbuffers[RENDERBUFFER_TARGET_2]);
            glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, screen_info.render_texture2_width, screen_info.render_texture2_height);
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, index_renderbuffers[RENDERBUFFER_TARGET_2]);
        }
        GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER) ;
        if(status != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"Failed to make complete framebuffer object: Second offscreen Buffer %x", status);
        }
    }
    if (NUM_OFFSCREEN_FRAMEBUFFERS>3) {
        NSLog(@"A maximum of 3 offscreen render buffers is currently supported. More coding required!");
    }
    
}
-(void)TextureCache{
    GLKView *view = (GLKView *)self.view;
    CVOpenGLESTextureCacheRef textureCache;
    //CVOpenGLESTextureCacheCreate(<#CFAllocatorRef allocator#>, <#CFDictionaryRef cacheAttributes#>, <#CVEAGLContext eaglContext#>, <#CFDictionaryRef textureAttributes#>, <#CVOpenGLESTextureCacheRef *cacheOut#>)
    CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, view.context, NULL, &textureCache);
    
    CFDictionaryRef empty; // empty value for attr value.
    CFMutableDictionaryRef attrs;
    empty = CFDictionaryCreate(kCFAllocatorDefault, // our empty IOSurface properties dictionary
                               NULL,
                               NULL,
                               0,
                               &kCFTypeDictionaryKeyCallBacks,
                               &kCFTypeDictionaryValueCallBacks);
    attrs = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                      1,
                                      &kCFTypeDictionaryKeyCallBacks,
                                      &kCFTypeDictionaryValueCallBacks);
    
    CFDictionarySetValue(attrs,
                         kCVPixelBufferIOSurfacePropertiesKey,
                         empty);
    
    // for simplicity, lets just say the image is 640x480
    CVPixelBufferCreate(kCFAllocatorDefault, screen_info.render_texture0_width, screen_info.render_texture0_height,
                        /*kCVPixelFormatType_32BGRA*/kCVPixelFormatType_32BGRA,
                        attrs,
                        &renderTarget);
    // in real life check the error return value of course.
    
    // first create a texture from our renderTarget
    // textureCache will be what you previously made with CVOpenGLESTextureCacheCreate
    CVOpenGLESTextureRef renderTexture;
    //CVOpenGLESTextureCacheCreateTextureFromImage(<#CFAllocatorRef allocator#>, <#CVOpenGLESTextureCacheRef textureCache#>, <#CVImageBufferRef sourceImage#>, <#CFDictionaryRef textureAttributes#>, <#GLenum target#>, <#GLint internalFormat#>, <#GLsizei width#>, <#GLsizei height#>, <#GLenum format#>, <#GLenum type#>, <#size_t planeIndex#>, <#CVOpenGLESTextureRef *textureOut#>)
    CVOpenGLESTextureCacheCreateTextureFromImage (kCFAllocatorDefault,
                                                  textureCache,
                                                  renderTarget,
                                                  NULL, // texture attributes
                                                  GL_TEXTURE_2D,
                                                  /*GL_RGBA*/GL_RGBA, // opengl format
                                                  screen_info.render_texture0_width,
                                                  screen_info.render_texture0_height,
                                                  /*GL_BGRA*/GL_BGRA, // native iOS format
                                                  GL_UNSIGNED_BYTE,
                                                  0,
                                                  &renderTexture);
    
    // check err value
    
    // set the texture up like any other texture
    index_textures_render[TEXTURE_OFFSCREEN_TARGET_0] = CVOpenGLESTextureGetName(renderTexture);
    glBindTexture(CVOpenGLESTextureGetTarget(renderTexture),
                  CVOpenGLESTextureGetName(renderTexture));
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
    // bind the texture to the framebuffer you're going to render to
    // (boilerplate code to make a framebuffer not shown)
    glBindFramebuffer(GL_FRAMEBUFFER, index_framebuffers[FRAMEBUFFER_OFFSCREEN_RENDER_0]);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                           GL_TEXTURE_2D, index_textures_render[TEXTURE_OFFSCREEN_TARGET_0], 0);
    
    // great, now you're ready to render to your image.
}
-(void)readPixels{
    if (kCVReturnSuccess == CVPixelBufferLockBaseAddress(renderTarget, kCVPixelBufferLock_ReadOnly)) {
        uint8_t* pixels=(uint8_t*)CVPixelBufferGetBaseAddress(renderTarget);
        // process pixels how you like!
        //size_t bytesPerRow = CVPixelBufferGetBytesPerRow(renderTarget);
        //NSLog(@"Bytes per row:%zu",bytesPerRow);
        //bgra
        int n = 0;
        for (int i = 2; i < fission->NUM_PARTICLES*4; i+=4) {
        //for (int i = 2; i < vertices_info.num_point_indices*4+3; i+=4) {
            //average+=pixels[i];
            //if (pixels[i]>0&&pixels[i-1]>0) {
            if (pixels[i]>128) {
                [fission setActive:n];
                //fission->saps[(i-3)/8].mode = MODE_ACTIVE0;
            }
            n++;
        }
       
        //int x = 384;
        //int y = 512;
        //int b = pixels[(x*4)+(y*bytesPerRow)];
        //int g = pixels[((x*4)+(y*bytesPerRow))+1];
        //int r = pixels[((x*4)+(y*bytesPerRow))+2];
        //NSLog(@"R:%i, G:%i, B:%i",r,g,b);
        //CVPixelBufferUnlockBaseAddress(<#CVPixelBufferRef pixelBuffer#>, <#CVOptionFlags unlockFlags#>)
        CVPixelBufferUnlockBaseAddress(renderTarget, kCVPixelBufferLock_ReadOnly);
    }
}
@end
