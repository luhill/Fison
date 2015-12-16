//
//  Fission_Interface.h
//  Fission 3.0
//
//  Created by Luke Hill on 23/11/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Fission.h"
@interface Fission (Fission_Interface){
    
}
-(void)blurChanged:(float)val;
-(void)collisionSizeChanged:(float)val;
-(void)particleSizeChanged:(float)val;
-(void)radiusChanged:(float)val;
-(void)speedChanged:(float)val;
-(void)particleFragmentsChanged:(float)val;
-(void)createTouchGhost:(CGPoint)location withVelocity:(CGPoint)velocity;
-(void)restoreDefaultSettings;
-(void)setParticleCount;
-(void)doubleTap;
-(void)touchedAt:(CGPoint)p;
-(int)particleCountChanged:(float)val extraParticles:(float)val2;
-(void)setMode:(int)mode;
-(void)toggleMode;
-(void)renderModeSwitched:(BOOL)val;
-(void)showToolBar;

@end
