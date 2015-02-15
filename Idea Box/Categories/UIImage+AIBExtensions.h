//
// Created by Thomas Dimson on 1/1/14.
// Copyright (c) 2014 Thomas Dimson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (AIBExtensions)
- (UIImage *)stretchableImageWithCapInsets:(UIEdgeInsets)capInsets;

- (UIImage *)imageFlippedHorizontal;

- (UIImage *)imageMaskWithColor:(UIColor *)maskColor;

+ (UIImage *)launchImage;
@end