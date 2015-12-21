//
//  Fission.h
//  Fission 3.0
//
//  Created by Luke Hill on 12/11/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
@class GL_ViewController;
struct _Point2D;//Forward declaration
typedef struct _Particle{
    struct _Point2D *vPtr0, *vPtr1;
    GLfloat xc,yc;
    GLshort mode;
    GLushort randAngle, randDistance, randTime;
    GLushort t;
    GLushort fragIndex;
    GLushort binomialLayer;
    int leadIndex;
    bool isFirstPassiveInGroup;//Only the first passive particle in a group will be displayed as others in the group will overlap it
}Particle;
typedef struct _touchGhost{
    CGPoint currentPoint;
    CGPoint velocity;
    bool active;
}TouchGhost;
enum{
    MODE_PASSIVE,
    MODE_ACTIVE0,
    MODE_ACTIVE1,
    MODE_ACTIVE2,
    MODE_ACTIVE3,
    MODE_ACTIVE4,
    MODE_ACTIVE5,
    MODE_PACTIVE,
    MODE_PASSIVE_RESPAWN,
    MODE_OFF=-1,
    NUM_MODES
};
@interface Fission : NSObject{
@public
    GL_ViewController* viewPtr;
    struct _Point2D* verts;//Pointer to View controller vertices
    int NUM_POINTS;
    int NUM_PARTICLES;
    int NUM_PARTS;
    float BINOMIAL_LAYERS;
    int NUM_PASSIVE;//current number of passive particles
    int NUM_PASSIVE_GROUPS;//current number of passive clusters
    int NUM_ACTIVE;//current number of active particles
    int currentMode;
    int currentActiveMode;
    int spawnIndex;
    Particle* saps;
    float blur;
    bool setGrid;
    float radius, speed;
    float collisionSize, particleSize;
    TouchGhost* touchGhosts;
    int touchGhostIndex, NUM_TOUCH_GHOSTS;
    bool COLOR_MODE_IMAGE;
    bool RENDER_MODE_SPRITE;
    bool USING_INTRO, COLLAPSING_INTRO;
    float introTimer;
    float introCountDown;
    float collapseDelay;
}
-(Fission*)initWithPoints:(int)numPoints andPointer:(GL_ViewController*)ptr;
-(void)update;
-(void)newMoleculeAtX:(float)x andY:(float)y andMode:(int)mode;
-(void)newParticleAtIndex:(int)i mode:(GLshort)mode x:(float)x y:(float)y fragIndex:(int)fragIndex time:(GLushort)time first:(bool)first;
-(void)setActive:(int)index;
-(void)explodeField:(int)mode;
-(void)updateIntro;
-(void)initializeParticles;
@end
