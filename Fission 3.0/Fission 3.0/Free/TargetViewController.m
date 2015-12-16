//
//  TargetViewController.m
//  Fission 3.0
//
//  Created by Luke Hill on 14/12/2015.
//  Copyright © 2015 Luke Hill. All rights reserved.
//

#import "TargetViewController.h"

@interface TargetViewController (){
    BOOL _bannerIsVisible;
    ADBannerView *_adBanner;
}

@end

@implementation TargetViewController
@synthesize loadPhoto;
-(void)viewDidLoad{
    [super viewDidLoad];
    _adBanner = [[ADBannerView alloc] initWithFrame:CGRectZero];
    _adBanner.delegate = self;
    [_adBanner setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    _adBanner.hidden = YES;
    _adBanner.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_adBanner];
    NSLog(@"Added banner");
    //loadPhoto.hidden=yes;
}
-(IBAction)modeButtonPressed:(id)sender{
    UIButton *b = (UIButton*)sender;
    if (b.tag>=5) {
        NSLog(@"Upgrade");
        NSURL *appStoreURL = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id483865749"];
        if ([[UIApplication sharedApplication]canOpenURL:appStoreURL])
            [[UIApplication sharedApplication]openURL:appStoreURL];
    }else{
        [super modeButtonPressed:sender];
    }
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    [super pickerView:pickerView didSelectRow:row inComponent:component];
    loadPhoto.hidden = YES;
}
#pragma mark - ads
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
/*!
 * @method bannerViewWillLoadAd:
 *
 * @discussion
 * Called when a banner has confirmation that an ad will be presented, but
 * before the resources necessary for presentation have loaded.
 */
- (void)layoutAnimated:(BOOL)animated{
    CGRect contentFrame = self.view.bounds;
    CGRect bannerFrame = _adBanner.frame;
    bool hideBanner;
    //bannerFrame.size.width=contentFrame.size.width;
    
    if (_adBanner.bannerLoaded){
        hideBanner = NO;
        _adBanner.hidden = hideBanner;
        contentFrame.size.height -= _adBanner.frame.size.height;
        bannerFrame.origin.y = 0;
    } else {
        hideBanner = YES;
        bannerFrame.origin.y = 0.0-bannerFrame.size.height;
    }
    
    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        //self.view.frame = contentFrame;
        [self.view layoutIfNeeded];
        _adBanner.frame = bannerFrame;
    }completion:^(BOOL finished){
        _adBanner.hidden=hideBanner;
    }]; }

-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
    NSLog(@"Recieve ad");
    [self layoutAnimated:YES];
}
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"Failed to recieve ad");
    [self layoutAnimated:YES];
}
/*!
 * @method bannerViewActionShouldBegin:willLeaveApplication:
 *
 * Called when the user taps on the banner and some action is to be taken.
 * Actions either display full screen content modally, or take the user to a
 * different application.
 *
 * The delegate may return NO to block the action from taking place, but this
 * should be avoided if possible because most ads pay significantly more when
 * the action takes place and, over the longer term, repeatedly blocking actions
 * will decrease the ad inventory available to the application.
 *
 * Applications should reduce their own activity while the advertisement's action
 * executes.
 */
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave{
    return YES;
}

/*!
 * @method bannerViewActionDidFinish:
 *
 * Called when a modal action has completed and control is returned to the
 * application. Games, media playback, and other activities that were paused in
 * bannerViewActionShouldBegin:willLeaveApplication: should resume at this point.
 */
- (void)bannerViewActionDidFinish:(ADBannerView *)banner{
    
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
