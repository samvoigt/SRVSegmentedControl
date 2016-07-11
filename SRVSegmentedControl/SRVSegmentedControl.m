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

@property (nonatomic, strong) UIView *selectorMaskView;

@property (nonatomic, strong) NSLayoutConstraint *selectorOffsetConstraint;

@property (nonatomic) BOOL shouldUpdateSelectorLocationAfterLayoutPass;

@end

@implementation SRVSegmentedControl

@synthesize trackImage = _trackImage;
@synthesize selectorImage = _selectorImage;

- (instancetype)initWithItems:(NSArray<NSString *> *)items
                         font:(UIFont *)font
            selectedTextColor:(UIColor *)selectedTextColor
          unselectedTextColor:(UIColor *)unselectedTextColor
                   trackImage:(UIImage *)trackImage
                selectorImage:(UIImage *)selectorImage
              trackImageColor:(UIColor *)trackImageColor
           selectorImageColor:(UIColor *)selectorImageColor {
    
    self = [super init];
    
    if (self) {
        _items = items;
        _font = font;
        _selectedTextColor = selectedTextColor;
        _unselectedTextColor = unselectedTextColor;
        _trackImage = trackImage;
        _selectorImage = selectorImage;
        _trackImageColor = trackImageColor;
        _selectorImageColor = selectorImageColor;
        [self reflowViews];
    }
    return self;
}

- (instancetype)initWithItems:(NSArray<NSString *> *)items
                         font:(UIFont *)font
            selectedTextColor:(UIColor *)selectedTextColor
          unselectedTextColor:(UIColor *)unselectedTextColor
              trackImageColor:(UIColor *)trackImageColor
           selectorImageColor:(UIColor *)selectorImageColor {
    
    return [self initWithItems:items
                          font:font
             selectedTextColor:selectedTextColor
           unselectedTextColor:unselectedTextColor
                    trackImage:[SRVSegmentedControl defaultTrackImage]
                 selectorImage:[SRVSegmentedControl defaultSelectorImage]
               trackImageColor:trackImageColor
            selectorImageColor:selectorImageColor];
}

- (instancetype)initWithItems:(NSArray<NSString *> *)items
                         font:(UIFont *)font
            selectedTextColor:(UIColor *)selectedTextColor
          unselectedTextColor:(UIColor *)unselectedTextColor
                    trackView:(UIView *)trackView
                 selectorView:(UIView *)selectorView {
    
    self = [super init];
    if (self) {
        _items = items;
        _font = font;
        _selectedTextColor = selectedTextColor;
        _unselectedTextColor = unselectedTextColor;
        _trackView = trackView;
        _selectorView = selectorView;
        [self reflowViews];
    }
    return self;
}


- (instancetype)initWithItems:(NSArray<NSString *> *)items {
    
    self = [super init];
    if (self) {
        _items = items;
        [self reflowViews];
    }
    return self;
}

- (void)setupGestureRecognizer {
    for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
        [self removeGestureRecognizer:recognizer];
    }
    
    for (UIGestureRecognizer *recognizer in self.selectorView.gestureRecognizers) {
        [self.selectorView removeGestureRecognizer:recognizer];
    }
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)]];
    [self.selectorView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)]];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.selectorMaskView.frame = self.selectorView.frame;
    
    if (self.shouldUpdateSelectorLocationAfterLayoutPass && !CGRectEqualToRect(self.frame, CGRectZero)) {
        self.shouldUpdateSelectorLocationAfterLayoutPass = NO;
        [self setSelectedSegmentIndex:self.selectedSegmentIndex animated:NO];
    }
}

- (void)reflowViews {
    
    [self removeAllSubviews];
    
    self.selectedSegmentIndex = 0;
    
    [self setupTrackView];
    
    [self setupLabels];
    
    [self setupSelectorView];
    
    [self bringSubviewToFront:self.selectedLabelsContainterView];
    
    [self setupGestureRecognizer];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    [self setupSelectorMask];
}

- (void)setupTrackView {
    
    if (!self.trackView) {
        if (!self.trackImage) {
            _trackImage = [SRVSegmentedControl defaultTrackImage];
        }
        _trackView = [[UIImageView alloc] initWithImage:self.trackImage];
    }
    
    self.trackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self insertSubview:self.trackView atIndex:0];
    
    NSDictionary *views = @{@"track" : self.trackView};
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
        
        itemSelectedLabel.textColor = self.selectedTextColor ? : [UIColor whiteColor];
        itemUnselectedLabel.textColor = self.unselectedTextColor ? : [UIColor blackColor];
        
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
    [view addConstraint:[NSLayoutConstraint constraintWithItem:firstLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    
    for (int i = 0; i < labels.count - 1; i++) {
        UILabel *label1 = labels[i];
        UILabel *label2 = labels[i+1];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:label2 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:label1 attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:label2 attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:label2 attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:label2 attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    }
    
    UILabel *lastLabel = [labels lastObject];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:lastLabel attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
}

- (void)setupSelectorView {
    
    if (!self.selectorView) {
        if (!self.selectorImage) {
            _selectorImage = [SRVSegmentedControl defaultSelectorImage];
        }
        _selectorView = [[UIImageView alloc] initWithImage:self.selectorImage];
    }
    
    self.selectorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self insertSubview:self.selectorView atIndex:1];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[selector]-0-|" options:0 metrics:nil views:@{@"selector" : self.selectorView}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:(1.0 / self.items.count) constant:0]];
    
    self.selectorOffsetConstraint = [NSLayoutConstraint constraintWithItem:self.selectorView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    [self addConstraint:self.selectorOffsetConstraint];
    
    self.selectorView.userInteractionEnabled = YES;
}

- (void)setupSelectorMask {
    
    if ([self.selectorView isKindOfClass:[UIImageView class]]) {
        self.selectorMaskView = [[UIImageView alloc] initWithFrame:self.selectorView.frame];
        ((UIImageView *)self.selectorMaskView).image = self.selectorImage;
    }
    else {
        self.selectorMaskView = [[UIView alloc] initWithFrame:self.selectorView.frame];
        self.selectorMaskView.backgroundColor = [UIColor blackColor];
    }
    
    self.selectedLabelsContainterView.maskView = self.selectorMaskView;
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
        newOffset = MIN(newOffset, self.frame.size.width - self.selectorView.frame.size.width);
        
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
    
    CGFloat centerOfSelectorOffset = self.selectorOffsetConstraint.constant + (self.selectorView.frame.size.width / 2);
    [self moveSelectorToSegmentForXOffset:centerOfSelectorOffset];
}

- (void)updateSelectorLocation {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - Setters and Getters

- (void)setItems:(NSArray<NSString *> *)items {
    
    if (_items == items) {
        return;
    }
    
    _items = items;
    [self reflowViews];
}

- (void)setTrackView:(UIView *)trackView {
    
    if (_trackView == trackView) {
        return;
    }
    
    if (_trackView) {
        [_trackView removeFromSuperview];
    }
    _trackView = trackView;
    [self reflowViews];
}

- (void)setSelectorView:(UIView *)selectorView {
    
    if (_selectorView == selectorView) {
        return;
    }
    
    _selectorView = selectorView;
    
    [self reflowViews];
}

- (void)setTrackImage:(UIImage *)trackImage {
    
    if (_trackImage == trackImage) {
        return;
    }
    
    _trackImage = trackImage;
    [self reflowViews];
}

- (void)setTrackImageColor:(UIColor *)trackImageColor{
    _trackImageColor = trackImageColor;
    
    if (!self.trackImage) {
        return;
    }
    else if (self.trackImage.renderingMode != UIImageRenderingModeAlwaysTemplate) {
        self.trackImage = [self.trackImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    self.trackView.tintColor = trackImageColor;
}

- (void)setSelectorImage:(UIImage *)selectorImage {
    
    if (_selectorImage == selectorImage) {
        return;
    }
    
    _selectorImage = selectorImage;
    [self reflowViews];
}

- (void)setSelectorImageColor:(UIColor *)selectorImageColor {
    _selectorImageColor = selectorImageColor;
    
    if (!self.selectorImage) {
        return;
    }
    else if (self.selectorImage.renderingMode != UIImageRenderingModeAlwaysTemplate) {
        self.selectorImage = [self.selectorImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    self.selectorView.tintColor = selectorImageColor;
}

- (void)setFont:(UIFont *)font {
    
    _font = font;
    [self reflowViews];
}

- (void)setSelectedTextColor:(UIColor *)selectedTextColor {
    
    _selectedTextColor = selectedTextColor;
    [self reflowViews];
}

- (void)setUnselectedTextColor:(UIColor *)unselectedTextColor {
    
    _unselectedTextColor = unselectedTextColor;
    [self reflowViews];
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex {
    [self setSelectedSegmentIndex:selectedSegmentIndex animated:NO];
}

- (void)setSelectedSegmentIndex:(NSInteger)segmentIndex animated:(BOOL)animated {
    
    if (segmentIndex < 0 || segmentIndex > self.items.count) {
        return;
    }
    
    _selectedSegmentIndex = segmentIndex;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    if (CGRectEqualToRect(self.frame, CGRectZero)) {
        self.shouldUpdateSelectorLocationAfterLayoutPass = YES;
        return;
    }
    
    CGFloat endOffset = (segmentIndex * self.selectorView.frame.size.width);
    
    self.selectorOffsetConstraint.constant = endOffset;
    [self setNeedsUpdateConstraints];
    
    if (animated) {
        CGRect endFrameForMask = CGRectMake(endOffset, 0, self.selectorMaskView.frame.size.width, self.selectorMaskView.frame.size.height);
        [UIView animateWithDuration:0.3 animations:^{
            
            [self layoutIfNeeded];
            self.selectorMaskView.frame = endFrameForMask;
            
        }];
    }
    else {
        [self updateSelectorLocation];
    }
}

#pragma mark - Cocoapod Resource Bundle Handling

+ (UIImage *)defaultTrackImage {
    
    return [[[SRVSegmentedControl imageInPodsBundleNamed:@"TrackImage"] resizableImageWithCapInsets:self.edgeInsetsForDefaultImages] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

+ (UIImage *)defaultSelectorImage {
    
    return [[[SRVSegmentedControl imageInPodsBundleNamed:@"SelectorImage"] resizableImageWithCapInsets:self.edgeInsetsForDefaultImages] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

+ (UIImage *)imageInPodsBundleNamed:(NSString *)imageName {
    
    static NSBundle *podBundle = nil;
    if (!podBundle) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSURL *podBundleURL = [bundle URLForResource:@"SRVSegmentedControl" withExtension:@"bundle"];
        podBundle = [NSBundle bundleWithURL:podBundleURL];
    }
    
    return [UIImage imageNamed:imageName inBundle:podBundle compatibleWithTraitCollection:nil];
}

+ (UIEdgeInsets)edgeInsetsForDefaultImages {
    return UIEdgeInsetsMake(20, 20, 20, 20);
}

@end
