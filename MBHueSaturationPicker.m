//
//  MBHueSaturationPicker.m
//
//  Copyright (c) 2013 Matthias Bauch <dev@matthiasbauch.com>
//  This work is free. You can redistribute it and/or modify it under the
//  terms of the Do What The Fuck You Want To Public License, Version 2,
//  as published by Sam Hocevar. See the COPYING file for more details.

#import "MBHueSaturationPicker.h"
#import <QuartzCore/QuartzCore.h>

@interface MBHueSaturationPicker ()
@property (strong, nonatomic) CAShapeLayer *crossHairLayer;
@property (strong, nonatomic) CAShapeLayer *borderLayer;
@end

@implementation MBHueSaturationPicker {
    CGFloat _brightness;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat lineWidth = 1.f;
        
        _borderLayer = [CAShapeLayer layer];
        _borderLayer.frame = self.bounds;
        _borderLayer.path = CGPathCreateWithEllipseInRect(self.bounds, 0);
        _borderLayer.lineWidth = lineWidth;
        _borderLayer.strokeColor = [UIColor whiteColor].CGColor;
        _borderLayer.fillColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:_borderLayer];
        
        CGFloat crossHairSize = 10;
        _crossHairLayer = [CAShapeLayer layer];
        _crossHairLayer.frame = CGRectMake(40, 40, crossHairSize, crossHairSize);
        _crossHairLayer.path = CGPathCreateWithEllipseInRect(CGRectMake(0, 0, crossHairSize, crossHairSize), 0);
        _crossHairLayer.strokeColor = [UIColor whiteColor].CGColor;
        _crossHairLayer.lineWidth = lineWidth;
        _crossHairLayer.fillColor = [UIColor clearColor].CGColor;
        _crossHairLayer.backgroundColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:_crossHairLayer];
    }
    return self;
}

- (void)setHue:(CGFloat)hue animated:(BOOL)animated {
    _hue = hue;
    [self configureCrossHairLayerAnimated:animated];
}

- (void)setSaturation:(CGFloat)saturation animated:(BOOL)animated {
    _saturation = saturation;
    [self configureCrossHairLayerAnimated:animated];
}

- (void)setBrightness:(CGFloat)brightness animated:(BOOL)animated {
    _brightness = brightness;
    [self configureCrossHairLayerAnimated:animated];
}

- (void)configureCrossHairLayerAnimated:(BOOL)animated {
    CGPoint center = CGPointMake(floorf(self.bounds.size.width/2.0f), floorf(self.bounds.size.height/2.0f));
    CGFloat radius = floorf(self.bounds.size.width/2.0f);
    
    [CATransaction begin];
    if (!animated) {
        [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
    }
    
    CGFloat angle = 2*M_PI * (1-_hue);
    CGFloat saturationRadius = radius * _saturation;
    CGPoint point = CGPointMake(center.x + saturationRadius * cosf(angle), center.y + saturationRadius * sinf(angle));
    
    _crossHairLayer.position = CGPointMake(point.x, point.y);
    _crossHairLayer.fillColor = [UIColor colorWithHue:_hue saturation:_saturation brightness:_brightness alpha:1].CGColor;
    
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
    CGPoint center = CGPointMake(floorf(self.bounds.size.width/2.0f), floorf(self.bounds.size.height/2.0f));
    CGFloat radius = floorf(self.bounds.size.width/2.0f);
    
    CGFloat dx = point.x - center.x;
    CGFloat dy = point.y - center.y;
    
    CGFloat touchRadius = sqrtf(powf(dx, 2)+powf(dy, 2));
    if (touchRadius > radius) {
        _saturation = 1.f;
    }
    else {
        _saturation = touchRadius / radius;
    }
    
    CGFloat angleRad = atan2f(dx, dy);
    CGFloat angleDeg = (angleRad * (180.0f/M_PI) - 90);
    if (angleDeg < 0.f) {
        angleDeg += 360.f;
    }
    _hue = angleDeg / 360.0f;

    [self configureCrossHairLayerAnimated:NO];

    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPoint center = CGPointMake(floorf(self.bounds.size.width/2.0f), floorf(self.bounds.size.height/2.0f));
    CGFloat radius = floorf(self.bounds.size.width/2.0f) + 5;           // draw a bit outside of our bouds. we will clip that back to our bounds.
                                                                        // this avoids artifacts at the edge
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextSaveGState(context);
    CGContextAddEllipseInRect(context, self.bounds);
    CGContextClip(context);
    
    NSInteger numberOfSegments = 3600;
    for (CGFloat i = 0; i < numberOfSegments; i++) {
        UIColor *color = [UIColor colorWithHue:1-i/(float)numberOfSegments saturation:1 brightness:1 alpha:1];
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        
        CGFloat segmentAngle = 2*M_PI / (float)numberOfSegments;
        CGPoint start = center;
        CGPoint end = CGPointMake(center.x + radius * cosf(i * segmentAngle), center.y + radius * sinf(i * segmentAngle));
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, 0, start.x, start.y);
        
        CGFloat offsetFromMid = 0.5f*(M_PI/180);
        CGPoint end1 = CGPointMake(center.x + radius * cosf(i * segmentAngle-offsetFromMid), center.y + radius * sinf(i * segmentAngle-offsetFromMid));
        CGPoint end2 = CGPointMake(center.x + radius * cosf(i * segmentAngle+offsetFromMid), center.y + radius * sinf(i * segmentAngle+offsetFromMid));
        CGPathAddLineToPoint(path, 0, end1.x, end1.y);
        CGPathAddLineToPoint(path, 0, end2.x, end2.y);
        CGPathAddLineToPoint(path, 0, start.x, start.y);
        
        CGContextSaveGState(context);
        CGContextAddPath(context, path);
        CGContextClip(context);
        
        NSArray *colors = @[(__bridge id)[UIColor colorWithWhite:1 alpha:1].CGColor, (__bridge id)color.CGColor];
        CGGradientRef gradient = CGGradientCreateWithColors(rgbColorSpace, (__bridge CFArrayRef)colors, NULL);
        CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation|kCGGradientDrawsAfterEndLocation);
        
        CGContextRestoreGState(context);
    }
    
    CGContextRestoreGState(context);
    
    CGContextSetStrokeColorWithColor(context, self.backgroundColor.CGColor);
    CGContextSetLineWidth(context, 1);
    CGContextStrokeEllipseInRect(context, CGRectMake(center.x - radius, center.y - radius, radius * 2, radius * 2));
}

@end
