//
//  UIImage+RotatedImage.m
//  Fission 3.0
//
//  Created by Luke Hill on 19/12/2015.
//  Copyright © 2015 Luke Hill. All rights reserved.
//

#import "UIImage+RotatedImage.h"

@implementation UIImage (RotatedImage)
- (UIImage *)normalizedImage:(UIImage*)image {
    /*
    UIImageOrientation targetOrientation;
    switch (glOrientation) {
        case UIInterfaceOrientationPortrait:{
            targetOrientation = UIImageOrientationUp;
            break;}
        case UIInterfaceOrientationPortraitUpsideDown:{
            targetOrientation = UIImageOrientationDown;
            break;}
        case UIInterfaceOrientationLandscapeLeft:{
            targetOrientation = UIImageOrientationLeft;
            break;}
        case UIInterfaceOrientationLandscapeRight:{
            targetOrientation = UIImageOrientationRight;
            break;}
        default:
            break;
    }
    if (self.imageOrientation == targetOrientation) return self;
    */
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:(CGRect){0, 0, image.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}
-(UIImage*)imageForOrientation:(UIInterfaceOrientation)orientation andFrame:(CGRect)frame toGlFrame:(CGRect)glframe glOrientation:(UIInterfaceOrientation)glOrientation{
    //Get rid or current orientation
    
    //UIImage*fixedImage = [self scaleImageToSize:self toFrame:glframe];
    UIImage* fixedImage = [self normalizedImage:self];//portrait version of the image
    
   
    fixedImage = [self counterRotateImage:fixedImage orientation:glOrientation];//gl version of the image
    
    fixedImage = [self normalizedImage:fixedImage];//portrait version of gl imgae
    
    fixedImage = [self scaleImageToSize:[self rotateImage:fixedImage orientation:orientation] toFrame:frame glFrame:glframe];
    
    
    return fixedImage;
}
- (UIImage *)scaleImageToSize:(UIImage*)original toFrame:(CGRect)frame glFrame:(CGRect)glFrame{
    CGRect viewRect = frame;
    if (frame.size.width>frame.size.height) {
        //view
    }
    //Frame is no longer constant in ios9 and changes when screen rotates
    viewRect.size.width = MIN(frame.size.width, frame.size.height);
    viewRect.size.height = MAX(frame.size.width, frame.size.height);
    CGRect scaledImageRect = CGRectZero;
    CGFloat aspectWidth, aspectHeight;
    if (glFrame.size.width > glFrame.size.height) {
        viewRect.size.width = MAX(frame.size.width, frame.size.height);
        viewRect.size.height = MIN(frame.size.width, frame.size.height);
        aspectWidth = viewRect.size.width / original.size.width;
        aspectHeight = viewRect.size.height / original.size.height;
    }else{
        viewRect.size.width = MIN(frame.size.width, frame.size.height);
        viewRect.size.height = MAX(frame.size.width, frame.size.height);
        aspectWidth = viewRect.size.width / original.size.width;
        aspectHeight = viewRect.size.height / original.size.height;
    }
    CGFloat aspectRatio = MAX( aspectWidth, aspectHeight );
    
    scaledImageRect.size.width = original.size.width * aspectRatio;
    scaledImageRect.size.height = original.size.height * aspectRatio;
    scaledImageRect.origin.x = (viewRect.size.width - scaledImageRect.size.width) / 2.0f;
    scaledImageRect.origin.y = (viewRect.size.height - scaledImageRect.size.height) / 2.0f;
    
    UIGraphicsBeginImageContextWithOptions( viewRect.size, NO, 0 );
    [original drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}
-(UIImage*)counterRotateImage:(UIImage*)original orientation:(UIInterfaceOrientation)uiOrientation{
    UIImageOrientation newOrientation;
    
    switch (uiOrientation) {
        case UIInterfaceOrientationPortrait:{
           // NSLog(@"Portrait");
            newOrientation = UIImageOrientationUp;
        }break;
        case UIInterfaceOrientationPortraitUpsideDown:{
           // NSLog(@"Portrait Down");
            newOrientation = UIImageOrientationDown;
        }break;
        case UIInterfaceOrientationLandscapeLeft:{
            //NSLog(@"Land Left");
            newOrientation = UIImageOrientationRight;
        }break;
        case UIInterfaceOrientationLandscapeRight:{
            //NSLog(@"Land right");
            newOrientation = UIImageOrientationLeft;
        }break;
        default:{//flat or other
            //NSLog(@"Other");
            newOrientation = UIImageOrientationUp;
        }break;
    }
    UIImage * rotatedImage = [[UIImage alloc] initWithCGImage: original.CGImage scale: 1.0 orientation: newOrientation];
    return rotatedImage;
}
-(UIImage*)rotateImage:(UIImage*)original orientation:(UIInterfaceOrientation)uiOrientation{
    UIImageOrientation newOrientation;
    
    switch (uiOrientation) {
        case UIInterfaceOrientationPortrait:{
            NSLog(@"Portrait");
            newOrientation = UIImageOrientationUp;
        }break;
        case UIInterfaceOrientationPortraitUpsideDown:{
            NSLog(@"Portrait Down");
            newOrientation = UIImageOrientationDown;
        }break;
        case UIInterfaceOrientationLandscapeLeft:{
            NSLog(@"Land Left");
            newOrientation = UIImageOrientationLeft;
        }break;
        case UIInterfaceOrientationLandscapeRight:{
            NSLog(@"Land right");
            newOrientation = UIImageOrientationRight;
        }break;
        default:{//flat or other
            NSLog(@"Other");
            newOrientation = UIImageOrientationUp;
        }break;
    }
    UIImage * rotatedImage = [[UIImage alloc] initWithCGImage: original.CGImage scale: 1.0 orientation: newOrientation];
    return rotatedImage;
}
- (UIImage *)fixOrientation {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
@end
