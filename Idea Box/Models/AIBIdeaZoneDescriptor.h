//
// Created by Thomas Dimson on 12/25/13.
// Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBFileInfo;
@class DBPath;


@interface AIBIdeaZoneDescriptor : NSObject
- (id)initWithName:(NSString *)name fileInfo:(DBFileInfo *)fileInfo;

- (NSURL *)shareURL;

@property(nonatomic, copy) NSString *name;
@property(nonatomic, strong) DBFileInfo *fileInfo;
@property(nonatomic, strong) UIColor *color;
@property(nonatomic) NSUInteger numIdeas;
@property(nonatomic) BOOL anyUpdated;
@end