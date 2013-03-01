//
//  MBColorSwatchList.h
//
//  Copyright (c) 2013 Matthias Bauch <dev@matthiasbauch.com>
//  This work is free. You can redistribute it and/or modify it under the
//  terms of the Do What The Fuck You Want To Public License, Version 2,
//  as published by Sam Hocevar. See the COPYING file for more details.

#import <UIKit/UIKit.h>

@class MBColorSwatchList;

@protocol MBSwatchListDelegate <NSObject>
- (UIColor *)swatchList:(MBColorSwatchList *)swatchList colorToSetForSwatchAtIndex:(NSInteger)index;
- (void)swatchList:(MBColorSwatchList *)swatchList didSelectColorAtIndex:(NSInteger)index;
@end

@interface MBColorSwatchList : UIView
@property (weak, nonatomic) id <MBSwatchListDelegate> delegate;

@property (assign, nonatomic) NSInteger rows;
@property (assign, nonatomic) NSInteger columns;

@property (strong, nonatomic) NSArray *colors;
@end
