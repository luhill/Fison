//
//  MenuViewController.m
//  Fission 3.0
//
//  Created by Luke Hill on 10/11/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

#import "MenuViewController.h"
#import "AppDelegate.h"
#import "GlobalAccess.h"
#import "GL_Texture.h"
#import "GL_OpenGL.h"
#import "UIImage+RotatedImage.h"
@interface MenuViewController ()

@end
@implementation MenuViewController
GlobalAccess *data;
AppDelegate *appDelegate;
@synthesize toolBar, toolbarSegment;
@synthesize button_modePassive, button_mode0, button_mode1, button_mode2,button_mode3,button_mode4,button_mode5;
@synthesize slider_blur, slider_particleSize, slider_radius, slider_speed, slider_particleFragments, slider_particleCount, slider_particleCount2;
@synthesize particleCount;
@synthesize moreParticlesLabel;
@synthesize colorPicker;
@synthesize drawModeSegment;
@synthesize button_showToolbar, button_hideToolBar, loadPhoto;
@synthesize seeThroughView,view0, view1, view2, view3;
@synthesize imagePicker, imagePopOver;
@synthesize renderModeSwitch;
@synthesize backgroundImage;
@synthesize upgradeButton;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    viewDescription =@"Menu";
    appDelegate = [[UIApplication sharedApplication] delegate];
    data = appDelegate.global;
    data->menuView = self;
    colorArray =[[NSArray alloc] initWithObjects:@"custom",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14", nil];
    [data->glView->fission restoreDefaultSettings];
    [data->glView->fission setParticleCount];
    [colorPicker selectRow:1 inComponent:0 animated:NO];
    [self setupFreeVersionUI:loadPhoto slider2:slider_particleCount2];
    [self hideToolBarWithAnimation:NO];
    button_showToolbar.hidden = YES;
    upgradeButton.hidden = YES;
    loadPhoto.hidden = YES;
    backgroundImage = [UIImage imageNamed:@"background"];
    UIColor *back = [UIColor clearColor];//[UIColor colorWithWhite:1.0 alpha:0.1];
    view0.backgroundColor = back;
    view1.backgroundColor = back;
    view2.backgroundColor = back;
    view3.backgroundColor = back;
    [self initilizeBackgroundPhoto];

}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //[self initilizeBackgroundPhoto];
}
-(void)setupFreeVersionUI:(UIButton*)loadPhoto slider2:(UISlider*)slider2{
    //do nothing. free version subclasses this method to setup ui
}
//////////////////////////////////////////////////////////////////////////////////////
//-------------------------Application Specific Methods-----------------------------//
//////////////////////////////////////////////////////////////////////////////////////
// This method creates an image by changing individual pixels of an image. Color of pixel has been taken from an array of colours('avgRGBsOfPixel')
-(IBAction)unwindToMenuView:(UIStoryboardSegue*)unwindSegue{
    data->glView->fission->COLLAPSING_INTRO = YES;
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self initilizeBackgroundPhoto];
}

#pragma mark - Color Picker
-(void)initilizeBackgroundPhoto{
    //called when glview loads
    [data->glView setBackGroundImage:[backgroundImage imageForOrientation:self.interfaceOrientation andFrame:self.view.frame toGlFrame:data->glView.view.frame glOrientation:data.glView.interfaceOrientation]];
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component{
    return colorArray.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    NSString* imgName = [colorArray objectAtIndex:row];
    if ([imgName  isEqual: @"custom"]) {
        UIView *myView = [UIView new];
        myView.frame = CGRectMake(0, 0, pickerView.frame.size.width, 20);
        UILabel *selectLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 20)];
        selectLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        selectLabel.textAlignment = NSTextAlignmentCenter;
        selectLabel.text = @"Background Image";
        [myView addSubview:selectLabel];
        return myView;
    }else{
        UIImageView *myImageView = [UIImageView alloc];
        myImageView = [myImageView initWithImage:[UIImage imageNamed:[colorArray objectAtIndex:row]]];
        myImageView.frame = CGRectMake(0, 0, pickerView.frame.size.width, 20);
        return myImageView;
    }
}
-(void)hideLoadPhoto:(UIButton*)loadPhoto{
    
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSString* imgName = [colorArray objectAtIndex:row];
    if ([imgName isEqual:@"custom"]) {
        loadPhoto.hidden = NO;
        [self hideLoadPhoto:loadPhoto];
        data->glView->fission->COLOR_MODE_IMAGE = YES;
        //[data->glView setColorMapWithImage:((UIImageView*)([pickerView viewForRow:row forComponent:component])).image];
    }else{
        loadPhoto.hidden = YES;
        [data->glView setColorMap:[colorArray objectAtIndex:row]];
        data->glView->fission->COLOR_MODE_IMAGE = NO;
    }
    
}
#pragma mark - Image Picker

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    backgroundImage = image;
    NSLog(@"Image Orientation:%li",(long)backgroundImage.imageOrientation);
    [self initilizeBackgroundPhoto];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [imagePopOver dismissPopoverAnimated:YES];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    imagePicker = nil;
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [imagePopOver dismissPopoverAnimated:YES];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}
-(IBAction)loadPhoto:(id)sender{
    NSLog(@"Loading Photo");
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    //imagePickerController.showsCameraControls  = NO;
    imagePicker = imagePickerController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        [popover presentPopoverFromRect:loadPhoto.frame inView:view1 permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        imagePopOver = popover;
    } else {
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark - Interface Buttons
-(IBAction)showIntro:(id)sender{
    [self performSegueWithIdentifier:@"PushIntro" sender:sender];
    [self hideToolBarWithAnimation:NO];
    data->glView->fission->USING_INTRO = YES;
    data->glView->fission->introTimer = 0.0;
    data->glView->fission->introCountDown = 1.0;
    data->glView->fission->COLLAPSING_INTRO = NO;
}
-(IBAction)upgradePressed:(id)sender{
    
}
-(IBAction)restoreDefaultSettingsPressed:(id)sender{
    [data->glView->fission restoreDefaultSettings];
}
-(IBAction)modeButtonPressed:(id)sender{
    UIButton *b = (UIButton*)sender;
    button_modePassive.selected = NO;
    button_mode0.selected = NO;
    button_mode1.selected = NO;
    button_mode2.selected = NO;
    button_mode3.selected = NO;
    button_mode4.selected = NO;
    button_mode5.selected = NO;
    b.selected = YES;
    [data.glView->fission setMode:(int)b.tag];
}
-(IBAction)buildFissionGrid:(id)sender{
    [data->glView->fission explodeField:MODE_PACTIVE];
}
-(IBAction)blurChanged:(id)sender{
    [data->glView->fission blurChanged: slider_blur.value];
}
-(IBAction)particleSizeChanged:(id)sender{
    [data->glView->fission particleSizeChanged: slider_particleSize.value];
}
-(IBAction)radiusChanged:(id)sender{
    [data->glView->fission radiusChanged: slider_radius.value];
}
-(IBAction)speedChanged:(id)sender{
    [data->glView->fission speedChanged: slider_speed.value];
}
-(IBAction)particleFragmentsChanged:(id)sender{
    [data->glView->fission particleFragmentsChanged: slider_particleFragments.value];
}
-(void)setUpgradeButtonVisible:(UIButton*)button hideIt:(BOOL)hide{
    
}
-(IBAction)particleCountChanged:(id)sender{
    float val = slider_particleCount.value;
    if (val<1.0) {
        [self setUpgradeButtonVisible:upgradeButton hideIt:YES];
        slider_particleCount2.hidden = YES;
        moreParticlesLabel.hidden = YES;
        slider_particleCount2.value = 0.0;
    }else{
        slider_particleCount2.hidden = NO;
        moreParticlesLabel.hidden = NO;
        [self setUpgradeButtonVisible:upgradeButton hideIt:NO];
    }
    int count = [data->glView->fission particleCountChanged: slider_particleCount.value extraParticles:slider_particleCount2.value];
    particleCount.text = [NSString stringWithFormat:@"%1i",count];
}
-(IBAction)particleCount2Changed:(id)sender{
    int count = [data->glView->fission particleCountChanged: slider_particleCount.value extraParticles:slider_particleCount2.value];
    particleCount.text = [NSString stringWithFormat:@"%1i",count];
}
-(IBAction)drawModeSegmentChanged:(id)sender{
    data->glView->draw_mode = (int)drawModeSegment.selectedSegmentIndex;
}
-(IBAction)renderModeSwitched:(id)sender{
    data->glView->fission->RENDER_MODE_SPRITE = renderModeSwitch.on;
}
#pragma mark - Reusable Interface Items
//////////////////////////////////////////////////////////////////////////////////////
//-----------------------Template Items for tool bar views--------------------------//
//////////////////////////////////////////////////////////////////////////////////////

-(void)hideToolBarWithAnimation:(bool)animate{
    CGRect frame = toolBar.frame;
    frame.origin.y = seeThroughView.bounds.size.height+toolBar.frame.size.height;
    if (animate) {
        [UIView animateWithDuration:0.3f animations:^{
            toolBar.frame = frame;
        }completion:^(BOOL finished){
            toolBar.hidden=YES;
            button_showToolbar.hidden = NO;
        }];
    }else{
        toolBar.frame = frame;
        toolBar.hidden=YES;
        button_showToolbar.hidden = NO;
    }
    
    view0.hidden = YES;
    view1.hidden = YES;
    view2.hidden = YES;
    view3.hidden = YES;
    
    toolbarSegment->previousSelectedIndex=-1;
}
-(void)showToolBarWithAnimation:(bool)animate{
    CGRect frame = toolBar.frame;
    frame.origin.y = seeThroughView.bounds.size.height-toolBar.frame.size.height;
    toolBar.hidden = NO;
    [UIView animateWithDuration:0.3f animations:^{
        toolBar.frame = frame;
    }];
    
    button_showToolbar.hidden = YES;
    [self showAndHideMenus];
}
-(IBAction)showToolBar:(id)sender{
    [self showToolBarWithAnimation:YES];
}
-(IBAction)hideToolBar:(id)sender{
    [self hideToolBarWithAnimation:YES];
}
-(IBAction)toolbarSegmentChanged:(id)sender{
    [self showAndHideMenus];
}
- (IBAction)showGestureForSwipeRecognizer:(UISwipeGestureRecognizer *)recognizer {
    NSInteger index = toolbarSegment.selectedSegmentIndex;
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        index++;
    }else if (recognizer.direction==UISwipeGestureRecognizerDirectionRight){
        index--;
    }else if (recognizer.direction==UISwipeGestureRecognizerDirectionDown){
        NSLog(@"Swipe Down");
        index = -1;
    }
    index%=4;
    toolbarSegment.selectedSegmentIndex = index;
    [self showAndHideMenus];
}
-(void)setViewPositionsForIndex:(NSInteger)index previousIndex:(NSInteger)indexOld{
    CGRect frame0, frame1, frame2, frame3;
    float y = toolBar.frame.origin.y;
    float y0, y1, y2,y3;
    
    frame0 = view0.frame;
    frame1 = view1.frame;
    frame2 = view2.frame;
    frame3 = view3.frame;
    if (indexOld<0) {
        indexOld=index;
        y0 = seeThroughView.bounds.size.height;
        y1 = y0;
        y2 = y0;
        y3 = y0;
    }else{
        y0 = y-frame0.size.height;
        y1 = y-frame1.size.height;
        y2 = y-frame2.size.height;
        y3 = y-frame3.size.height;
    }
    
    //set initial spacing
    switch (indexOld) {
        case -1:{//close all
            frame0.origin = CGPointMake(0.0*toolBar.frame.size.width, y0);
            frame1.origin = CGPointMake(1.0*toolBar.frame.size.width, y1);
            frame2.origin = CGPointMake(2.0*toolBar.frame.size.width, y2);
            frame3.origin = CGPointMake(3.0*toolBar.frame.size.width, y3);
            break;}
        case 0:{
            frame0.origin = CGPointMake(0.0*toolBar.frame.size.width, y0);
            frame1.origin = CGPointMake(1.0*toolBar.frame.size.width, y1);
            frame2.origin = CGPointMake(2.0*toolBar.frame.size.width, y2);
            frame3.origin = CGPointMake(3.0*toolBar.frame.size.width, y3);
            //view0.hidden = NO; view1.hidden = NO; view2.hidden = NO;
            break;}
        case 1:{
            frame0.origin = CGPointMake(-1.0*toolBar.frame.size.width,y0);
            frame1.origin = CGPointMake(0.0*toolBar.frame.size.width, y1);
            frame2.origin = CGPointMake(1.0*toolBar.frame.size.width, y2);
            frame3.origin = CGPointMake(2.0*toolBar.frame.size.width, y3);
        break;}
        case 2:{
            frame0.origin = CGPointMake(-2.0*toolBar.frame.size.width, y0);
            frame1.origin = CGPointMake(-1.0*toolBar.frame.size.width, y1);
            frame2.origin = CGPointMake(0.0*toolBar.frame.size.width, y2);
            frame3.origin = CGPointMake(1.0*toolBar.frame.size.width, y3);
            break;}
        case 3:{
            frame0.origin = CGPointMake(-3.0*toolBar.frame.size.width, y0);
            frame1.origin = CGPointMake(-2.0*toolBar.frame.size.width, y1);
            frame2.origin = CGPointMake(-1.0*toolBar.frame.size.width, y2);
            frame3.origin = CGPointMake(0.0*toolBar.frame.size.width, y3);
            break;}
        default:{
            break;}
    }
    view0.frame = frame0;
    view1.frame = frame1;
    view2.frame = frame2;
    view3.frame = frame3;
}

-(void)showAndHideMenus{
    NSInteger selectedIndex = toolbarSegment.selectedSegmentIndex;
    NSInteger previousIndex = toolbarSegment->previousSelectedIndex;
    
    CGRect frame0, frame1, frame2, frame3;
    BOOL hide0 = YES, hide1 = YES, hide2 = YES, hide3 = YES;
    float y = toolBar.frame.origin.y;
    
    frame0 = view0.frame;
    frame1 = view1.frame;
    frame2 = view2.frame;
    frame3 = view3.frame;
    //frame0.origin = CGPointMake(0, y-frame0.size.height);
    //frame1.origin = CGPointMake(0, y-frame1.size.height);
    //frame2.origin = CGPointMake(0, y-frame2.size.height);
    
    //Before animating the views make sure the intial positions are set up correctly
    [self setViewPositionsForIndex:selectedIndex previousIndex:previousIndex];
    
    //Unhide views before animation so that they can be visible while they slide in
    if (selectedIndex>=0) {
        view0.hidden = NO; view1.hidden = NO; view2.hidden = NO; view3.hidden = NO;
    }
    //set the final positions for the views
        switch (selectedIndex) {
            case -1:{//close all
                hide0 = YES; hide1 = YES; hide2 = YES; hide3 = YES;
                frame0.origin.y = seeThroughView.frame.size.height;
                frame1.origin.y = seeThroughView.frame.size.height;
                frame2.origin.y = seeThroughView.frame.size.height;
                frame3.origin.y = seeThroughView.frame.size.height;
                break;}
            case 0:{
                hide0 = NO; hide1 = YES; hide2 = YES; hide3 = YES;
                frame0.origin = CGPointMake(0.0*toolBar.frame.size.width, y-frame0.size.height);
                frame1.origin = CGPointMake(1.0*toolBar.frame.size.width, y-frame1.size.height);
                frame2.origin = CGPointMake(2.0*toolBar.frame.size.width, y-frame2.size.height);
                frame3.origin = CGPointMake(3.0*toolBar.frame.size.width, y-frame3.size.height);
                break;}
            case 1:{
                hide0 = YES; hide1 = NO; hide2 = YES; hide3 = YES;
                frame0.origin = CGPointMake(-1.0*toolBar.frame.size.width, y-frame0.size.height);
                frame1.origin = CGPointMake(0.0*toolBar.frame.size.width, y-frame1.size.height);
                frame2.origin = CGPointMake(1.0*toolBar.frame.size.width, y-frame2.size.height);
                frame3.origin = CGPointMake(2.0*toolBar.frame.size.width, y-frame3.size.height);
                break;}
            case 2:{
                hide0 = YES; hide1 = YES; hide2 = NO; hide3 = YES;
                frame0.origin = CGPointMake(-2.0*toolBar.frame.size.width, y-frame0.size.height);
                frame1.origin = CGPointMake(-1.0*toolBar.frame.size.width, y-frame1.size.height);
                frame2.origin = CGPointMake(0.0*toolBar.frame.size.width, y-frame2.size.height);
                frame3.origin = CGPointMake(1.0*toolBar.frame.size.width, y-frame3.size.height);
                break;}
            case 3:{
                hide0 = YES; hide1 = YES; hide2 = YES; hide3 = NO;
                frame0.origin = CGPointMake(-3.0*toolBar.frame.size.width, y-frame0.size.height);
                frame1.origin = CGPointMake(-3.0*toolBar.frame.size.width, y-frame1.size.height);
                frame2.origin = CGPointMake(-1.0*toolBar.frame.size.width, y-frame2.size.height);
                frame3.origin = CGPointMake(0.0*toolBar.frame.size.width, y-frame3.size.height);
                break;}
            default:{
                break;}
        }
    //animate the view movements
    [UIView animateWithDuration:0.3f animations:^{
        if (!hide0) {
            view0.hidden = hide0;
        }
        if (!hide1) {
            view2.hidden = hide1;
        }
        if (!hide2) {
            view2.hidden = hide2;
        }
        if (!hide3) {
            view3.hidden = hide3;
        }
        view0.frame = frame0;
        view1.frame = frame1;
        view2.frame = frame2;
        view3.frame = frame3;
        
    } completion:^(BOOL finished){
        //after the animation finishes, hide the unnessecary views
        view0.hidden = hide0;
        view1.hidden = hide1;
        view2.hidden = hide2;
        view3.hidden = hide3;
    }
     ];
    
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
