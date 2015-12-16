//
//  Fission.m
//  Fission 3.0
//
//  Created by Luke Hill on 12/11/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

#import "Fission.h"
#import "GL_ViewController.h"
#import "GL_OpenGL.h"
#import "Fission_Interface.h"
@implementation Fission
-(Fission*)initWithPoints:(int)numPoints andPointer:(GL_ViewController*)ptr{
    viewPtr = ptr;
    verts = viewPtr->vertices;
    NUM_POINTS = numPoints;
    NUM_PARTICLES = NUM_POINTS/2;
    NUM_PARTS = 32;
    NUM_TOUCH_GHOSTS = 10;
    touchGhostIndex = 0;
    BINOMIAL_LAYERS=ceilf(log2f((float)NUM_PARTS));
    currentMode = MODE_ACTIVE0;
    currentActiveMode = MODE_ACTIVE0;
    COLOR_MODE_IMAGE = NO;
    spawnIndex = NUM_PARTICLES-1;
    setGrid = NO;
    USING_INTRO = YES;
    COLLAPSING_INTRO = NO;
    introTimer = 0.0;
    introCountDown = 1.0;
    [self launchFission];
    return self;
}
-(void)updateIntro{
    if (USING_INTRO) {
        introTimer+=0.004;
        if (introTimer>2.0*M_PIx2) {
            NSLog(@"Reset Intro Timer");
            introTimer=M_PIx2;
        }
        if (COLLAPSING_INTRO) {
            introCountDown-=(2.0-introCountDown)*0.005;
            if (introCountDown<0.0) {
                USING_INTRO = NO;
                COLLAPSING_INTRO = NO;
                introTimer =0.0;
                introCountDown = 1.0;
                //[self buildIntroGrid:MODE_PACTIVE];
                [self explodeField:MODE_PACTIVE];
                [self showToolBar];
            }
        }
    }
}
-(void)updateTouchGhosts{
    for (int i = 0; i < NUM_TOUCH_GHOSTS; i++) {
        if (touchGhosts[i].active) {
            [self newMoleculeAtX:touchGhosts[i].currentPoint.x andY:touchGhosts[i].currentPoint.y andMode:currentActiveMode];
            touchGhosts[i].currentPoint.x+=touchGhosts[i].velocity.x;
            touchGhosts[i].currentPoint.y+=touchGhosts[i].velocity.y;
            if (touchGhosts[i].currentPoint.x > viewPtr->screen_info.view_width) {
                touchGhosts[i].velocity.x*=-1.0;
                touchGhosts[i].currentPoint.x = viewPtr->screen_info.view_width;
            }
            if (touchGhosts[i].currentPoint.x < 0.0) {
                touchGhosts[i].velocity.x*=-1.0;
                touchGhosts[i].currentPoint.x = 0.0;
            }
            if (touchGhosts[i].currentPoint.y > viewPtr->screen_info.view_height) {
                touchGhosts[i].velocity.y*=-1.0;
                touchGhosts[i].currentPoint.y = viewPtr->screen_info.view_height;
            }
            if (touchGhosts[i].currentPoint.y < 0.0) {
                touchGhosts[i].velocity.y*=-1.0;
                touchGhosts[i].currentPoint.y = 0.0;
            }
            touchGhosts[i].velocity.x*=0.97;
            touchGhosts[i].velocity.y*=0.97;
            if (fabs(touchGhosts[i].velocity.x) < 0.5 || fabs(touchGhosts[i].velocity.y) < 0.5) {
                touchGhosts[i].active = NO;
            }
        }
    }
}
-(void)update{
    [self updateTouchGhosts];
    float distance,time,randAngle,randDistance, randTime;
    NUM_PASSIVE_GROUPS = 0;
    NUM_PASSIVE=0;
    int vi = viewPtr->vertices_info.offset_fissionPoints;
    for (int i = 0; i < NUM_PARTICLES; i++) {
        time = saps[i].vPtr1->t/60000.0;
        randAngle = saps[i].randAngle/60000.0*M_PIx2;
        randDistance = saps[i].randDistance/60000.0;
        randTime = saps[i].randTime/60000.0+0.5;
        switch (saps[i].mode) {
            case MODE_PASSIVE:{
                NUM_PASSIVE++;
                if (saps[i].isFirstPassiveInGroup) {
                    viewPtr->point_indices[NUM_PASSIVE_GROUPS]=vi+1;//saps[i].vPtr1_index;
                    NUM_PASSIVE_GROUPS++;
                }
                saps[i].vPtr1->t++;
                saps[i].vPtr1->t%=60;
                break;}
            case MODE_PACTIVE:{//Passive with no collision
                NUM_PASSIVE++;
                if (saps[i].isFirstPassiveInGroup) {
                    viewPtr->point_indices[NUM_PASSIVE_GROUPS]=vi+1;//saps[i].vPtr1_index;
                    NUM_PASSIVE_GROUPS++;
                }
                saps[i].vPtr1->t++;
                saps[i].vPtr1->t%=60;
                time = saps[i].t/60000.0;
                //NSLog(@"Binomial Layer:%i",saps[i].binomialLayer);
                randAngle = saps[saps[i].leadIndex].randAngle/60000.0*M_PIx2;
                randDistance = saps[saps[i].leadIndex].randDistance/60000.0;
                randTime = saps[saps[i].leadIndex].randTime/60000.0+0.5;
                float cosA = cosf(randAngle);
                float sinA = sinf(randAngle);
                float w = MIN(fabs(viewPtr->screen_info.view_width/2.0/(cosA==0.0?0.01f:cosA)), fabs(viewPtr->screen_info.view_height/2.0/(sinA==0.0?0.01f:sinA)));
                distance = time*randDistance;
                saps[i].vPtr1->x = w*distance*cosA+saps[i].xc;
                saps[i].vPtr1->y = w*distance*sinA+saps[i].yc;
                saps[i].t+=speed*randTime*(1.01-powf(time,2));
                if (saps[i].t>=60000) {
                    //[self spawnNewPassiveAtPactive:i];
                    saps[i].mode = MODE_PASSIVE;
                    saps[i].xc = saps[i].vPtr1->x;
                    saps[i].yc = saps[i].vPtr1->y;
                    saps[i].vPtr0->x = saps[i].vPtr1->x;
                    saps[i].vPtr0->y = saps[i].vPtr1->y;
                }
                break;}
            case MODE_ACTIVE0:{//Implode
                saps[i].vPtr0->x = saps[i].vPtr1->x;
                saps[i].vPtr0->y = saps[i].vPtr1->y;
                
                distance = sin(time*M_PI)*radius/5.0*randDistance;
                saps[i].vPtr1->x = distance*cosf(randAngle+time*M_PIx2)+saps[i].xc;
                saps[i].vPtr1->y = distance*sinf(randAngle+time*M_PIx2)+saps[i].yc;
                saps[i].vPtr1->t+=speed*0.5;
                if (saps[i].vPtr1->t>=60000) {
                    saps[i].vPtr1->t =0;
                    saps[i].mode = MODE_ACTIVE1;
                }
                break;}
            case MODE_ACTIVE1:{//Normal
                saps[i].vPtr0->x = saps[i].vPtr1->x;
                saps[i].vPtr0->y = saps[i].vPtr1->y;
                
                distance = time*radius*randDistance;
                saps[i].vPtr1->x = distance*cosf(randAngle)+saps[i].xc;
                saps[i].vPtr1->y = distance*sinf(randAngle)+saps[i].yc;
                
                saps[i].vPtr1->t+=speed*randTime*(1.01-time*time);
                break;}
            case MODE_ACTIVE2:{//Implode Lines
                saps[i].vPtr0->x = saps[i].vPtr1->x;
                saps[i].vPtr0->y = saps[i].vPtr1->y;
                
                distance = sin(time*M_PI)*radius/5.0;
                saps[i].vPtr1->x = distance*cosf(randAngle+M_PI)+saps[i].xc;
                saps[i].vPtr1->y = distance*sinf(randAngle+M_PI)+saps[i].yc;
                saps[i].vPtr1->t+=speed*0.5;
                if (saps[i].vPtr1->t>=60000) {
                    saps[i].vPtr1->t =0;
                    saps[i].mode = MODE_ACTIVE1;
                }
                break;}
            case MODE_ACTIVE3:{//Spiral
                saps[i].vPtr0->x = saps[i].vPtr1->x;
                saps[i].vPtr0->y = saps[i].vPtr1->y;
                
                distance = time*time*radius*randDistance;
                saps[i].vPtr1->x = distance*cosf(randAngle+time*M_PIx2)+saps[i].xc;
                saps[i].vPtr1->y = distance*sinf(randAngle+time*M_PIx2)+saps[i].yc;
                saps[i].vPtr1->t+=speed*randTime*0.5*(1.01-time);
                break;}
            case MODE_ACTIVE4:{//DNA
                saps[i].vPtr0->x = saps[i].vPtr1->x;
                saps[i].vPtr0->y = saps[i].vPtr1->y;
                float x,y;
                x = radius*time;
                y = radius/20.0*sinf(x/radius*10.0*(1.5));
                saps[i].vPtr1->x = x*cosf(randAngle)-y*sinf(randAngle)+saps[i].xc;
                saps[i].vPtr1->y = y*cosf(randAngle)+x*sinf(randAngle)+saps[i].yc;
                saps[i].vPtr1->t+=speed*randTime*(1.01-time);
                break;}
            case MODE_ACTIVE5:{//Binomial
                saps[i].vPtr0->x = saps[i].vPtr1->x;
                saps[i].vPtr0->y = saps[i].vPtr1->y;
                
                float ta = time-(saps[i].binomialLayer-1.0)/BINOMIAL_LAYERS;
                distance = ta*radius;//*saps[i].rand2;
                saps[i].vPtr1->x = distance*cosf(randAngle)+saps[i].xc;
                saps[i].vPtr1->y = distance*sinf(randAngle)+saps[i].yc;
                saps[i].vPtr1->t+=speed*(1.01-time/*saps[i].binomialLayer*/);
                
                if (time>saps[i].binomialLayer/BINOMIAL_LAYERS){
                    saps[i].binomialLayer++;
                    if (saps[i].binomialLayer>BINOMIAL_LAYERS) {
                        saps[i].mode=MODE_OFF;
                    }else{
                        saps[i].xc = saps[i].vPtr1->x;
                        saps[i].yc = saps[i].vPtr1->y;
                        int modNum = (int)(powf(2.0, BINOMIAL_LAYERS)/powf(2.0, saps[i].binomialLayer-1.0));
                        int minusNum = (int)(powf(2.0,BINOMIAL_LAYERS)/powf(2.0, saps[i].binomialLayer));
                        int leftOrRight = saps[i].fragIndex%modNum-minusNum;
                        if (leftOrRight<0) {
                            saps[i].randAngle-=M_PI/3.0*(1.0-saps[i].binomialLayer/(BINOMIAL_LAYERS+1))*60000.0/M_PIx2;
                        }else{
                            saps[i].randAngle+=M_PI/3.0*(1.0-saps[i].binomialLayer/(BINOMIAL_LAYERS+1))*60000.0/M_PIx2;
                        }
                    }
                }
                break;}
            case MODE_OFF:{
                saps[i].vPtr0->x = -2000.0;
                saps[i].vPtr0->y = -2000.0;
                saps[i].vPtr1->x = -2000.0;
                saps[i].vPtr1->y = -2000.0;
                break;}
            default:
                break;
        }
        if (saps[i].vPtr1->t>=60000) {
            saps[i].mode = MODE_OFF;
            saps[i].vPtr1->t = 60000;
        }
        saps[i].vPtr0->t=saps[i].vPtr1->t;
        vi+=2;
    }
    [self copyFissionToDisplayVerts];
}
-(void)copyFissionToDisplayVerts{
    int vi=viewPtr->vertices_info.offset_fissionPoints;
    int passiveIndex = NUM_PASSIVE_GROUPS;
    int passiveIndex_reverse = NUM_PASSIVE;
    NUM_ACTIVE = 0;
    for (int i = 0; i < NUM_PARTICLES; i++) {
        if (saps[i].mode==MODE_PASSIVE) {
            //The first passive point in a cluster has already been added to the element array.
            if (!saps[i].isFirstPassiveInGroup) {
                viewPtr->point_indices[passiveIndex]=vi+1;//saps[i].vPtr0_index;//Index is the leading point of the line
                passiveIndex++;
            }
        }else if(saps[i].mode==MODE_PACTIVE){
            if (!saps[i].isFirstPassiveInGroup) {
                viewPtr->point_indices[passiveIndex]=vi+1;//saps[i].vPtr0_index;//Index is the leading point of the line
                passiveIndex++;
            }
        }else if(saps[i].mode!=MODE_OFF){
            viewPtr->line_indices[NUM_ACTIVE]=vi;//saps[i].vPtr0_index;
            viewPtr->line_indices[NUM_ACTIVE+1]=vi+1;//saps[i].vPtr1_index;
            NUM_ACTIVE+=2;
            //Add active points to the end of the array for cases when all points need to be drawn;
            viewPtr->point_indices[passiveIndex_reverse]=vi+1;//saps[i].vPtr1_index;
            passiveIndex_reverse++;
        }
        vi+=2;
    }
}
-(void)launchFission{
    saps = malloc(sizeof(Particle)*(NUM_PARTICLES));
    touchGhosts = malloc(sizeof(TouchGhost)*10);
    [self setIndices];
    [self connectParticlesToVertices];
    [self initializeTouchGhosts];
    [self initializeParticles];
    [self setCollisionMapIndex];
}
-(void)connectParticlesToVertices{
    int vi = viewPtr->vertices_info.offset_fissionPoints;
    for (int i = 0; i < NUM_PARTICLES; i++) {
        saps[i].vPtr0 = &verts[vi];
        saps[i].vPtr1 = &verts[vi+1];
        vi+=2;
    }
}
-(void)setIndices{
    for (int i = 0; i < viewPtr->vertices_info.num_point_indices; i++) {
        viewPtr->point_indices[i]=i*2+1+viewPtr->vertices_info.offset_fissionPoints;
    }
    [viewPtr pushElements];
}
//Each particle is assigned an addition possition for collision mapping. A shader will use the index to position the particle into a grid based on index. This will allow data from the read pixels function to be mapped back to a particle with appropriate index.
-(void)setCollisionMapIndex{
    int vertIndex=0+viewPtr->vertices_info.offset_fissionPoints;
    int rows = viewPtr->screen_info.render_texture0_height;
    int cols = viewPtr->screen_info.render_texture0_width;
    for (unsigned short r = 0; r < rows; r++) {
        for (unsigned short c = 0; c < cols; c++) {
            verts[vertIndex].xi = c*2-cols+1;
            verts[vertIndex].yi = r*2-rows+1;
            verts[vertIndex+1].xi = c*2-cols+1;
            verts[vertIndex+1].yi = r*2-rows+1;
            vertIndex+=2;
        }
    }
}
-(void)setActive:(int)index{
    if (saps[index].mode==MODE_PASSIVE) {
        //NSLog(@"set active:%i",index);
        saps[index].mode=currentActiveMode;
        saps[index].vPtr1->t = 0.0;
        saps[index].isFirstPassiveInGroup=NO;
    }else if(saps[index].mode==MODE_PACTIVE){
        
    }else{
        if (saps[index].vPtr1->t>2000) {
            saps[index].mode = MODE_OFF;
        }
    }
    //optional functionality could be to turn active particles off
}
-(float)randomNumberBetween:(float)min maxNumber:(float)max{
    return min + arc4random_uniform(max - min + 1);
}
-(void)newMoleculeAtX:(float)x andY:(float)y andMode:(int)mode{
    unsigned short commonRand = [self randomNumberBetween:0.0 maxNumber:30000];
    int firstIndex = spawnIndex;
    for (int i = 0; i < NUM_PARTS; i++) {
        switch (mode) {
            case MODE_PASSIVE:{
                [self newParticleAtIndex:spawnIndex mode:mode x:x y:y fragIndex:i time:[self randomNumberBetween:0 maxNumber:59] first:i==0];
                break;}
            case MODE_PACTIVE:{
                [self newParticleAtIndex:spawnIndex mode:mode x:x y:y fragIndex:i time:[self randomNumberBetween:0 maxNumber:59] first:i==0];
                saps[spawnIndex].leadIndex = firstIndex;
                break;}
            case MODE_ACTIVE5:{
                [self newParticleAtIndex:spawnIndex mode:mode x:x y:y fragIndex:i time:0 first:i==0];
                if (i < NUM_PARTS/2) {
                    saps[spawnIndex].randAngle=commonRand;
                }else{
                    saps[spawnIndex].randAngle=commonRand+30000;
                }
                break;}
            default:{
                [self newParticleAtIndex:spawnIndex mode:mode x:x y:y fragIndex:i time:0 first:i==0];
                break;}
        }
        spawnIndex--;
        if (spawnIndex<0) {
            spawnIndex = NUM_PARTICLES-1;
        }
    }
}
-(void)newParticleAtIndex:(int)i mode:(GLshort)mode x:(float)x y:(float)y fragIndex:(int)fragIndex time:(GLushort)time first:(bool)first{
    saps[i].mode = mode;
    saps[i].xc = x;
    saps[i].yc = y;
    saps[i].vPtr0->x = x;
    saps[i].vPtr0->y = y;
    saps[i].vPtr1->x = x;
    saps[i].vPtr1->y = y;
    saps[i].vPtr1->t = time;
    saps[i].t = 0;
    saps[i].isFirstPassiveInGroup=first;
    saps[i].vPtr1->t = time;
    saps[i].binomialLayer = 1;
    saps[i].fragIndex=fragIndex;
}

-(void)explodeField:(int)mode{
    for (int i = 0; i < NUM_PARTICLES; i+=NUM_PARTS) {
        //[self newMoleculeAtX:viewPtr->screen_info.view_width/2.0 andY:viewPtr->screen_info.view_height/2.0 andMode:mode];
        //[self initializeParticle:i atX:viewPtr->screen_info.view_width/2.0 andY:viewPtr->screen_info.view_height/2.0 andMode:mode andPart:0 isFirst:YES];
        [self newMoleculeAtX:viewPtr->screen_info.view_width/2.0 andY:viewPtr->screen_info.view_height/2.0 andMode:mode];
        //[self newParticleAtIndex:i mode:mode x:viewPtr->screen_info.view_width/2.0 y:viewPtr->screen_info.view_height/2.0 fragIndex:i time:[self randomNumberBetween:0 maxNumber:59] first:YES];
    }
}
-(void)initializeParticles{
    for (int i = 0; i < NUM_PARTICLES; i++) {
        [self newParticleAtIndex:i mode:MODE_OFF x:0.0 y:0.0 fragIndex:0 time:0 first:NO];
        saps[i].vPtr1->a =[self randomNumberBetween:15000 maxNumber:45000];
        saps[i].randAngle = [self randomNumberBetween:0.0 maxNumber:60000];
        saps[i].randDistance = [self randomNumberBetween:10 maxNumber:60000];
        saps[i].randTime = [self randomNumberBetween:0 maxNumber:60000];
    }
}
-(void)initializeTouchGhosts{
    for (int i = 0; i < 10; i++) {
        touchGhosts[i].active = NO;
        touchGhosts[i].currentPoint = CGPointMake(-200.0, -200.0);
        touchGhosts[i].velocity = CGPointMake(0.0, 0.0);
    }
}
@end
