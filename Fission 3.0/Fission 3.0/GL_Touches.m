//
//  VC_Touches.m
//  Fission 3.0
//
//  Created by Luke Hill on 12/11/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

#import "GL_Touches.h"
#import "GL_OpenGL.h"
#import "TrackTouch.h"
#import "Fission_Interface.h"
@implementation GL_ViewController (GL_Touches)

-(CGPoint)flipPoint:(CGPoint)p{
    return CGPointMake(p.x, screen_info.view_height-p.y);
}
-(void)touchedAt:(CGPoint)p{
    [fission touchedAt:p];
}
-(void)touchTimerMethod:(NSTimer*)theTimer{
    CGPoint p = [[theTimer userInfo] locationInView:self.view];
    [self touchedAt:[self flipPoint:p]];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (touchDictionary==NULL) {
        touchDictionary = CFDictionaryCreateMutable(NULL, 0,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
    }
    for (UITouch *touch in touches) {
        TrackTouch *trackTouch = (TrackTouch *)CFDictionaryGetValue(touchDictionary,(__bridge void *)(touch));
        if (trackTouch==NULL) {
            trackTouch = [[TrackTouch alloc] init];
            trackTouch->touchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(touchTimerMethod:) userInfo:touch repeats:YES];
            trackTouch->p0 = [self flipPoint:[touch locationInView:self.view]];
            trackTouch->p1 = [self flipPoint:[touch locationInView:self.view]];
            CFDictionarySetValue(touchDictionary, (__bridge const void *)(touch),(__bridge const void *)(trackTouch));
        }
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UITouch *touch in touches) {
        TrackTouch *trackTouch = (TrackTouch *)CFDictionaryGetValue(touchDictionary, (__bridge void *)(touch));
        if (trackTouch) {
            trackTouch->p0 = [self flipPoint:[touch previousLocationInView:self.view]];
            trackTouch->p1 = [self flipPoint:[touch locationInView:self.view]];
            [self touchedAt:trackTouch->p1];
            if ([trackTouch->touchTimer isValid]) {
                [trackTouch->touchTimer invalidate];
                trackTouch->touchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(touchTimerMethod:) userInfo:touch repeats:YES];
            }
        }
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UITouch *touch in touches) {
        TrackTouch *trackTouch = (TrackTouch *)CFDictionaryGetValue(touchDictionary,(__bridge void *)(touch));
        if (trackTouch) {
            if ([trackTouch->touchTimer isValid]) {
                [trackTouch->touchTimer invalidate];
            }
            [fission createTouchGhost:trackTouch->p1 withVelocity:CGPointMake(trackTouch->p1.x-trackTouch->p0.x, trackTouch->p1.y-trackTouch->p0.y)];
            CFDictionaryRemoveValue(touchDictionary, (__bridge void *)(touch));
        }
    }
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UITouch *touch in touches) {
        TrackTouch *trackTouch = (TrackTouch *)CFDictionaryGetValue(touchDictionary,(__bridge void *)(touch));
        if (trackTouch) {
            if ([trackTouch->touchTimer isValid]) {
                [trackTouch->touchTimer invalidate];
            }
            CFDictionaryRemoveValue(touchDictionary, (__bridge void *)(touch));
        }
    }
}
@end
