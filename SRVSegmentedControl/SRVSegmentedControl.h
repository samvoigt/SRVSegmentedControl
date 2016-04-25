//
//  SRVSegmentedControl.h
//  SRVSegmentedControlDemo
//
//  Created by Sam Voigt on 4/22/16.
//  Copyright © 2016 Integer Wars. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SRVSegmentedControl : UIControl

@property (nonatomic, strong) NSArray<NSString *> *items;
@property (nonatomic, strong) UIImage *trackImage;
@property (nonatomic, strong) UIColor *trackColor;

@property (nonatomic, strong) UIImage *selectorImage;
@property (nonatomic, strong) UIColor *selectorColor;

@property (nonatomic, strong) UIFont *font;

@property (nonatomic, strong) UIColor *selectedFontColor;
@property (nonatomic, strong) UIColor *unselectedFontColor;

@property (nonatomic) CGFloat minimumLabelBuffer;

@property (nonatomic) NSInteger selectedSegmentIndex;

- (void)setSelectedSegmentIndex:(NSInteger)segmentIndex animated:(BOOL)animated;

- (instancetype)initWithItems:(NSArray<NSString *> *)items;

@end
