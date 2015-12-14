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
    [self addNonRotatingGLView];
    // Override point for customization after application launch.
    // We want to prevent rotating our gl view but only rotate menu view
    UIDevice *device = [UIDevice currentDevice];					//Get the device object
    [device beginGeneratingDeviceOrientationNotifications];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self											//Add yourself as an observer
           selector:@selector(orientationChanged:)
               name:UIDeviceOrientationDidChangeNotification
             object:device];
    
    // Override point for customization after application launch.
    
    [self.window makeKeyAndVisible];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self.window.rootViewController performSegueWithIdentifier:@"PushIntro" sender:self];
    });
    self.window.backgroundColor = [UIColor clearColor];
    return YES;
}
-(void)orientationChanged:(NSNotification*)notification{
    //[global.menuView orientationChanged:YES];
    //[global.introView orientationChanged:YES];
    //[global.instructionsView orientationChanged:YES];
}
-(id)init{
    //[self.window makeKeyAndVisible];
    self.global = [[GlobalAccess alloc] init];
    return [super init];
}
-(void)addNonRotatingGLView{
    global.glView = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GlView"];
    //NSLog(@"Adding gl View");
    [self.window addSubview:global.glView.view];
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
