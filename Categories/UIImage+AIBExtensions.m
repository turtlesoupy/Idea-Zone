//
// Created by Thomas Dimson on 1/1/14.
// Copyright (c) 2014 Thomas Dimson. All rights reserved.
//

#import "UIImage+AIBExtensions.h"


@implementation UIImage (AIBExtensions)

- (UIImage *)stretchableImageWithCapInsets:(UIEdgeInsets)capInsets {
    return [self resizableImageWithCapInsets:capInsets
                                resizingMode:UIImageResizingModeStretch];
}

- (UIImage *)imageFlippedHorizontal {
    return [UIImage imageWithCGImage:self.CGImage
                               scale:self.scale
                         orientation:UIImageOrientationUpMirrored];
}

- (UIImage *)imageMaskWithColor:(UIColor *)maskColor
{
    CGRect imageRect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);

    UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, self.scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGContextScaleCTM(ctx, 1.0f, -1.0f);
    CGContextTranslateCTM(ctx, 0.0f, -(imageRect.size.height));

    CGContextClipToMask(ctx, imageRect, self.CGImage);
    CGContextSetFillColorWithColor(ctx, maskColor.CGColor);
    CGContextFillRect(ctx, imageRect);

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}
@end