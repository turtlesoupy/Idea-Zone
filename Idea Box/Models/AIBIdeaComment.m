//
// Created by Thomas Dimson on 12/29/13.
// Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import "AIBIdeaComment.h"


@implementation AIBIdeaComment {
}

- (id) initWithText:(NSString *)text author:(NSString *)author {
    if((self = [super init])) {
        _text = text; 
        _author = author;
    }

    return self;
}

- (id) initWithImagePath:(NSString *)imagePath author:(NSString *)author {
    if((self = [super init])) {
        _imagePath = imagePath;
        _author = author;
    }
    return self;
}

@end