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
    
    self = [self initWithItems:items font:font
             selectedTextColor:selectedTextColor
           unselectedTextColor:unselectedTextColor
                     trackView:[[UIImageView alloc] initWithImage:trackImage]
                  selectorView:[[UIImageView alloc] initWithImage:selectorImage]];
    
    if (self) {
        self.trackImage = trackImage;
        self.selectorImage = selectorImage;
        self.trackImageColor = trackImageColor;
        self.selectorImageColor = selectorImageColor;
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
        self.items = items;
        self.font = font;
        self.selectedTextColor = selectedTextColor;
        self.unselectedTextColor = unselectedTextColor;
        self.trackView = trackView;
        self.selectorView = selectorView;
        [self reflowViews];
    }
    return self;
}


- (instancetype)initWithItems:(NSArray<NSString *> *)items {
    
    self = [super init];
    if (self) {
        self.items = items;
        [self reflowViews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.selectorMaskView.frame = self.selectorView.frame;
}

- (void)reflowViews {
    
    [self removeAllSubviews];
    
    self.selectedSegmentIndex = 0;
    [self loadTrackViewIfNeeded];
    
    [self loadTrackViewIfNeeded];
    [self setupTrackView];
    
    [self setupLabels];
    
    [self loadSelectorViewIfNeeded];
    [self setupSelectorView];
    
    [self setupGestureRecognizers];
    
    [self bringSubviewToFront:self.selectedLabelsContainterView];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    [self setupSelectorMask];
}

- (void)loadTrackViewIfNeeded {

    if (!self.trackView) {
        if (!self.trackImage) {
            _trackImage = [SRVSegmentedControl defaultTrackImage];
        }
        _trackView = [[UIImageView alloc] initWithImage:self.trackImage];
    }
}

- (void)setupTrackView {
    
    if (self.trackView) {
        [self.trackView removeFromSuperview];
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

- (void)loadSelectorViewIfNeeded {
    
    if (!self.selectorView) {
        if (!self.selectorImage) {
            _selectorImage = [SRVSegmentedControl defaultSelectorImage];
        }
        _selectorView = [[UIImageView alloc] initWithImage:self.selectorImage];
    }
}

- (void)setupSelectorView {
    
    if (self.selectorView) {
        [self.selectorView removeFromSuperview];
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

- (void)setupGestureRecognizers {
    
    for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
        [self removeGestureRecognizer:recognizer];
    }
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)]];
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
    self.selectorMaskView.frame = self.selectorView.frame;
}

#pragma mark - Setters and Getters

- (void)setItems:(NSArray<NSString *> *)items {
    _items = items;
    [self reflowViews];
}

- (void)setTrackView:(UIView *)trackView {
    
    if (_trackView) {
        [_trackView removeFromSuperview];
    }
    _trackView = trackView;
    [self setupTrackView];
}

- (void)setSelectorView:(UIView *)selectorView {
    
    if (_selectorView == selectorView) {
        return;
    }
    else if (_selectorView) {
        [_selectorView removeFromSuperview];
    }
    
    _selectorView = selectorView;
    [self setupSelectorView];
    [_selectorView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)]];
    [self setupSelectorMask];
}

- (void)setTrackImage:(UIImage *)trackImage {
    
    _trackImage = trackImage;
    if ([self.trackView isKindOfClass:[UIImageView class]]){
        ((UIImageView *)self.trackView).image = trackImage;
    }
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
    _selectorImage = selectorImage;
   
    if ([self.selectorView isKindOfClass:[UIImageView class]]){
        ((UIImageView *)self.selectorView).image = selectorImage;
        [self setupSelectorMask];
    }
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
    for (UILabel *label in self.unselectedLabels) {
        label.font = font;
    }
    for (UILabel *label in self.selectedLabels) {
        label.font = font;
    }
}

- (void)setSelectedTextColor:(UIColor *)selectedTextColor {

    _selectedTextColor = selectedTextColor;
    for (UILabel *label in self.selectedLabels) {
        label.textColor = selectedTextColor;
    }
}

- (void)setUnselectedTextColor:(UIColor *)unselectedTextColor {
    
    _unselectedTextColor = unselectedTextColor;
    for (UILabel *label in self.unselectedLabels) {
        label.textColor = unselectedTextColor;
    }
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex {
    [self setSelectedSegmentIndex:selectedSegmentIndex animated:NO];
}

- (void)setSelectedSegmentIndex:(NSInteger)segmentIndex animated:(BOOL)animated {
    
    if (segmentIndex < 0 || segmentIndex > self.items.count) {
        return;
    }
    
    CGFloat endOffset = (segmentIndex * self.selectorView.frame.size.width);
    
    self.selectorOffsetConstraint.constant = endOffset;
    [self setNeedsUpdateConstraints];
    
    _selectedSegmentIndex = segmentIndex;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
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
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"SRVSegmentedControl" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    return [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
}

+ (UIEdgeInsets)edgeInsetsForDefaultImages {
    return UIEdgeInsetsMake(20, 20, 20, 20);
}

@end
