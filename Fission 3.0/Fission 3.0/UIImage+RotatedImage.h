//
//  UIImage+RotatedImage.h
//  Fission 3.0
//
//  Created by Luke Hill on 19/12/2015.
//  Copyright © 2015 Luke Hill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (RotatedImage)

-(UIImage*)imageForOrientation:(UIInterfaceOrientation)orientation andFrame:(CGRect)frame toGlFrame:(CGRect)glFrame glOrientation:(UIInterfaceOrientation)glOrientation;
@end
