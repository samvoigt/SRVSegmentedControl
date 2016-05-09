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
@property (nonatomic, strong) UIImage *selectorImage;

@property (nonatomic, strong) UIColor *trackImageColor;
@property (nonatomic, strong) UIColor *selectorImageColor;

@property (nonatomic, strong) UIView *trackView;
@property (nonatomic, strong) UIView *selectorView;

@property (nonatomic, strong) UIFont *font;

@property (nonatomic, strong) UIColor *selectedTextColor;
@property (nonatomic, strong) UIColor *unselectedTextColor;

@property (nonatomic) NSInteger selectedSegmentIndex;

- (void)setSelectedSegmentIndex:(NSInteger)segmentIndex animated:(BOOL)animated;

- (instancetype)initWithItems:(NSArray<NSString *> *)items;

- (instancetype)initWithItems:(NSArray<NSString *> *)items
                         font:(UIFont *)font
            selectedTextColor:(UIColor *)selectedTextColor
          unselectedTextColor:(UIColor *)unselectedTextColor
                    trackView:(UIView *)trackView
                 selectorView:(UIView *)selectorView;

- (instancetype)initWithItems:(NSArray<NSString *> *)items
                         font:(UIFont *)font
            selectedTextColor:(UIColor *)selectedTextColor
          unselectedTextColor:(UIColor *)unselectedTextColor
              trackImageColor:(UIColor *)trackImageColor
           selectorImageColor:(UIColor *)selectorImageColor;

- (instancetype)initWithItems:(NSArray<NSString *> *)items
                         font:(UIFont *)font
            selectedTextColor:(UIColor *)selectedTextColor
          unselectedTextColor:(UIColor *)unselectedTextColor
                   trackImage:(UIImage *)trackImage
                selectorImage:(UIImage *)selectorImage
              trackImageColor:(UIColor *)trackImageColor
           selectorImageColor:(UIColor *)selectorImageColor;

@end
