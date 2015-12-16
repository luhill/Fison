//
//  IntroViewController.m
//  Fission 3.0
//
//  Created by Luke Hill on 8/12/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

#import "IntroViewController.h"
#import "AppDelegate.h"
#import "GlobalAccess.h"

@interface IntroViewController ()

@end

@implementation IntroViewController
@synthesize button_upgrade, splash;

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    GlobalAccess *data = appDelegate.global;
    data->introView = self;
    viewDescription =@"Intro";
    button_upgrade.hidden = NO;
    splash.alpha = 0.0;
    //[data->menuView performSegueWithIdentifier:@"PushIntro" sender:data->menuView];
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated{
    
    [UIView animateWithDuration:2.0 animations:^{
        splash.alpha = 1.0;
        [self.view layoutIfNeeded];
    }];
}
-(IBAction)upgradePressed:(id)sender{
    NSLog(@"Upgrade");
    //483865749
    NSURL *appStoreURL = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id483865749"];
    if ([[UIApplication sharedApplication]canOpenURL:appStoreURL])
        [[UIApplication sharedApplication]openURL:appStoreURL];
}
-(IBAction)unwindToIntroView:(UIStoryboardSegue*)unwindSegue{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    GlobalAccess *data = appDelegate.global;
    data->glView->fission->USING_INTRO = YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
