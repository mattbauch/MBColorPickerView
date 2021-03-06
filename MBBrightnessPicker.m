//
//  MBBrightnessPicker.m
//
//  Copyright (c) 2013 Matthias Bauch <dev@matthiasbauch.com>
//  This work is free. You can redistribute it and/or modify it under the
//  terms of the Do What The Fuck You Want To Public License, Version 2,
//  as published by Sam Hocevar. See the COPYING file for more details.

#import "MBBrightnessPicker.h"
#import <QuartzCore/QuartzCore.h>

@interface MBBrightnessPicker ()
@property (strong, nonatomic) CAShapeLayer *crossHairLayer;
@property (strong, nonatomic) CAShapeLayer *borderLayer;
@property (strong, nonatomic) CAGradientLayer *gradientLayer;
@end

@implementation MBBrightnessPicker {
    CGFloat _hue;
    CGFloat _saturation;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat lineWidth = 2.f;
        
        
        
        _gradientLayer = [CAGradientLayer layer];
        [self.layer addSublayer:_gradientLayer];
        
        _borderLayer = [CAShapeLayer layer];
        _borderLayer.lineWidth = lineWidth;
        _borderLayer.strokeColor = [UIColor whiteColor].CGColor;
        _borderLayer.fillColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:_borderLayer];
        
        
        _crossHairLayer = [CAShapeLayer layer];
        _crossHairLayer.strokeColor = [UIColor whiteColor].CGColor;
        _crossHairLayer.lineWidth = lineWidth;
        _crossHairLayer.fillColor = [UIColor clearColor].CGColor;
        _crossHairLayer.backgroundColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:_crossHairLayer];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat borderInset = 0;
    
    _gradientLayer.frame = self.bounds;
    _gradientLayer.colors = @[(__bridge id)[UIColor whiteColor].CGColor, (__bridge id)[UIColor blackColor].CGColor];

    _borderLayer.frame = CGRectInset(self.bounds, borderInset, borderInset);
    CGPathRef borderLinePath = CGPathCreateWithRect(CGRectMake(0, 0, self.bounds.size.width-(2*borderInset), self.bounds.size.height-(2*borderInset)), 0);
    _borderLayer.path = borderLinePath;
    CGPathRelease(borderLinePath);

    CGFloat crossHairSize = 6;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, 0, 0, 0);
    CGPathAddLineToPoint(path, 0, self.bounds.size.width, 0);
    CGPathMoveToPoint(path, 0, 0, crossHairSize);
    CGPathAddLineToPoint(path, 0, self.bounds.size.width, crossHairSize);
    _crossHairLayer.path = path;
    CGPathRelease(path);
    
    _crossHairLayer.frame = CGRectMake(0, 0, self.bounds.size.width, crossHairSize);

    [_crossHairLayer.sublayers[0] removeFromSuperlayer];
    CALayer *fillLayer = [CALayer layer];
    fillLayer.frame = CGRectMake(0, 1, self.bounds.size.width, crossHairSize-2);
    fillLayer.backgroundColor = [UIColor blackColor].CGColor;
    [_crossHairLayer addSublayer:fillLayer];
    
    [self configureLayers:NO];
}

- (void)setHue:(CGFloat)hue animated:(BOOL)animated {
    _hue = hue;
    [self configureLayers:animated];
    [self setNeedsDisplay];
}

- (void)setSaturation:(CGFloat)saturation animated:(BOOL)animated {
    _saturation = saturation;
    [self configureLayers:animated];
    [self setNeedsDisplay];
}

- (void)setBrightness:(CGFloat)brightness animated:(BOOL)animated {
    _brightness = brightness;
    [self configureLayers:animated];
    [self setNeedsDisplay];
}

- (void)configureLayers:(BOOL)animated {
    [CATransaction begin];
    if (!animated) {
        [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
    }
    CGFloat y = (1-_brightness) * self.bounds.size.height;
    CGPoint point = CGPointMake(0, y);
    
    _crossHairLayer.position = CGPointMake(_crossHairLayer.position.x, point.y);
    
    CALayer *fillLayer = _crossHairLayer.sublayers[0];
    fillLayer.backgroundColor = [UIColor colorWithHue:_hue saturation:_saturation brightness:_brightness alpha:1].CGColor;
    
    UIColor *color = [UIColor colorWithHue:_hue saturation:_saturation brightness:1 alpha:1];
    _gradientLayer.colors = @[(__bridge id)color.CGColor, (__bridge id)[UIColor blackColor].CGColor];
    
    if (_brightness < 0) {
        _crossHairLayer.hidden = YES;
    }
    else {
        _crossHairLayer.hidden = NO;
    }
    
    [CATransaction commit];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    [self sendActionForColorAtPoint:[touch locationInView:self]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    [self sendActionForColorAtPoint:[touch locationInView:self]];
}

- (void)sendActionForColorAtPoint:(CGPoint)point {
    CGFloat y = point.y;
    CGFloat brightness = 1 - (y / self.bounds.size.height);
    if (brightness >= 0 && brightness <= 1) {
        _brightness = brightness;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        [self configureLayers:NO];
    }
}

@end
