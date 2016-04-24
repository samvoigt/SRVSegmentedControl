//
//  SRVSegmentedControl.m
//  SRVSegmentedControlDemo
//
//  Created by Sam Voigt on 4/22/16.
//  Copyright © 2016 Integer Wars. All rights reserved.
//

#import "SRVSegmentedControl.h"

@interface SRVSegmentedControl ()

@property (nonatomic, strong) NSArray<UILabel *> *unselectedLabels;
@property (nonatomic, strong) NSArray<UILabel *> *selectedLabels;
@property (nonatomic, strong) UIView *selectedLabelsContainterView;

@property (nonatomic, strong) UIImageView *trackImageView;
@property (nonatomic, strong) UIImageView *selectorImageView;
@property (nonatomic, strong) UIImageView *selectorImageMaskView;

@property (nonatomic, strong) NSLayoutConstraint *selectorOffsetConstraint;

@end

@implementation SRVSegmentedControl

@synthesize trackImage = _trackImage;

- (instancetype)initWithItems:(NSArray<NSString *> *)items {
    
    self = [super init];
    if (self) {
        
        
        [self reflowViews];
    }
    
    return self;
}

- (void)reflowViews {
    
    [self removeAllSubviews];
    
    [self setupTrack];
    [self setupLabels];
    [self setupSelector];
    [self setupGestureRecognizers];
    
    [self bringSubviewToFront:self.selectedLabelsContainterView];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    [self setupSelectorMask];
    
}

- (void)setupTrack {
    
    self.trackImageView = [[UIImageView alloc] initWithImage:self.trackImage];
    
    self.trackImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:self.trackImageView];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[track]-0-|" options:0 metrics:nil views:@{@"track" : self.trackImageView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[track]-0-|" options:0 metrics:nil views:@{@"track" : self.trackImageView}]];
}

- (void)setupLabels {
    
    NSMutableArray<UILabel *> *unselectedLabels = [NSMutableArray new];
    NSMutableArray<UILabel *> *selectedLabels = [NSMutableArray new];
    
    for (NSString *itemName in self.items) {
        UILabel *itemUnselectedLabel = [UILabel new];
        UILabel *itemSelectedLabel = [UILabel new];
        itemUnselectedLabel.translatesAutoresizingMaskIntoConstraints =
        itemSelectedLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        itemUnselectedLabel.text =
        itemSelectedLabel.text = itemName;
        
        itemUnselectedLabel.textAlignment =
        itemSelectedLabel.textAlignment = NSTextAlignmentCenter;
        
        itemUnselectedLabel.adjustsFontSizeToFitWidth =
        itemSelectedLabel.adjustsFontSizeToFitWidth = YES;
        
        itemUnselectedLabel.minimumScaleFactor =
        itemSelectedLabel.minimumScaleFactor = 0.5;
        
        itemSelectedLabel.textColor = [UIColor whiteColor];
        
        //itemLabel.backgroundColor = [self randomColor];
        
        [unselectedLabels addObject:itemUnselectedLabel];
        [selectedLabels addObject:itemSelectedLabel];
    }
    
    self.unselectedLabels = unselectedLabels;
    self.selectedLabels = selectedLabels;
    
    [self setupSelectedLabelsContainerView];
    
    [self setupLabelConstraintsForLabels:self.unselectedLabels inView:self];
    [self setupLabelConstraintsForLabels:self.selectedLabels inView:self.selectedLabelsContainterView];
    
}

- (void)setupSelectedLabelsContainerView {
    
    self.selectedLabelsContainterView = [UIView new];
    self.selectedLabelsContainterView.translatesAutoresizingMaskIntoConstraints = NO;
    self.selectedLabelsContainterView.userInteractionEnabled = NO;
    
    self.selectedLabelsContainterView.backgroundColor = [self randomColor];
    
    [self addSubview:self.selectedLabelsContainterView];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[container]-0-|" options:0 metrics:nil views:@{@"container" : self.selectedLabelsContainterView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[container]-0-|" options:0 metrics:nil views:@{@"container" : self.selectedLabelsContainterView}]];
}

- (void)setupLabelConstraintsForLabels:(NSArray<UILabel *> *)labels inView:(UIView *)view {
    
    if (labels.count < 1) {
        return;
    }
    
    for (UILabel *label in labels) {
        [view addSubview:label];
    }
    
    UILabel *firstLabel = labels[0];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[label]-0-|" options:0 metrics:nil views:@{@"label" : firstLabel}]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:firstLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeading multiplier:1 constant:self.minimumLabelBuffer]];
    
    for (int i = 0; i < labels.count - 1; i++) {
        UILabel *label1 = labels[i];
        UILabel *label2 = labels[i+1];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:label2 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:label1 attribute:NSLayoutAttributeRight multiplier:1 constant:self.minimumLabelBuffer]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:label2 attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:label2 attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:label2 attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    }
    
    UILabel *lastLabel = [labels lastObject];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:lastLabel attribute:NSLayoutAttributeTrailing multiplier:1 constant:self.minimumLabelBuffer]];
    
}

- (void)setupSelector {
    
    self.selectorImageView = [[UIImageView alloc] initWithImage:self.selectorImage];
    
    self.selectorImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:self.selectorImageView];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[selector]-0-|" options:0 metrics:nil views:@{@"selector" : self.selectorImageView}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:(1.0 / self.items.count) constant:0]];
    
    self.selectorOffsetConstraint = [NSLayoutConstraint constraintWithItem:self.selectorImageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    [self addConstraint:self.selectorOffsetConstraint];
    
    self.selectorImageView.userInteractionEnabled = YES;
}

- (void)setupSelectorMask {
    self.selectorImageMaskView = [[UIImageView alloc] initWithFrame:self.selectorImageView.frame];
    self.selectorImageMaskView.image = self.selectorImage;
    
    self.selectedLabelsContainterView.maskView = self.selectorImageMaskView;
}

- (void)updateMaskViewLocation {
    self.selectorImageMaskView.frame = self.selectorImageView.frame;
}

- (void)setupGestureRecognizers {
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)]];
    [self.selectorImageView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)]];
}

- (UIColor *)randomColor {
    NSArray *colors = @[[UIColor redColor], [UIColor blueColor], [UIColor greenColor], [UIColor yellowColor], [UIColor purpleColor]];
    
    return colors[arc4random() % colors.count];
}

- (void)removeAllSubviews {
    
    NSArray *subviews = [self.subviews copy];
    for (UIView *subview in subviews) {
        [subview removeFromSuperview];
    }
}

#pragma mark - Gesture Recognizer Handlers

- (void)handleTap:(UITapGestureRecognizer *)sender {
    NSLog(@"tap");
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    
    NSLog(@"translation: %@", NSStringFromCGPoint([sender translationInView:self]));
    
    self.selectorOffsetConstraint.constant = [sender translationInView:self].x;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [self updateMaskViewLocation];
}

#pragma mark - Setters and Getters

- (void)setItems:(NSArray<NSString *> *)items {
    _items = items;
    [self reflowViews];
}

- (UIImage *)trackImage {
    
    if (!_trackImage) {
        _trackImage = [[self imageForResourceNamed:@"BackgroundImage.png"] resizableImageWithCapInsets:self.edgeInsetsForDefaultImages];
    }
    
    return _trackImage;
}

- (void)setTrackImage:(UIImage *)trackImage {
    _trackImage = trackImage;
}

- (UIImage *)selectorImage {
    
    if (!_selectorImage) {
        _selectorImage = [[self imageForResourceNamed:@"SelectorImage.png"] resizableImageWithCapInsets:self.edgeInsetsForDefaultImages];
    }
    
    return _selectorImage;
}

#pragma mark - Cocoapod Resource Bundle Handling

- (UIImage *)imageForResourceNamed:(NSString *)fullResourceName {
    
    NSString *resolutionExtension = @"";
    CGFloat scale = [UIScreen mainScreen].scale;
    if (scale > 1.9 && scale < 2.1) {
        resolutionExtension = @"@2x";
    }
    else if (scale > 2.9 && scale < 3.1) {
        resolutionExtension = @"@3x";
    }
    
    NSString *extension = [fullResourceName pathExtension];
    NSString *resourceName = [[fullResourceName stringByDeletingPathExtension] stringByAppendingString:resolutionExtension];

    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:resourceName withExtension:extension];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    return [[UIImage alloc] initWithData:imageData scale:scale];
}

- (UIEdgeInsets)edgeInsetsForDefaultImages {
    return UIEdgeInsetsMake(20, 20, 20, 20);
}

@end
