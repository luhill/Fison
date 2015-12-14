//
//  IntroViewController.h
//  Fission 3.0
//
//  Created by Luke Hill on 8/12/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomRotatingView.h"
@interface IntroViewController : CustomRotatingView{

}
@property(nonatomic, retain) IBOutlet UIButton *button_upgrade;
-(IBAction)unwindToIntroView:(UIStoryboardSegue*)unwindSegue;
-(IBAction)upgradePressed:(id)sender;
@end
