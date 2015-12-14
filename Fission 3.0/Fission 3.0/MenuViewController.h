//
//  MenuViewController.h
//  Fission 3.0
//
//  Created by Luke Hill on 10/11/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomRotatingView.h"
#import "RadioStyleSegmentControl_Luke.h"
@interface MenuViewController : CustomRotatingView <UIPickerViewDataSource,UIPickerViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
@public
    NSArray *colorArray;
    UIImage *backgroundImage;
}
@property(nonatomic, retain) IBOutlet UIToolbar *toolBar;
@property(nonatomic, retain) IBOutlet RadioStyleSegmentControl_Luke *toolbarSegment;
@property(nonatomic, retain) IBOutlet UIView *seeThroughView,*view0, *view1, *view2, *view3;
@property(nonatomic, retain) IBOutlet UIButton *button_modePassive, *button_mode0,*button_mode1, *button_mode2,*button_mode3,*button_mode4,*button_mode5;//
@property(nonatomic, retain) IBOutlet UIButton *button_showToolbar, *button_defaultSettings, *loadPhoto;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *button_hideToolBar;
@property(nonatomic, retain) IBOutlet UISlider *slider_blur, *slider_particleSize, *slider_radius, *slider_speed, *slider_particleFragments, *slider_particleCount, *slider_particleCount2;
@property(nonatomic, retain) IBOutlet UISwitch *renderModeSwitch;
@property(nonatomic, retain) IBOutlet UISegmentedControl *drawModeSegment;
@property(nonatomic, retain) IBOutlet UITextField *particleCount;
@property(nonatomic, retain) IBOutlet UILabel *moreParticlesLabel;
@property(nonatomic, retain) IBOutlet UIPickerView *colorPicker;
@property (nonatomic, strong) UIPopoverController *imagePopOver;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
-(IBAction)unwindToMenuView:(UIStoryboardSegue*)unwindSegue;
-(IBAction)modeButtonPressed:(id)sender;
-(IBAction)toolbarSegmentChanged:(id)sender;
-(IBAction)blurChanged:(id)sender;
-(IBAction)particleSizeChanged:(id)sender;
-(IBAction)radiusChanged:(id)sender;
-(IBAction)speedChanged:(id)sender;
-(IBAction)particleFragmentsChanged:(id)sender;
-(IBAction)particleCountChanged:(id)sender;
-(IBAction)particleCount2Changed:(id)sender;
-(IBAction)drawModeSegmentChanged:(id)sender;
-(IBAction)restoreDefaultSettingsPressed:(id)sender;
-(IBAction)loadPhoto:(id)sender;
-(IBAction)buildFissionGrid:(id)sender;
-(IBAction)showIntro:(id)sender;
-(IBAction)renderModeSwitched:(id)sender;
-(IBAction)showToolBar:(id)sender;
-(void)showToolBarWithAnimation:(bool)animate;
-(void)hideToolBarWithAnimation:(bool)animate;
@end