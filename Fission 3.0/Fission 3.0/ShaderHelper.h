//
//  ShaderHelper.h
//  Fission 3.0
//
//  Created by Luke Hill on 12/11/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
enum{
    UNIFORM_PROJECTION,
    UNIFORM_PROJECTION_2D_A,
    UNIFORM_PROJECTION_2D_B,
    UNIFORM_PROJECTION_2D_C,
    UNIFORM_TEXTURE0,
    UNIFORM_TEXTURE1,
    UNIFORM_TEXTURE2,
    UNIFORM_TEXTURE3,
    UNIFORM_TEXTURE4,
    UNIFORM_POINT_SIZE,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_BLUR,
    UNIFORM_RENDER_WIDTH1,
    UNIFORM_RENDER_HEIGHT1,
    UNIFORM_RENDER_WIDTH2,
    UNIFORM_RENDER_HEIGHT2,
    NUM_UNIFORMS
};//Uniform Index
enum{
    ATTRIBUTE_POSITION,
    ATTRIBUTE_TEXTURE,
    ATTRIBUTE_TEXTURE2,
    ATTRIBUTE_NORMAL,
    ATTRIBUTE_POSITION_CENTER,
    ATTRIBUTE_POSITION_GRID,
    ATTRIBUTE_TEXTURE_SHORT,
    NUM_ATTRIBUTES
};// Attribute index.
@interface ShaderHelper : NSObject{
@public
    NSString* file_name_vert_shader;
    NSString* file_name_frag_shader;
    NSString* description;
    GLuint *uniforms;
    GLuint *attributes;
    GLuint programIndex;
    bool *useUniform;
    bool *useAttribute;
    NSArray *attributeNames;// = [NSArray arrayWithObjects:@"String1",@"String2",@"String3",nil];
    NSArray *uniformNames;
}
-(ShaderHelper*)initWithVertexFileName:(NSString*)v andFragFileName:(NSString*)f andDescription:(NSString*)desc;
-(bool)load;
-(void)activateAttributes:(GLuint*)a andUniforms:(GLuint*)u;
-(void)setUniform:(GLuint)uniformEnum toValuePointer:(void**)p;
@end