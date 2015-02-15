//
// Created by Thomas Dimson on 12/31/13.
// Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWTableViewCell.h"

@class AIBIdeaZoneDescriptor;

@interface AIBIdeaZonesTableViewCell : SWTableViewCell
+ (CGFloat) cellHeight;
- (void)setIdeaZone:(AIBIdeaZoneDescriptor *)ideaZone;
@end