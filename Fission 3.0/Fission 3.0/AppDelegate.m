//
//  AppDelegate.m
//  Fission 3.0
//
//  Created by Luke Hill on 10/11/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

#import "AppDelegate.h"
#import "GlobalAccess.h"
@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize global;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self addGlWindow];
    // Override point for customization after application launch.
    
    [self.window setBackgroundColor:[UIColor clearColor]];
    self.window.opaque = NO;
    [self.window makeKeyAndVisible];
    [self addAndRemoveSplash];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self.window.rootViewController performSegueWithIdentifier:@"PushIntro" sender:self];
    });
    
    return YES;
}
-(void)addAndRemoveSplash{
    UIImageView *splashScreen = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LaunchScreen"]];
    [self.window addSubview:splashScreen];
    [self.window makeKeyAndVisible];
    
    [UIView animateWithDuration:1.0 animations:^{splashScreen.alpha = 0.0;}
                     completion:(void (^)(BOOL)) ^{
                         [splashScreen removeFromSuperview];
                     }
     ];
}
-(id)init{
    //[self.window makeKeyAndVisible];
    self.global = [[GlobalAccess alloc] init];
    return [super init];
}
-(void)addGlWindow{
    global.glView = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GlView"];
    UIWindow *window2 = [[UIWindow alloc] initWithFrame:global.glView.view.frame];
    window2.rootViewController = global.glView;
    window2.userInteractionEnabled = YES;
    window2.hidden = NO;
    self.windowGL = window2;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //NSLog(@"Pushing intro");
    //
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
