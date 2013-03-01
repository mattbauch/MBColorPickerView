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

@property (assign, nonatomic) CGFloat hue;
@property (assign, nonatomic) CGFloat saturation;

- (void)setBrightness:(CGFloat)brightness;
@end