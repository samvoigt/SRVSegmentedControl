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

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.segmentedControl.items = @[@"hello", @"how", @"are", @"you"];
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
