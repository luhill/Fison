//
//  InstructionsViewController.m
//  Fission 3.0
//
//  Created by Luke Hill on 8/12/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

#import "InstructionsViewController.h"
#import "AppDelegate.h"
#import "GlobalAccess.h"
@interface InstructionsViewController ()

@end

@implementation InstructionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    GlobalAccess *data = appDelegate.global;
    data->instructionsView = self;
    viewDescription =@"Intructions";
}

@end
