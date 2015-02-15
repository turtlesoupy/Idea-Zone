//
// Created by Thomas Dimson on 12/31/13.
// Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIBIdeaZoneDescriptor;

@interface UINavigationBar (AIBExtensions)
- (void)tintForZone:(AIBIdeaZoneDescriptor *)zone;
- (void)resetTints;
@end