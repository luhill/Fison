//
//  ShaderHelper.m
//  Fission 3.0
//
//  Created by Luke Hill on 12/11/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

#import "ShaderHelper.h"
#include "GL_ViewController.h"
@implementation ShaderHelper
-(ShaderHelper*)initWithVertexFileName:(NSString*)v andFragFileName:(NSString*)f andDescription:(NSString*)desc{
    attributeNames = [NSArray arrayWithObjects:@"position",@"textureCoords",@"textureCoords2",@"normal",@"positionCenter",@"positionGrid",@"shortTextureCoords",nil];
    uniformNames = [NSArray arrayWithObjects:@"projection",@"projection2d_a",@"projection2d_b",@"projection2d_c",@"tex0",@"tex1",@"tex2",@"tex3",@"tex4",@"ptSize",@"normalMatrix",@"blur",@"w1",@"h1",@"w2",@"h2",nil];
    uniforms = (GLuint*)malloc(NUM_UNIFORMS*sizeof(GLuint));
    attributes = (GLuint*)malloc(NUM_ATTRIBUTES*sizeof(GLuint));
    useUniform = (bool*)malloc(NUM_UNIFORMS*sizeof(bool));
    useAttribute = (bool*)malloc(NUM_ATTRIBUTES*sizeof(bool));
    memset(useUniform, 0, NUM_UNIFORMS*sizeof(bool));//initially uses no uniforms or attributes. These must be purposley enabled
    memset(useAttribute, 0, NUM_ATTRIBUTES*sizeof(bool));
    file_name_vert_shader = v;
    file_name_frag_shader = f;
    description = desc;
    return self;
}
-(void)setParameters{
    
}
-(void)setUniform:(GLuint)uniformEnum toValuePointer:(void**)p{
    switch (uniformEnum) {
        case UNIFORM_PROJECTION:{
            //GLKMatrix3 *p2 = p;
            GLKMatrix3 p3 = *(GLKMatrix3 *)&p;
            glUniformMatrix4fv(uniforms[UNIFORM_PROJECTION], 1, 0, p3.m);
            break;}
            
        default:
            break;
    }
}
-(void)activateAttributes:(GLuint*)a andUniforms:(GLuint*)u{
    for (int i = 0; i < sizeof(a)/sizeof(GLuint); i++) {
        useAttribute[a[i]] = YES;
    }
    for (int i = 0; i < sizeof(a)/sizeof(GLuint); i++) {
        useUniform[a[i]] = YES;
    }
}
-(bool)load{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    programIndex = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:file_name_vert_shader ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader: %@",description);
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:file_name_frag_shader ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader: %@", description);
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(programIndex, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(programIndex, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    for (int i = 0; i < NUM_ATTRIBUTES; i++) {
        if (useAttribute[i]) {
            glBindAttribLocation(programIndex, i, [attributeNames[i] UTF8String]);
        }
    }
    
    // Link program.
    if (![self linkProgram:programIndex]) {
        NSLog(@"Failed to link program: %@", description);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (programIndex) {
            glDeleteProgram(programIndex);
            programIndex = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    for (int i = 0; i < NUM_UNIFORMS; i++) {
        if (useUniform[i]) {
            uniforms[i] = glGetUniformLocation(programIndex, [uniformNames[i] UTF8String]);
        }
    }
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(programIndex, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(programIndex, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader: %@", description);
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Compile log for shader:%@ \n%s",description, log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}
- (BOOL)linkProgram:(GLuint)prog{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Link log for program: %@ \n%s",description ,log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}
- (BOOL)validateProgram:(GLuint)prog{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Validate log for program: %@ \n%s",description ,log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}
@end
