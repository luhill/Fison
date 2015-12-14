//
//  TrackTouch.h
//  Fission 3.0
//
//  Created by Luke Hill on 30/11/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface TrackTouch : NSObject{
@public
    CGPoint p0,p1;
    NSTimer *touchTimer;
}
-(TrackTouch*)init;
@end
