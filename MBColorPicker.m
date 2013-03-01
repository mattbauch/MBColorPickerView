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

- (void)setColor:(UIColor *)color {
    CGFloat h,s,b,w;
    if ([color getHue:&h saturation:&s brightness:&b alpha:NULL]) {
        self.hue = h;
        self.saturation = s;
        self.brightness = b;
    }
    else if ([color getWhite:&w alpha:NULL]) {
        self.saturation = 0.0f;
        self.brightness = w;
    }
    _color = color;
}

- (void)setHue:(CGFloat)hue {
    _hue = hue;
    self.hsPicker.hue = hue;
    [self.brightnessPicker setHue:hue];
}

- (void)setSaturation:(CGFloat)saturation {
    _saturation = saturation;
    self.hsPicker.saturation = saturation;
    [self.brightnessPicker setSaturation:saturation];
}

- (void)setBrightness:(CGFloat)brightness {
    _brightness = brightness;
    [self.hsPicker setBrightness:brightness];
    self.brightnessPicker.brightness = brightness;
}

- (void)changeColorAndSendValueChangedAction {
    _color = [UIColor colorWithHue:_hsPicker.hue saturation:_hsPicker.saturation brightness:_brightnessPicker.brightness alpha:1];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (IBAction)hsPickerDidChangeValue:(MBHueSaturationPicker *)sender {
    [_brightnessPicker setHue:sender.hue];
    [_brightnessPicker setSaturation:sender.saturation];

    _hue = sender.hue;
    _saturation = sender.saturation;
    [self changeColorAndSendValueChangedAction];
}

- (IBAction)brightnessPickerDidChangeValue:(MBBrightnessPicker *)sender {
    [_hsPicker setBrightness:sender.brightness];
    
    _brightness = sender.brightness;
    [self changeColorAndSendValueChangedAction];
}

- (IBAction)swatchListDidChangeValue:(MBColorSwatchList *)sender {
    NSLog(@"Foo");
}


#pragma mark - MBSwatchListDelegate

- (void)swatchList:(MBColorSwatchList *)swatchList didSelectColorAtIndex:(NSInteger)index {
    UIColor *color = swatchList.colors[index];
    NSLog(@"COlor %@", color);
    self.color = color;
}

- (UIColor *)swatchList:(MBColorSwatchList *)swatchList colorToSetForSwatchAtIndex:(NSInteger)index {
    return _color;
}

@end
