//
// Created by Thomas Dimson on 12/26/13.
// Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBFileInfo;


@interface AIBIdeaDescriptor : NSObject {
}
@property(nonatomic, copy) NSString *name;
@property(nonatomic, strong) DBFileInfo *info;
@property(nonatomic, assign) NSInteger numComments;

- (id)initWithFileInfo:(DBFileInfo *)info;
@end