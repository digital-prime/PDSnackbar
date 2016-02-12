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


@property (strong, nonatomic) UIColor        *actionTitleColor;
@property (strong, nonatomic) UIColor        *messageLabelTextColor;
@property (strong, nonatomic) NSString       *message;
@property (strong, nonatomic) UIFont         *actionButtonFont;
@property (strong, nonatomic) UIFont         *messageFont;
@property (assign, nonatomic) CGFloat        transparency;
@property (assign, nonatomic) BOOL           multiline;
@property (assign, nonatomic) NSTimeInterval duration;

- (instancetype)initSnackBarWithMessage:(NSString *)message
                               duration:(SnackbarDurationTime)durationTime;

- (instancetype)initIndicatorSnackBarWithMessage:(NSString *)message
                                        duration:(SnackbarDurationTime)durationTime;

- (instancetype)initActionSnackBarWithMessage:(NSString *)message
                                  actionTitle:(NSString *)actionTitle
                                  actionBlock:(ActionBlock)actionBlock
                                     duration:(SnackbarDurationTime)durationTime;

- (void)show;

- (void)hide;

@end