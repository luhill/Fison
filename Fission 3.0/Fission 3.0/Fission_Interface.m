//
//  Fission_Interface.m
//  Fission 3.0
//
//  Created by Luke Hill on 23/11/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

#import "Fission_Interface.h"
#import "AppDelegate.h"
#import "GlobalAccess.h"

@implementation Fission (Fission_Interface)
-(void)doubleTap{
    NSLog(@"Double Tap");
    if (currentMode==MODE_PASSIVE) {
        currentMode=currentActiveMode;
    }else{
        currentMode=MODE_PASSIVE;
    }
}
-(void)setMode:(int)mode{
    currentMode = mode;
    if (!mode==MODE_PASSIVE) {
        currentActiveMode = mode;
    }
}
-(void)touchedAt:(CGPoint)p{
    [self newMoleculeAtX:p.x andY:p.y andMode:currentMode];
}
-(void)blurChanged:(float)val{
    blur = val;
}
-(void)collisionSizeChanged:(float)val{
    //Collision size must be an odd number as it is used to determine point size in the collision shader. Even sized points will not be centered correctly and have undeseried sided effects;
    int s = (int)(val*63.0+1.0);
    if (s%2==0) {
        s++;
    }
    collisionSize = s;
}
-(void)particleSizeChanged:(float)val{
    float s = val*31.0+1.0;
    particleSize = s;
    int c = floor((particleSize+32)/4);
    //collisionSize = (particleSize+32)/4;
    if (c%2==0) {
        c++;//point size must be odd for proper centering in shader
    }
    collisionSize = c;
    glLineWidth(s);
}
-(void)radiusChanged:(float)val{
    radius = val*512.0;
}
-(void)speedChanged:(float)val{
    speed = val/10.0*60000.0;
}
-(void)particleFragmentsChanged:(float)val{
    NUM_PARTS = (int)(val*99.0+1.0);
    BINOMIAL_LAYERS=ceilf(log2f((float)NUM_PARTS));
}
-(int)particleCountChanged:(float)val1 extraParticles:(float)val2{
    int numReg = val1*32000;
    int numExtra = val2*(viewPtr->vertices_info.fissionPoints/2-32000);
    NUM_PARTICLES = MIN(numReg+numExtra, viewPtr->vertices_info.fissionPoints);
    
    spawnIndex = MIN(spawnIndex, NUM_PARTICLES-1);
    for (int i = NUM_PARTICLES; i < viewPtr->vertices_info.fissionPoints/2; i++) {
        [self newParticleAtIndex:i mode:MODE_OFF x:0.0 y:0.0 fragIndex:0 time:0 first:NO];
    }
    return NUM_PARTICLES;
}
-(void)createTouchGhost:(CGPoint)location withVelocity:(CGPoint)velocity{
    if (!currentMode==MODE_PASSIVE) {
    touchGhosts[touchGhostIndex].active = YES;
    touchGhosts[touchGhostIndex].currentPoint = location;
    touchGhosts[touchGhostIndex].velocity = velocity;
    touchGhostIndex++;
    touchGhostIndex%=NUM_TOUCH_GHOSTS;
    }
}
-(void)restoreDefaultSettings{
    GlobalAccess *data;
    AppDelegate * delegate = [[UIApplication sharedApplication] delegate];
    data = delegate->global;
    
    data->menuView.slider_blur.value = 0.85;
    data->menuView.slider_particleSize.value = 1.0/31.0;
    data->menuView.slider_radius.value = 0.5;
    data->menuView.slider_speed.value = 0.5;
    data->menuView.slider_particleFragments.value = 16.0/100.0;
    
    [data->menuView.slider_blur sendActionsForControlEvents:UIControlEventValueChanged];
    [data->menuView.slider_particleSize sendActionsForControlEvents:UIControlEventValueChanged];
    [data->menuView.slider_radius sendActionsForControlEvents:UIControlEventValueChanged];
    [data->menuView.slider_speed sendActionsForControlEvents:UIControlEventValueChanged];
    [data->menuView.slider_particleFragments sendActionsForControlEvents:UIControlEventValueChanged];
}
-(void)renderModeSwitched:(BOOL)val{
    RENDER_MODE_SPRITE = val;
}
-(void)setParticleCount{
    GlobalAccess *data;
    AppDelegate * delegate = [[UIApplication sharedApplication] delegate];
    data = delegate->global;
    data->menuView.slider_particleCount.value = 0.5;
    [data->menuView.slider_particleCount sendActionsForControlEvents:UIControlEventValueChanged];
    data->menuView.renderModeSwitch.on =YES;
    [data->menuView.renderModeSwitch sendActionsForControlEvents:UIControlEventValueChanged];
}
-(void)showToolBar{
    GlobalAccess *data;
    AppDelegate * delegate = [[UIApplication sharedApplication] delegate];
    data = delegate->global;
    [data->menuView hideToolBarWithAnimation:NO];
    [data->menuView showToolBarWithAnimation:YES];
}
@end
