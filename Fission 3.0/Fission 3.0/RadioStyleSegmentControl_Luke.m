//
//  RadioStyleSegmentControl_Luke.m
//  Fission 3.0
//
//  Created by Luke Hill on 11/11/2015.
//  Copyright (c) 2015 Luke Hill. All rights reserved.
//

#import "RadioStyleSegmentControl_Luke.h"

@implementation RadioStyleSegmentControl_Luke


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    previousSelectedIndex = self.selectedSegmentIndex;
    [super touchesEnded:touches withEvent:event];
    if (previousSelectedIndex==self.selectedSegmentIndex) {
        previousSelectedIndex = -1;
        [self setSelectedSegmentIndex:-1];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}
-(void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex{
    previousSelectedIndex = self.selectedSegmentIndex;
    [super setSelectedSegmentIndex:selectedSegmentIndex];
}

@end
