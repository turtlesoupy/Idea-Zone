//
// Created by Thomas Dimson on 12/25/13.
// Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import "AIBIdeaZoneDescriptor.h"
#import <Dropbox/Dropbox.h>


@implementation AIBIdeaZoneDescriptor {
}

- (id)initWithName:(NSString *)name fileInfo:(DBFileInfo *)fileInfo {
    if((self = [super init]))  {
        _name = name;
        _fileInfo = fileInfo;
        _color = [UIColor orangeColor];
        _numIdeas = 0;
        _anyUpdated = NO;
    }

    return self;
}

- (NSURL *)shareURL {
    NSString *orgName = [[[[DBAccountManager sharedManager] linkedAccount] info] orgName];
    return [NSURL URLWithString:[[NSString stringWithFormat:@"https://www.dropbox.com/%@%@?share=1",
                    [((orgName && [orgName length] > 0) ? orgName : @"personal") stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                    [[[self fileInfo] path] stringValue]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

@end