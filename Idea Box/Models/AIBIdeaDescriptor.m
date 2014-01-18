//
// Created by Thomas Dimson on 12/26/13.
// Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import "AIBIdeaDescriptor.h"
#import <Dropbox/Dropbox.h>


@implementation AIBIdeaDescriptor {
}

- (id) initWithFileInfo:(DBFileInfo *)info {
    if ((self = [super init])) {
        _name = [[[info path] name] stringByDeletingPathExtension];
        _info = info;
        _numComments = 0;
    }
    
    return self;
}

@end