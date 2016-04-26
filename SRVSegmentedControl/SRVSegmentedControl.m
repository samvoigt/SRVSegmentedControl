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
@synthesize selectorImage = _selectorImage;

- (instancetype)initWithItems:(NSArray<NSString *> *)items {
    
    self = [super init];
    if (self) {
        
        [self reflowViews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.selectorImageMaskView.frame = self.selectorImageView.frame;
}

- (void)reflowViews {
    
    [self removeAllSubviews];
    
    self.selectedSegmentIndex = 0;
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
    
    if (self.trackColor) {
        self.trackImageView = [[UIImageView alloc] initWithImage:[self.trackImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        self.trackImageView.tintColor = self.trackColor;
    }
    else {
        self.trackImageView = [[UIImageView alloc] initWithImage:self.trackImage];
    }
    
    self.trackImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.trackImageView];
    
    NSDictionary *views = @{@"track" : self.trackImageView};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[track]-0-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[track]-0-|" options:0 metrics:nil views:views]];
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
        
        itemSelectedLabel.textColor = self.selectedFontColor ? : [UIColor whiteColor];
        itemUnselectedLabel.textColor = self.unselectedFontColor ? : [UIColor blackColor];
        
        itemSelectedLabel.font =
        itemUnselectedLabel.font = self.font;
        
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
        
    [self addSubview:self.selectedLabelsContainterView];
    
    NSDictionary *views = @{@"container" : self.selectedLabelsContainterView};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[container]-0-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[container]-0-|" options:0 metrics:nil views:views]];
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
    
    if (self.selectorColor) {
        self.selectorImageView = [[UIImageView alloc] initWithImage:[self.selectorImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        self.selectorImageView.tintColor = self.selectorColor;
    }
    else {
        self.selectorImageView = [[UIImageView alloc] initWithImage:self.selectorImage];
    }
    
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

- (void)setupGestureRecognizers {
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)]];
    [self.selectorImageView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)]];
}

- (void)removeAllSubviews {
    
    NSArray *subviews = [self.subviews copy];
    for (UIView *subview in subviews) {
        [subview removeFromSuperview];
    }
}

#pragma mark - Gesture Recognizer Handlers

- (void)handleTap:(UITapGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self moveSelectorToSegmentForXOffset:[sender locationInView:self].x];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    
    static CGFloat startingOffset;
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        startingOffset = self.selectorOffsetConstraint.constant;
    }
    else if (sender.state == UIGestureRecognizerStateChanged) {
        
        CGFloat newOffset = [sender translationInView:self].x + startingOffset;
        newOffset = MAX(0, newOffset);
        newOffset = MIN(newOffset, self.frame.size.width - self.selectorImageView.frame.size.width);
        
        self.selectorOffsetConstraint.constant = newOffset;
        [self updateSelectorLocation];
    }
    else {
        [self snapToCurrentSegment];
    }
}

- (void)moveSelectorToSegmentForXOffset:(CGFloat)xOffset {
    
    NSInteger segment = (xOffset / self.frame.size.width) * self.items.count;
    [self setSelectedSegmentIndex:segment animated:YES];
}

- (void)snapToCurrentSegment {
    
    CGFloat centerOfSelectorOffset = self.selectorOffsetConstraint.constant + (self.selectorImageView.frame.size.width / 2);
    [self moveSelectorToSegmentForXOffset:centerOfSelectorOffset];
}

- (void)updateSelectorLocation {
    [self setNeedsLayout];
    [self layoutIfNeeded];
    self.selectorImageMaskView.frame = self.selectorImageView.frame;
}

#pragma mark - Setters and Getters

- (void)setItems:(NSArray<NSString *> *)items {
    _items = items;
    [self reflowViews];
}

- (UIImage *)trackImage {
    
    if (!_trackImage) {
        _trackImage = [[self imageInPodsBundleNamed:@"BackgroundImage"] resizableImageWithCapInsets:self.edgeInsetsForDefaultImages];
    }
    
    return _trackImage;
}

- (void)setTrackImage:(UIImage *)trackImage {
    _trackImage = trackImage;
    self.trackImageView.image = trackImage;
}

- (void)setTrackColor:(UIColor *)trackColor{
    _trackColor = trackColor;
    
    if (self.trackImage.renderingMode != UIImageRenderingModeAlwaysTemplate) {
        self.trackImage = [self.trackImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    self.trackImageView.tintColor = trackColor;
}

- (UIImage *)selectorImage {
    
    if (!_selectorImage) {
        _selectorImage = [[self imageInPodsBundleNamed:@"SelectedImage"] resizableImageWithCapInsets:self.edgeInsetsForDefaultImages];
    }
    
    return _selectorImage;
}

- (void)setSelectorImage:(UIImage *)selectorImage {
    _selectorImage = selectorImage;
    self.selectorImageView.image = selectorImage;
    [self setupSelectorMask];
}

- (void)setSelectorColor:(UIColor *)selectorColor {
    _selectorColor = selectorColor;
    
    if (self.selectorImage.renderingMode != UIImageRenderingModeAlwaysTemplate) {
        self.selectorImage = [self.selectorImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    self.selectorImageView.tintColor = selectorColor;
}

- (void)setFont:(UIFont *)font {
    
    _font = font;
    for (UILabel *label in self.unselectedLabels) {
        label.font = font;
    }
    for (UILabel *label in self.selectedLabels) {
        label.font = font;
    }
}

- (void)setSelectedFontColor:(UIColor *)selectedFontColor {

    _selectedFontColor = selectedFontColor;
    for (UILabel *label in self.selectedLabels) {
        label.textColor = selectedFontColor;
    }
}

- (void)setUnselectedFontColor:(UIColor *)unselectedFontColor {
    
    _unselectedFontColor = unselectedFontColor;
    for (UILabel *label in self.unselectedLabels) {
        label.textColor = unselectedFontColor;
    }
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex {
    [self setSelectedSegmentIndex:selectedSegmentIndex animated:NO];
}

- (void)setSelectedSegmentIndex:(NSInteger)segmentIndex animated:(BOOL)animated {
    
    if (segmentIndex < 0 || segmentIndex > self.items.count) {
        return;
    }
    
    CGFloat endOffset = (segmentIndex * self.selectorImageView.frame.size.width);
    
    self.selectorOffsetConstraint.constant = endOffset;
    [self setNeedsUpdateConstraints];
    
    if (animated) {
        CGRect endFrameForMask = CGRectMake(endOffset, 0, self.selectorImageMaskView.frame.size.width, self.selectorImageMaskView.frame.size.height);
        [UIView animateWithDuration:0.3 animations:^{
            
            [self layoutIfNeeded];
            self.selectorImageMaskView.frame = endFrameForMask;
            
        } completion:^(BOOL finished) {
            _selectedSegmentIndex = segmentIndex;
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }];
    }
    else {
        [self updateSelectorLocation];
        _selectedSegmentIndex = segmentIndex;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

#pragma mark - Cocoapod Resource Bundle Handling

- (UIImage *)imageInPodsBundleNamed:(NSString *)imageName {
    NSBundle *podBundle = [NSBundle bundleForClass:[self class]];
    return [UIImage imageNamed:imageName inBundle:podBundle compatibleWithTraitCollection:nil];
}

- (UIEdgeInsets)edgeInsetsForDefaultImages {
    return UIEdgeInsetsMake(20, 20, 20, 20);
}

@end
