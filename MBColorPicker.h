//
//  MBColorPicker.h
//
//  Copyright (c) 2013 Matthias Bauch <dev@matthiasbauch.com>
//  This work is free. You can redistribute it and/or modify it under the
//  terms of the Do What The Fuck You Want To Public License, Version 2,
//  as published by Sam Hocevar. See the COPYING file for more details.

#import <UIKit/UIKit.h>

@class MBHueSaturationPicker;
@class MBBrightnessPicker;
@class MBColorSwatchList;

@interface MBColorPicker : UIControl
@property (strong, nonatomic) MBHueSaturationPicker *hsPicker;
@property (strong, nonatomic) MBBrightnessPicker *brightnessPicker;
@property (strong, nonatomic) MBColorSwatchList *swatchList;


@property (assign, nonatomic) CGFloat hue;
@property (assign, nonatomic) CGFloat saturation;
@property (assign, nonatomic) CGFloat brightness;
@property (strong, nonatomic) UIColor *color;

- (void)setHue:(CGFloat)hue animated:(BOOL)animated;
- (void)setSaturation:(CGFloat)saturation animated:(BOOL)animated;
- (void)setBrightness:(CGFloat)brightness animated:(BOOL)animated;
- (void)setColor:(UIColor *)color animated:(BOOL)animated;

@end
