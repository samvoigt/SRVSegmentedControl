//
//  DemoViewController.m
//  SRVSegmentedControlDemo
//
//  Created by Sam Voigt on 4/22/16.
//  Copyright © 2016 Integer Wars. All rights reserved.
//

#import "DemoViewController.h"
#import "SRVSegmentedControl.h"

@interface DemoViewController ()

@property (weak, nonatomic) IBOutlet SRVSegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet UILabel *selectedSegmentLabel;

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.segmentedControl.items = @[@"hello", @"how", @"are", @"you"];
    [self updateSelectedSegmentLabel];
    
    self.segmentedControl.selectorImageColor = [UIColor purpleColor];
    self.segmentedControl.trackImageColor = [UIColor blueColor];
    
    self.segmentedControl.font = [UIFont boldSystemFontOfSize:10.0];
    
    self.segmentedControl.selectedTextColor = [UIColor redColor];
    self.segmentedControl.unselectedTextColor = [UIColor greenColor];
    
    self.segmentedControl.selectedSegmentIndex = 2;
}

- (IBAction)segmentedControlValueChanged:(SRVSegmentedControl *)sender {
    
    [self updateSelectedSegmentLabel];
}

- (void)updateSelectedSegmentLabel {
    self.selectedSegmentLabel.text = [NSString stringWithFormat:@"Selected Segment: %li", self.segmentedControl.selectedSegmentIndex];
}

@end
