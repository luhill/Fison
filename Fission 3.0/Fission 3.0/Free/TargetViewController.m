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
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //_adBanner = [[ADBannerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    //_adBanner.delegate = self;
}
/*!
 * @method bannerViewWillLoadAd:
 *
 * @discussion
 * Called when a banner has confirmation that an ad will be presented, but
 * before the resources necessary for presentation have loaded.
 */
- (void)bannerViewWillLoadAd:(ADBannerView *)banner{
    
}
- (void)bannerViewDidLoadAd:(ADBannerView *)banner{
    
}

/*!
 * @method bannerView:didFailToReceiveAdWithError:
 *
 * @discussion
 * Called when an error has occurred while attempting to get ad content. If the
 * banner is being displayed when an error occurs, it should be hidden
 * to prevent display of a banner view with no ad content.
 *
 * @see ADError for a list of possible error codes.
 */
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    
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
    return NO;
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
