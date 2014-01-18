//
// Created by Thomas Dimson on 12/30/13.
// Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import "UIColor+AIBExtensions.h"


@implementation UIColor (AIBExtensions)

+ (UIColor *)colorWithHexString:(NSString *)hexString
{
    unsigned int hex;
    [[NSScanner scannerWithString:hexString] scanHexInt:&hex];
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;

    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:1.0f];
}

- (NSString *)hexString {
    const CGFloat *components = CGColorGetComponents([self CGColor]);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    NSString *hexString=[NSString stringWithFormat:@"%02X%02X%02X", (int)(r * 255), (int)(g * 255), (int)(b * 255)];
    return hexString;
}

- (UIColor*)blackOrWhiteContrastingColor {
    const CGFloat *componentColors = CGColorGetComponents(self.CGColor);

    CGFloat darknessScore = (((componentColors[0]*255) * 299) + ((componentColors[1]*255) * 587) + ((componentColors[2]*255) * 114)) / 1000;

    if (darknessScore >= 125) {
        return [UIColor blackColor];
    }

    return [UIColor whiteColor];
}


+ (NSArray *) ideaZonePalette {
    return @[
            [UIColor colorWithHexString:@"FF3B30"], // R
            [UIColor colorWithHexString:@"FF9500"], // O
            [UIColor colorWithHexString:@"FFCC00"], // Y
            [UIColor colorWithHexString:@"4CD964"], // G
            [UIColor colorWithHexString:@"34AADC"], // B
            [UIColor colorWithHexString:@"007AFF"], // I
            [UIColor colorWithHexString:@"5856D6"], // V
    ];
}

@end