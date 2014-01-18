//
// Created by Thomas Dimson on 1/3/14.
// Copyright (c) 2014 Thomas Dimson. All rights reserved.
//

#import "AIBPathViewStates.h"
#import "CocoaSecurity.h"
#import "AIBConstants.h"
#import <Dropbox/Dropbox.h>


@implementation AIBPathViewStates {
    DBDatastore *_datastore;
    DBTable *_viewStatesTable;
}
- (id)initWithDatastore:(DBDatastore *)datastore {
    if((self = [super init])) {
        _datastore =  datastore;
        _viewStatesTable = [_datastore getTable:@"pathViewStates"];
    }
    return self;
}

- (DBError *)clearAllStatesAndSync:(BOOL) sync {
    DBError *error;
    NSArray *results = [_viewStatesTable query:nil error:&error];
    if(error) {
        return error;
    }

    for(DBRecord *result in results) {
        [result deleteRecord];
    }

    if(sync) {
        [_datastore sync:nil];
    }

    return nil;
}

- (NSString *)pathKey:(DBPath *)path{
    return [[CocoaSecurity md5:[path stringValue]] base64];
}

- (NSDate *) lastPathView:(DBFileInfo *)info error:(DBError **) error {
    DBError *_error;
    DBRecord *rec = [_viewStatesTable getRecord:[self pathKey:[info path]] error:&_error];
    AIBReturnIfErrorPtr(error, _error, nil)
    if(!rec || !rec[@"last-seen"]) {
        return nil;
    }
    return rec[@"last-seen"];
}

- (BOOL) pathWasUpdated:(DBFileInfo *)info error:(DBError **)error {
    static CGFloat const closeEnough = 30.0;
    DBError *_error;
    NSDate *lastView = [self lastPathView:info error:&_error];
    AIBReturnIfErrorPtr(error, _error, NO);


    if(!lastView || fabs([lastView timeIntervalSinceDate:[info modifiedTime]]) > closeEnough) {
        return YES;
    }

    return NO;
}


- (DBError *) markViewed:(DBFileInfo *)info sync:(BOOL)sync {
    BOOL wasInserted;
    DBError *error;
    DBRecord *rec = [_viewStatesTable getOrInsertRecord:[self pathKey:[info path]]
                                                fields:@{
                                                        @"path": [[info path] stringValue],
                                                        @"last-seen": [info modifiedTime]
                                                        }
                                              inserted:&wasInserted error:&error];

    if(error) {
        return error;
    }

    if(!wasInserted) {
        rec[@"last-seen"] = [info modifiedTime];
    }

    if(sync) {
        AIBLog(@"%@", [_datastore sync:&error]);
        if(error) {
            return error;
        }
    }

    return nil;
}

- (BOOL)isEmpty {
    return [[_viewStatesTable query:nil error:nil] count] > 0;
}


@end