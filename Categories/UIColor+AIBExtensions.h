//
// Created by Thomas Dimson on 12/30/13.
// Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIColor (AIBExtensions)
+ (UIColor *)colorWithHexString:(NSString *)hexString;

+ (NSArray *)ideaZonePalette;

- (NSString *)hexString;

- (UIColor *)blackOrWhiteContrastingColor;
@end

