//
//  CAEAGLLayer+Retained.m
//  Fission 3.0
//
//  Created by Luke Hill on 19/12/2015.
//  Copyright © 2015 Luke Hill. All rights reserved.
//

#import "CAEAGLLayer+Retained.h"

@implementation CAEAGLLayer (Retained)
- (NSDictionary*) drawableProperties
{
    NSLog(@"REtained");
    return @{kEAGLDrawablePropertyRetainedBacking : @(YES)};
}

@end
