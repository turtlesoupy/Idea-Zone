//
// Created by Thomas Dimson on 1/3/14.
// Copyright (c) 2014 Thomas Dimson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBDatastore;
@class DBError;
@class DBFileInfo;

@interface AIBPathViewStates : NSObject
- (id)initWithDatastore:(DBDatastore *)datastore;

- (DBError *)clearAllStatesAndSync:(BOOL)sync1;
- (NSDate *)lastPathView:(DBFileInfo *)info error:(DBError **)error;
- (BOOL)pathWasUpdated:(DBFileInfo *)info error:(DBError **)error;
- (DBError *)markViewed:(DBFileInfo *)info sync:(BOOL)sync;
- (BOOL) isEmpty;
@end