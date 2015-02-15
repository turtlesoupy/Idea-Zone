//
// Created by Thomas Dimson on 1/11/14.
// Copyright (c) 2014 Thomas Dimson. All rights reserved.
//

#import "UIScreen+AIBExtensions.h"


@implementation UIScreen (AIBExtensions)

- (CGRect) orientedBounds {
    if(UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        return CGRectMake(
                [self bounds].origin.y,
                [self bounds].origin.x,
                [self bounds].size.height,
                [self bounds].size.width
        );
    } else {
        return [self bounds];
    }
}
@end