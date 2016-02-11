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

static CGFloat const PDSnackbarHeight = 100.f;
static CGFloat const PDSnackbarAnimationDuration = 0.2;

@implementation PDSnackbar {
    UIView                  *_containerView;
    UIButton                *_actionButton;
    UIActivityIndicatorView *_activityIndicator;
    SnackbarDurationTime    _durationTime;
    NSTimer                 *_timer;
    ActionBlock             _actionBlock;
}

#pragma mark init

- (instancetype)initSnackBarWithContainerView:(__kindof UIView *)containerView
                                      message:(NSString *)message
                                     duration:(SnackbarDurationTime)durationTime {
    self = [super init];
    if (self) {
        _containerView = containerView;
        _durationTime = durationTime;

        [self createMessageLabel];
        _messageLabel.text = message;
        _messageLabel.textColor = SNACKBAR_TEXT_COLOR;

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

- (instancetype)initActionSnackBarWithContainerView:(__kindof UIView *)containerView
                                            message:(NSString *)message
                                        actionTitle:(NSString *)actionTitle
                                        actionBlock:(ActionBlock)actionBlock
                                           duration:(SnackbarDurationTime)durationTime {
    self = [self initSnackBarWithContainerView:containerView
                                       message:message
                                      duration:durationTime];
    if (self) {
        [self createActionButton];
        [_actionButton setTitle:actionTitle
                       forState:UIControlStateNormal];
        [_actionButton addTarget:self
                          action:@selector(actionButtonTapped:)
                forControlEvents:UIControlEventTouchUpInside];
        _actionBlock = actionBlock;
    }
    return self;
}

- (void)actionButtonTapped:(id)sender {
    _actionBlock();
    [self hide];
}

- (instancetype)initIndicatorSnackBarWithContainerView:(__kindof UIView *)containerView
                                               message:(NSString *)message
                                              duration:(SnackbarDurationTime)durationTime {
    self = [self initSnackBarWithContainerView:containerView
                                       message:message
                                      duration:durationTime];
    if (self) {
        [self createIndicatorView];
    }
    return self;
}

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

- (void)multiline {
    self.messageLabel.numberOfLines = 0;
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
                         self.alpha = 0.8f;
                         CGRect newFrame = self.frame;
                         newFrame.origin.y = self.frame.origin.y - PDSnackbarHeight;
                         self.frame = newFrame;
                     }];

    if (_actionButton || _activityIndicator) {
        return;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:_durationTime
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

- (void)dealloc {
    [_timer invalidate];
    _timer = nil;
}

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

@end