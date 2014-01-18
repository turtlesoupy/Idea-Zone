//
// Created by Thomas Dimson on 12/25/13.
// Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import "AIBAnimation.h"

@implementation AIBAnimation {

}

+ (void)shakeAnimation:(CALayer*)layer {
    CGPoint pos = layer.position;
    static int numberOfShakes = 3;
    static CGFloat vigourOfShake = 0.055;
    CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];

    CGMutablePathRef shakePath = CGPathCreateMutable();
    CGPathMoveToPoint(shakePath, NULL, pos.x, pos.y);
    int index;
    for (index = 0; index < numberOfShakes; ++index)
    {
        CGPathAddLineToPoint(shakePath, NULL, pos.x - layer.frame.size.width * vigourOfShake, pos.y);
        CGPathAddLineToPoint(shakePath, NULL, pos.x + layer.frame.size.width * vigourOfShake, pos.y);
    }
    CGPathAddLineToPoint(shakePath, NULL, pos.x, pos.y);
    CGPathCloseSubpath(shakePath);
    shakeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    shakeAnimation.duration = 0.65;
    shakeAnimation.path = shakePath;
    [layer addAnimation:shakeAnimation forKey:nil];

}

@end