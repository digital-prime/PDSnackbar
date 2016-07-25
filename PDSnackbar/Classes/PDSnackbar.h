//
//  PDSnackbar.h
//  snackbar
//
//  Created by Stanislav Proskurnin on 10/02/16.
//  Copyright © 2016 Prime Digital. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PDSnackbarOptions.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PDSnackbarDurationTime) {
    PDSnackBarDurationTimeLong = 5,
    PDSnackBarDurationTimeShort = 2
};

typedef void (^PDSnackbarActionBlock)();

typedef void (^PDSnackbarTouchBlock)();

FOUNDATION_EXTERN NSString *const PDSnackbarMessageName;
FOUNDATION_EXTERN NSString *const PDSnackbarTapBlockName;
FOUNDATION_EXTERN NSString *const PDSnackbarActionButtonTitleName;
FOUNDATION_EXTERN NSString *const PDSnackbarActionButtonTapBlockName;
FOUNDATION_EXTERN NSString *const PDSnackbarDurationTimeName;
FOUNDATION_EXTERN NSString *const PDSnackbarActivityIndicatorEnabledName;

@interface PDSnackbar : UIControl

@property (assign, nonatomic) CGFloat transparency;
@property (assign, nonatomic) NSTimeInterval duration;

- (nonnull instancetype)initWithConfiguration:(nonnull NSDictionary<NSString *, id> *)configuration;

- (nonnull instancetype)initSnackBarWithMessage:(nonnull NSString *)message
                                       duration:(PDSnackbarDurationTime)durationTime;

- (nonnull instancetype)initSnackBarWithMessage:(nonnull NSString *)message
                                       duration:(PDSnackbarDurationTime)durationTime
                                     touchBlock:(nonnull PDSnackbarTouchBlock)touchBlock;

- (nonnull instancetype)initIndicatorSnackBarWithMessage:(nonnull NSString *)message
                                                duration:(PDSnackbarDurationTime)durationTime;

- (nonnull instancetype)initActionSnackBarWithMessage:(nonnull NSString *)message
                                          actionTitle:(nonnull NSString *)actionTitle
                                          actionBlock:(nonnull PDSnackbarActionBlock)actionBlock;

- (void)setActionTitleColor:(nonnull UIColor *)actionTitleColor;

- (void)setMultiline:(BOOL)multiline;

- (void)setMessageLabelTextColor:(nonnull UIColor *)messageLabelTextColor;

- (void)setMessage:(nonnull NSString *)message;

- (void)setMessageFont:(nonnull UIFont *)messageFont;

- (void)setActionButtonFont:(nonnull UIFont *)actionButtonFont;

- (void)show;

- (void)hide;

@end

NS_ASSUME_NONNULL_END