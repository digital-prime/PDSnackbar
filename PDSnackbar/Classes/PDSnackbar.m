//
//  PDSnackbar.m
//  snackbar
//
//  Created by Stanislav Proskurnin on 10/02/16.
//  Copyright © 2016 Prime Digital. All rights reserved.
//

#import "PDSnackbar.h"
#import <PureLayout/PureLayout.h>

#define SNACKBAR_TEXT_COLOR [UIColor colorWithRed:72.f / 255.0f green:68.f / 255.0f blue:62.f / 255.0f alpha:255.f / 255.0f]
#define SNACKBAR_BUTTON_COLOR [UIColor colorWithRed:252.f / 255.0f green:117.f / 255.0f blue:31.f / 255.0f alpha:255.f / 255.0f]

static CGFloat const PDSnackbarHeight = 80.f;
static CGFloat const PDSnackbarAnimationDuration = 0.2;

static NSString * const PDSnackbarSFMediumFontName  = @"SFUIDisplay-Medium";
static NSString * const PDSnackbarSFRegularFontName = @"SFUIDisplay-Regular";

@implementation PDSnackbar {
    UIView                  *_containerView;
    UILabel                 *_messageLabel;
    UIButton                *_actionButton;
    UIActivityIndicatorView *_activityIndicator;
    SnackbarDurationTime    _durationTime;
    NSTimer                 *_timer;
    ActionBlock             _actionBlock;
}

@synthesize multiline = _multiline;

#pragma mark init

- (instancetype)initSnackBarWithMessage:(NSString *)message
                               duration:(SnackbarDurationTime)durationTime {
    self = [super init];
    if (self) {
        _containerView = [self getContainerView];
        _durationTime = durationTime;

        [self createMessageLabel];
        _messageLabel.text = message;
        _messageLabel.textColor = SNACKBAR_TEXT_COLOR;
        _messageLabel.font = [UIFont fontWithName:PDSnackbarSFRegularFontName size:16.f];

        _transparency = 0.95;
        self.backgroundColor = [UIColor whiteColor];

        self.layer.shadowRadius  = 3.f;
        self.layer.shadowOpacity = 0.5f;
        self.layer.shadowColor   = [UIColor grayColor].CGColor;
        self.layer.shadowOffset  = CGSizeZero;
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.masksToBounds = NO;

        self.alpha = 0.f;
    }
    return self;
}

- (instancetype)initActionSnackBarWithMessage:(NSString *)message
                                  actionTitle:(NSString *)actionTitle
                                  actionBlock:(ActionBlock)actionBlock
                                     duration:(SnackbarDurationTime)durationTime {
    self = [self initSnackBarWithMessage:message
                                duration:durationTime];
    if (self) {
        [self createActionButton];
        [_actionButton setTitle:actionTitle
                       forState:UIControlStateNormal];
        [_actionButton addTarget:self
                          action:@selector(actionButtonTapped:)
                forControlEvents:UIControlEventTouchUpInside];
        _actionButton.titleLabel.font = [UIFont fontWithName:PDSnackbarSFMediumFontName size:16.f];
        _actionBlock = actionBlock;
    }
    return self;
}

- (instancetype)initIndicatorSnackBarWithMessage:(NSString *)message
                                        duration:(SnackbarDurationTime)durationTime {
    self = [self initSnackBarWithMessage:message
                                duration:durationTime];
    if (self) {
        [self createIndicatorView];
    }
    return self;
}

#pragma mark - Dealloc

- (void)dealloc {
    [_timer invalidate];
    _timer = nil;
}

#pragma mark Custom Setters

- (void)setMultiline:(BOOL)multiline {
    _multiline = multiline;
    _messageLabel.numberOfLines = multiline ? 0 : 1;
}

- (void)setActionTitleColor:(UIColor *)actionTitleColor {
    _actionTitleColor = actionTitleColor;
    [_actionButton setTitleColor:actionTitleColor
                        forState:UIControlStateNormal];
}

- (void)setMessageLabelTextColor:(UIColor *)messageLabelTextColor {
    _messageLabelTextColor = messageLabelTextColor;
    _messageLabel.textColor = messageLabelTextColor;
}

- (void)setMessage:(NSString *)message {
    _message = message;
    _messageLabel.text = message;
}

- (void)setMessageFont:(UIFont *)messageFont {
    _messageFont = messageFont;
    _messageLabel.font = messageFont;
}

- (void)setActionButtonFont:(UIFont *)actionButtonFont {
    _actionButtonFont = actionButtonFont;
    _actionButton.titleLabel.font = actionButtonFont;
}

#pragma mark - Create Content

- (void)createMessageLabel {
    self.frame = CGRectMake(0, CGRectGetMaxY(_containerView.frame),
            CGRectGetWidth(_containerView.frame), PDSnackbarHeight);

    _messageLabel = [[UILabel alloc] init];
    _messageLabel.numberOfLines = 1;
    [self addSubview:_messageLabel];

    [_messageLabel autoAlignAxis:ALAxisHorizontal
                toSameAxisOfView:self];
    [_messageLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft
                                    withInset:20.f];
    [_messageLabel autoPinEdgeToSuperviewEdge:ALEdgeTop
                                    withInset:10.f];
    [_messageLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom
                                    withInset:10.f];
    [_messageLabel autoPinEdgeToSuperviewEdge:ALEdgeRight
                                    withInset:25.f];
}

- (void)createIndicatorView {
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGAffineTransform transform = CGAffineTransformMakeScale(1.25f, 1.25f);
    _activityIndicator.transform = transform;

    [self addSubview:_activityIndicator];

    [_activityIndicator autoAlignAxis:ALAxisHorizontal
                     toSameAxisOfView:_messageLabel];
    [_activityIndicator autoPinEdgeToSuperviewEdge:ALEdgeRight
                                         withInset:25.f];
    [_messageLabel autoPinEdgeToSuperviewEdge:ALEdgeRight
                                    withInset:55.f];
    [_messageLabel autoPinEdge:ALEdgeRight
                        toEdge:ALEdgeLeft
                        ofView:_activityIndicator
                    withOffset:10];
}

- (void)createActionButton {
    _actionButton = [[UIButton alloc] init];
    [_actionButton setTitleColor:SNACKBAR_TEXT_COLOR
                        forState:UIControlStateHighlighted];
    [_actionButton setTitleColor:SNACKBAR_BUTTON_COLOR
                        forState:UIControlStateNormal];
    [self addSubview:_actionButton];

    [_actionButton autoAlignAxis:ALAxisHorizontal
                toSameAxisOfView:_messageLabel];
    [_actionButton autoPinEdgeToSuperviewEdge:ALEdgeRight
                                    withInset:10.f];
    [_actionButton autoPinEdge:ALEdgeLeft
                        toEdge:ALEdgeRight
                        ofView:_messageLabel
                    withOffset:10.f];
    [_messageLabel autoPinEdgeToSuperviewEdge:ALEdgeRight
                                    withInset:120.f];
}

#pragma mark - Action

- (void)actionButtonTapped:(id)sender {
    if (_actionBlock) {
        _actionBlock();
    }
    [self hide];
}

- (void)show {
    for (UIView *view in _containerView.subviews) {
        if ([view isKindOfClass:PDSnackbar.class]) {
            return;
        }
    }
    
    [_containerView addSubview:self];
    [self addSwipeGestures];
    [_activityIndicator startAnimating];
    [UIView animateWithDuration:PDSnackbarAnimationDuration
                     animations:^{
                         self.alpha = self.transparency;
                         CGRect newFrame = self.frame;
                         newFrame.origin.y = self.frame.origin.y - PDSnackbarHeight;
                         self.frame = newFrame;
                     }];
    
    if (_actionBlock || _activityIndicator) {
        return;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:self.duration > 0 ?: _durationTime
                                              target:self
                                            selector:@selector(hide)
                                            userInfo:nil
                                             repeats:NO];
}

- (void)hide {
    [_timer invalidate];
    _timer = nil;
    [UIView animateWithDuration:PDSnackbarAnimationDuration
                     animations:^{
                         self.alpha = 0.f;
                         CGRect newFrame = self.frame;
                         newFrame.origin.y = _containerView.frame.size.height;
                         self.frame = newFrame;
                     }
                     completion:^(BOOL finished) {
                         self.hidden = YES;
                         [self removeFromSuperview];
                         [_activityIndicator stopAnimating];
                     }];
}

#pragma mark - UISwipeGestureRecognizer

- (void)addSwipeGestures {
    UISwipeGestureRecognizer *downSwipeGestureRecognizer =
            [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(downSwipe:)];
    downSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self addGestureRecognizer:downSwipeGestureRecognizer];
}

- (void)downSwipe:(UISwipeGestureRecognizer *)swipeGestureRecognizer {
    [self hide];
}

#pragma mark - Container View

- (UIView *)getContainerView {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] <= 9.0) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        if (!window)
            window = [[UIApplication sharedApplication].windows objectAtIndex:0];
        return [window subviews].lastObject;
    } else {
        UIWindow *window =[[UIApplication sharedApplication] keyWindow];
        if (window == nil)
            window = [[[UIApplication sharedApplication] delegate] window];
        return window;
    }
}

@end