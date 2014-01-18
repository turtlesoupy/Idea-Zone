//
// Created by Thomas Dimson on 12/31/13.
// Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import "UINavigationBar+AIBExtensions.h"
#import "AIBIdeaZoneDescriptor.h"
#import "UIColor+AIBExtensions.h"


@implementation UINavigationBar (AIBExtensions)

- (void) tintForZone:(AIBIdeaZoneDescriptor *)zone {
    [self setBarTintColor:[zone color]];
    [self setTintColor:[[zone color] blackOrWhiteContrastingColor]];
    [self setTranslucent:NO];
    [self setTitleTextAttributes:@{NSForegroundColorAttributeName : [[zone color] blackOrWhiteContrastingColor]}];
    AIBLog(@"ZONE TINT: %@: %@", [zone color], [[zone color] blackOrWhiteContrastingColor]);
}

- (void) resetTints {
    [self setBarTintColor:nil];
    [self setTintColor:nil];
    [self setTranslucent:YES];
    [self setTitleTextAttributes:@{}];
}

@end