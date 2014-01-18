//
// Created by Thomas Dimson on 12/30/13.
// Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWTableViewCell.h"

@class AIBIdeaDescriptor;

@interface AIBIdeaZoneIdeaTableViewCell : SWTableViewCell
+ (CGFloat)cellHeight;
- (void)setIdeaDescriptor:(AIBIdeaDescriptor *)descriptor;
@end