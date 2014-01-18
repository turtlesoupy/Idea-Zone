//
// Created by Thomas Dimson on 1/1/14.
// Copyright (c) 2014 Thomas Dimson. All rights reserved.
//

#import <Foundation/Foundation.h>


@class AIBIdeaZoneDescriptor;

@interface AIBIdeaZone : NSObject
@property(nonatomic, strong) AIBIdeaZoneDescriptor *descriptor;
@property(nonatomic, strong) NSMutableArray *ideaDescriptors;
@end