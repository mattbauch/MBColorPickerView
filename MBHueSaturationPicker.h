//
//  MBHueSaturationPicker.h
//
//  Copyright (c) 2013 Matthias Bauch <dev@matthiasbauch.com>
//  This work is free. You can redistribute it and/or modify it under the
//  terms of the Do What The Fuck You Want To Public License, Version 2,
//  as published by Sam Hocevar. See the COPYING file for more details.

#import <UIKit/UIKit.h>

@class CAShapeLayer;

@interface MBHueSaturationPicker : UIControl
@property (readonly, nonatomic) CAShapeLayer *crossHairLayer;

@property (readonly, nonatomic) CGFloat hue;
@property (readonly, nonatomic) CGFloat saturation;

- (void)setHue:(CGFloat)hue animated:(BOOL)animated;
- (void)setSaturation:(CGFloat)saturation animated:(BOOL)animated;
- (void)setBrightness:(CGFloat)brightness animated:(BOOL)animated;
- (void)saveBackgroundImageForSize:(CGSize)size;

@end
