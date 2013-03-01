//
//  MBColorPicker.m
//
//  Copyright (c) 2013 Matthias Bauch <dev@matthiasbauch.com>
//  This work is free. You can redistribute it and/or modify it under the
//  terms of the Do What The Fuck You Want To Public License, Version 2,
//  as published by Sam Hocevar. See the COPYING file for more details.

#import "MBColorPicker.h"
#import "MBHueSaturationPicker.h"
#import "MBBrightnessPicker.h"
#import "MBColorSwatchList.h"

@interface MBColorPicker () <MBSwatchListDelegate>

@end

@implementation MBColorPicker

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        CGFloat hsPickerInset = 6.0f;
        
        CGFloat width = frame.size.width - hsPickerInset - hsPickerInset;
        CGFloat brightnessPickerWidth = 50.0f;
        CGFloat hsPickerWidth = MIN(width - 8 - brightnessPickerWidth, frame.size.height-(2*hsPickerInset));
        
        _hsPicker = [[MBHueSaturationPicker alloc] initWithFrame:CGRectMake(hsPickerInset, hsPickerInset, hsPickerWidth, hsPickerWidth)];
        [_hsPicker addTarget:self action:@selector(hsPickerDidChangeValue:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_hsPicker];
        
        _brightnessPicker = [[MBBrightnessPicker alloc] initWithFrame:CGRectMake(hsPickerInset+hsPickerWidth+8, hsPickerInset, brightnessPickerWidth, hsPickerWidth)];
        [_brightnessPicker addTarget:self action:@selector(brightnessPickerDidChangeValue:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_brightnessPicker];
        
        _swatchList = [[MBColorSwatchList alloc] initWithFrame:CGRectMake(hsPickerInset, hsPickerInset + hsPickerWidth + 8, width, 40)];
        _swatchList.delegate = self;
        [self addSubview:_swatchList];
    }
    return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    _hsPicker.backgroundColor = self.backgroundColor;
    _brightnessPicker.backgroundColor = self.backgroundColor;
    _swatchList.backgroundColor = self.backgroundColor;
}

- (void)setHue:(CGFloat)hue animated:(BOOL)animated {
    _hue = hue;
    [self.hsPicker setHue:hue animated:animated];
    [self.brightnessPicker setHue:hue animated:animated];
}

- (void)setHue:(CGFloat)hue {
    [self setHue:hue animated:NO];
}

- (void)setSaturation:(CGFloat)saturation animated:(BOOL)animated {
    _saturation = saturation;
    [self.hsPicker setSaturation:saturation animated:animated];
    [self.brightnessPicker setSaturation:saturation animated:animated];
}

- (void)setSaturation:(CGFloat)saturation {
    [self setSaturation:saturation animated:NO];
}

- (void)setBrightness:(CGFloat)brightness animated:(BOOL)animated {
    _brightness = brightness;
    [self.hsPicker setBrightness:brightness animated:animated];
    [self.brightnessPicker setBrightness:brightness animated:animated];
}

- (void)setBrightness:(CGFloat)brightness {
    [self setBrightness:brightness animated:NO];
}

- (void)setColor:(UIColor *)color animated:(BOOL)animated {
    CGFloat h,s,b,w;
    if ([color getHue:&h saturation:&s brightness:&b alpha:NULL]) {
        [self setHue:h animated:animated];
        [self setSaturation:s animated:animated];
        [self setBrightness:b animated:animated];
    }
    else if ([color getWhite:&w alpha:NULL]) {
        [self setSaturation:0 animated:animated];
        [self setBrightness:w animated:animated];
    }
    _color = color;
}

- (void)setColor:(UIColor *)color {
    [self setColor:color animated:NO];
}


- (void)changeColorAndSendValueChangedAction {
    _color = [UIColor colorWithHue:_hsPicker.hue saturation:_hsPicker.saturation brightness:_brightnessPicker.brightness alpha:1];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (IBAction)hsPickerDidChangeValue:(MBHueSaturationPicker *)sender {
    [_brightnessPicker setHue:sender.hue animated:NO];
    [_brightnessPicker setSaturation:sender.saturation animated:NO];

    _hue = sender.hue;
    _saturation = sender.saturation;
    [self changeColorAndSendValueChangedAction];
}

- (IBAction)brightnessPickerDidChangeValue:(MBBrightnessPicker *)sender {
    [_hsPicker setBrightness:sender.brightness animated:NO];
    
    _brightness = sender.brightness;
    [self changeColorAndSendValueChangedAction];
}

#pragma mark - MBSwatchListDelegate

- (void)swatchList:(MBColorSwatchList *)swatchList didSelectColorAtIndex:(NSInteger)index {
    UIColor *color = swatchList.colors[index];
    [self setColor:color animated:YES];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (UIColor *)swatchList:(MBColorSwatchList *)swatchList colorToSetForSwatchAtIndex:(NSInteger)index {
    return _color;
}

@end
