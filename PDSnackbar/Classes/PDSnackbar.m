//
//  PDSnackbar.m
//  snackbar
//
//  Created by Stanislav Proskurnin on 10/02/16.
//  Copyright © 2016 Prime Digital. All rights reserved.
//

#import "PDSnackbar.h"
#import <PureLayout/PureLayout.h>

static CGFloat const PDSnackbarAnimationDuration = 0.2;

NSString *const PDSnackbarMessageName = @"PDSnackbarMessageName";
NSString *const PDSnackbarTapBlockName = @"PDSnackbarTapBlockName";
NSString *const PDSnackbarActionButtonTitleName = @"PDSnackbarActionButtonTitleName";
NSString *const PDSnackbarActionButtonTapBlockName = @"PDSnackbarActionButtonTapBlockName";
NSString *const PDSnackbarDurationTimeName = @"PDSnackbarDurationTimeName";
NSString *const PDSnackbarActivityIndicatorEnabledName = @"PDSnackbarActivityIndicatorEnabledName";

@interface PDSnackbar ()

@property (nonnull, nonatomic, strong) UILabel *messageLabel;
@property (nonnull, nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic) PDSnackbarDurationTime durationTime;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy) PDSnackbarActionBlock actionBlock;
@property (nonatomic, copy) PDSnackbarTouchBlock touchBlock;
@end

@implementation PDSnackbar

#pragma mark init


- (nonnull instancetype)initSnackBarWithMessage:(nonnull NSString *)message
                                       duration:(PDSnackbarDurationTime)durationTime {
    return [self initWithConfiguration:@{
            PDSnackbarMessageName : message,
            PDSnackbarDurationTimeName : @(durationTime)
    }];
}

- (nonnull instancetype)initSnackBarWithMessage:(nonnull NSString *)message
                                       duration:(PDSnackbarDurationTime)durationTime
                                     touchBlock:(nonnull PDSnackbarTouchBlock)touchBlock {
    return [self initWithConfiguration:@{
            PDSnackbarMessageName : message,
            PDSnackbarDurationTimeName : @(durationTime),
            PDSnackbarTapBlockName : [touchBlock copy]
    }];
}

- (nonnull instancetype)initIndicatorSnackBarWithMessage:(nonnull NSString *)message
                                                duration:(PDSnackbarDurationTime)durationTime {
    return [self initWithConfiguration:@{
            PDSnackbarMessageName : message,
            PDSnackbarActivityIndicatorEnabledName : @YES,
            PDSnackbarDurationTimeName : @(durationTime),
    }];
}

- (nonnull instancetype)initActionSnackBarWithMessage:(nonnull NSString *)message
                                          actionTitle:(nonnull NSString *)actionTitle
                                          actionBlock:(nonnull PDSnackbarActionBlock)actionBlock {
    return [self initWithConfiguration:@{
            PDSnackbarMessageName : message,
            PDSnackbarActionButtonTitleName : actionTitle,
            PDSnackbarActionButtonTapBlockName : [actionBlock copy]
    }];
}

- (nonnull instancetype)initWithConfiguration:(nonnull NSDictionary<NSString *, id> *)configuration {
    PDSnackbarOptions *pdOptions = [PDSnackbarOptions sharedInstance];
    CGRect frame = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? pdOptions.frameIPad : pdOptions.frameIPhone;
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;

        [self createMessageLabel];
        _messageLabel.text = configuration[PDSnackbarMessageName];
        _messageLabel.textColor = pdOptions.textColor;
        _messageLabel.font = pdOptions.textFont;

        _transparency = 0.95;
        self.backgroundColor = [UIColor whiteColor];

        self.layer.shadowRadius = 3.f;
        self.layer.shadowOpacity = 0.5f;
        self.layer.shadowColor = [UIColor grayColor].CGColor;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.masksToBounds = NO;

        self.alpha = 0.f;

        self.durationTime = (PDSnackbarDurationTime) ((NSNumber *) configuration[PDSnackbarDurationTimeName]).unsignedIntegerValue;

        if (configuration[PDSnackbarActionButtonTitleName]) {
            [self createActionButton];
            [self.actionButton setTitle:configuration[PDSnackbarActionButtonTitleName] forState:UIControlStateNormal];
            [self.actionButton addTarget:self action:@selector(actionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            self.actionButton.titleLabel.font = [PDSnackbarOptions sharedInstance].buttonTitleFont;
            self.actionBlock = [configuration[PDSnackbarActionButtonTapBlockName] copy];
        }

        if (configuration[PDSnackbarTapBlockName]) {
            PDSnackbarTouchBlock touchBlock = [configuration[PDSnackbarTapBlockName] copy];
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                   action:@selector(touchBlockTapped:)];
            tapGestureRecognizer.numberOfTapsRequired = 1;
            [self addGestureRecognizer:tapGestureRecognizer];
            self.userInteractionEnabled = YES;
            _touchBlock = touchBlock;
        }

        if (configuration[PDSnackbarActivityIndicatorEnabledName]) {
            [self createIndicatorView];
        }
    }
    return self;
}

#pragma mark - Dealloc

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark Custom Setters

- (void)setMultiline:(BOOL)multiline {
    self.messageLabel.numberOfLines = multiline ? 0 : 1;
}

- (void)setActionTitleColor:(UIColor *)actionTitleColor {
    [self.actionButton setTitleColor:actionTitleColor
                            forState:UIControlStateNormal];
}

- (void)setMessageLabelTextColor:(UIColor *)messageLabelTextColor {
    self.messageLabel.textColor = messageLabelTextColor;
}

- (void)setMessage:(NSString *)message {
    self.messageLabel.text = message;
}

- (void)setMessageFont:(UIFont *)messageFont {
    self.messageLabel.font = messageFont;
}

- (void)setActionButtonFont:(UIFont *)actionButtonFont {
    self.actionButton.titleLabel.font = actionButtonFont;
}

#pragma mark - Create Content

- (void)createMessageLabel {
    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.numberOfLines = 1;
    [self addSubview:self.messageLabel];

    [self.messageLabel autoAlignAxis:ALAxisHorizontal
                    toSameAxisOfView:self];
    [self.messageLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft
                                        withInset:20.f];
    [self.messageLabel autoPinEdgeToSuperviewEdge:ALEdgeTop
                                        withInset:10.f];
    [self.messageLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom
                                        withInset:10.f];
    [self.messageLabel autoPinEdgeToSuperviewEdge:ALEdgeRight
                                        withInset:25.f];
}

- (void)createIndicatorView {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGAffineTransform transform = CGAffineTransformMakeScale(1.25f, 1.25f);
    self.activityIndicator.transform = transform;

    [self addSubview:self.activityIndicator];

    [self.activityIndicator autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.messageLabel];
    [self.activityIndicator autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:25.f];

    [self.messageLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:55.f];
    [self.messageLabel autoPinEdge:ALEdgeRight
                            toEdge:ALEdgeLeft
                            ofView:self.activityIndicator
                        withOffset:10];
}

- (void)createActionButton {
    self.actionButton = [[UIButton alloc] init];
    [self.actionButton setTitleColor:[PDSnackbarOptions sharedInstance].buttonTitleHighlighted
                            forState:UIControlStateHighlighted];
    [self.actionButton setTitleColor:[PDSnackbarOptions sharedInstance].buttonTitleColor
                            forState:UIControlStateNormal];
    [self addSubview:self.actionButton];

    [self.actionButton autoAlignAxis:ALAxisHorizontal
                    toSameAxisOfView:self.messageLabel];
    [self.actionButton autoPinEdgeToSuperviewEdge:ALEdgeRight
                                        withInset:10.f];
    [self.actionButton autoPinEdge:ALEdgeLeft
                            toEdge:ALEdgeRight
                            ofView:self.messageLabel
                        withOffset:10.f];
    [self.messageLabel autoPinEdgeToSuperviewEdge:ALEdgeRight
                                        withInset:120.f];
}

#pragma mark - Action

- (IBAction)actionButtonTapped:(id)sender {
    if (self.actionBlock) {
        self.actionBlock();
    }
    [self hide];
}

- (IBAction)touchBlockTapped:(id)sender {
    if (self.touchBlock) {
        self.touchBlock();
    }
    [self hide];
}

- (void)show {
    for (UIView *view in [[PDSnackbarOptions sharedInstance] containerView].subviews) {
        if ([view isKindOfClass:PDSnackbar.class]) {
            return;
        }
    }

    [[PDSnackbarOptions sharedInstance].containerView addSubview:self];
    [self addSwipeGestures];
    [self.activityIndicator startAnimating];
    [UIView animateWithDuration:PDSnackbarAnimationDuration
                     animations:^{
                         self.alpha = self.transparency;
                         CGRect newFrame = self.frame;
                         newFrame.origin.y = self.frame.origin.y - self.frame.size.height;
                         self.frame = newFrame;
                     }];

    if (self.actionBlock || self.activityIndicator) {
        return;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(self.duration > 0) ? self.duration : (NSTimeInterval) self.durationTime
                                                  target:self
                                                selector:@selector(hide)
                                                userInfo:nil
                                                 repeats:NO];
}

- (void)hide {
    [self.timer invalidate];
    self.timer = nil;
    [UIView animateWithDuration:PDSnackbarAnimationDuration
                     animations:^{
                         self.alpha = 0.f;
                         CGRect newFrame = self.frame;
                         newFrame.origin.y = [[PDSnackbarOptions sharedInstance] containerView].frame.size.height;
                         self.frame = newFrame;
                     }
                     completion:^(BOOL finished) {
                         self.hidden = YES;
                         [self removeFromSuperview];
                         [self.activityIndicator stopAnimating];
                     }];
}

#pragma mark - UISwipeGestureRecognizer

- (void)addSwipeGestures {
    UISwipeGestureRecognizer *downSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                                     action:@selector(downSwipe:)];
    downSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self addGestureRecognizer:downSwipeGestureRecognizer];
}

- (IBAction)downSwipe:(UISwipeGestureRecognizer *)swipeGestureRecognizer {
    [self hide];
}

@end