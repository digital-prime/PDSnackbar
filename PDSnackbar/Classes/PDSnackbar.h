//
//  PDSnackbar.h
//  snackbar
//
//  Created by Stanislav Proskurnin on 10/02/16.
//  Copyright © 2016 Prime Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SnackbarDurationTime) {
    SnackBarDurationTimeLong = 5,
    SnackBarDurationTimeShort = 2
};

typedef void (^ActionBlock)();

@interface PDSnackbar : UIControl

@property (strong, nonatomic) UILabel *messageLabel;

- (instancetype)initSnackBarWithContainerView:(__kindof UIView *)containerView
                                      message:(NSString *)message
                                     duration:(SnackbarDurationTime)durationTime;

- (instancetype)initIndicatorSnackBarWithContainerView:(__kindof UIView *)containerView
                                               message:(NSString *)message
                                              duration:(SnackbarDurationTime)durationTime;

- (instancetype)initActionSnackBarWithContainerView:(__kindof UIView *)containerView
                                            message:(NSString *)message
                                        actionTitle:(NSString *)actionTitle
                                        actionBlock:(ActionBlock)actionBlock
                                           duration:(SnackbarDurationTime)durationTime;

- (void)show;

- (void)hide;

- (void)multiline;

@end