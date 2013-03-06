//
//  MBColorSwatchList.m
//
//  Copyright (c) 2013 Matthias Bauch <dev@matthiasbauch.com>
//  This work is free. You can redistribute it and/or modify it under the
//  terms of the Do What The Fuck You Want To Public License, Version 2,
//  as published by Sam Hocevar. See the COPYING file for more details.

#import "MBColorSwatchList.h"
#import <QuartzCore/QuartzCore.h>

static NSString * MBUDColorPickerSavedColors = @"MBColorPickerSavedColors";

@interface MBColorSwatchList ()
@property (strong, nonatomic) NSArray *layers;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;
@end

@implementation MBColorSwatchList

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:MBUDColorPickerSavedColors];
        if (data) {
            NSArray *colors = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            if ([colors isKindOfClass:[NSArray class]]) {
                _colors = colors;
            }
        }
        [self fillColorsArrayIfNecessary];
        
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        [self addGestureRecognizer:_tapGestureRecognizer];
        
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
        [self addGestureRecognizer:_longPressGestureRecognizer];
    }
    return self;
}

- (void)setColumns:(NSInteger)columns {
    _columns = columns;
    [self fillColorsArrayIfNecessary];
    [_layers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    _layers = nil;
    [self setNeedsLayout];
}

- (void)setRows:(NSInteger)rows {
    _rows = rows;
    [self fillColorsArrayIfNecessary];
    [_layers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    _layers = nil;
    [self setNeedsLayout];
}

- (void)setColors:(NSArray *)colors {
    _colors = [colors copy];
    [self fillColorsArrayIfNecessary];
    [_layers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    _layers = nil;
    [self setNeedsLayout];
}

- (void)fillColorsArrayIfNecessary {
    if ([_colors count] < (_rows * _columns)) {
        NSInteger difference = (_rows * _columns) - [_colors count];
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:difference];
        for (NSInteger i = 0; i < difference; i++) {
            [arr addObject:[UIColor whiteColor]];
        }
        if (_colors) {
            _colors = [_colors arrayByAddingObjectsFromArray:arr];
        }
        else {
            _colors = arr;
        }
    }
}

- (NSInteger)indexForLocation:(CGPoint)location {
    for (NSInteger i = 0; i < [_layers count]; i++) {
        CALayer *layer = _layers[i];
        if (CGRectContainsPoint(layer.frame, location)) {
            return i;
        }
    }
    return NSNotFound;
}

- (IBAction)tapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint location = [sender locationInView:sender.view];
        NSInteger index = [self indexForLocation:location];
        if (index != NSNotFound) {
            [self.delegate swatchList:self didSelectColorAtIndex:index];
        }
    }
}

- (IBAction)longPressGesture:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        CGPoint location = [sender locationInView:sender.view];
        NSInteger index = [self indexForLocation:location];
        if (index != NSNotFound) {
            UIColor *newColor = [self.delegate swatchList:self colorToSetForSwatchAtIndex:index];
            if (!newColor) {
                newColor = [UIColor whiteColor];
            }
            NSMutableArray *colorCopy = [_colors mutableCopy];
            [colorCopy replaceObjectAtIndex:index withObject:newColor];
            _colors = colorCopy;
            
            CAShapeLayer *shapeLayer = _layers[index];
            shapeLayer.fillColor = newColor.CGColor;
            
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_colors];
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:MBUDColorPickerSavedColors];
        }
    }
}

- (void)layoutSubviews {
    if (_columns <= 0) {
        _columns = floorf(self.bounds.size.width/44.0f);
    }
    if (_rows <= 0) {
        _rows = floorf(self.bounds.size.height/44.0f);
    }

    if (!_layers) {
        CGFloat lineWidth = 2.0f;
        CGFloat xDistance = 0;
        if (_columns > 1) {
            xDistance = floorf(((self.bounds.size.width-lineWidth) - (_columns * 40)) / (_columns - 1));
        }
        CGFloat yDistance = 0;
        if (_rows > 1) {
            yDistance = floorf(((self.bounds.size.height-lineWidth) - (_rows * 40)) / (_rows - 1));
        }
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:_rows * _columns];
        for (NSInteger r = 0; r < _rows; r++) {
            for (NSInteger c = 0; c < _columns; c++) {
                CAShapeLayer *swatch = [CAShapeLayer layer];
                swatch.frame = CGRectMake(c * (40 + xDistance) + (lineWidth/2), r * (40 + yDistance), 40, 40);
                swatch.path = CGPathCreateWithRect(CGRectMake(0, 0, 40, 40), 0);
                swatch.lineWidth = lineWidth;
                swatch.strokeColor = [UIColor whiteColor].CGColor;
                [self.layer addSublayer:swatch];
                [array addObject:swatch];
            }
        }
        _layers = array;
    }
    
    for (NSInteger i = 0; i < [_layers count]; i++) {
        CAShapeLayer *shapeLayer = _layers[i];
        UIColor *color = [UIColor colorWithWhite:1-(i/(CGFloat)[_layers count]) alpha:1];
        if (i < [_colors count]) {
            color = _colors[i];
        }
        shapeLayer.fillColor = color.CGColor;
    }
    [super layoutSubviews];
}

@end
