//
// Created by Thomas Dimson on 12/29/13.
// Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class AIBIdeaComment;
@class AIBIdeaDescriptor;


@interface AIBIdea : NSObject
@property(nonatomic, copy) NSString *text;
@property(nonatomic) CLLocationCoordinate2D coordinate;
@property(nonatomic, copy) NSString *coordinateName;

@property(nonatomic, strong) AIBIdeaDescriptor *descriptor;

@property(nonatomic, readonly) NSMutableArray *comments;

@property(nonatomic, copy) NSString *author;

- (id)initWithText:(NSString *)text;
- (id)initFromDocument:(NSString *)document descriptor:(AIBIdeaDescriptor *)descriptor;

- (void)addComment:(AIBIdeaComment *)comment;

- (void)removeLastComment;

- (NSString *)asDocument;
- (NSString *)documentTitle;
@end