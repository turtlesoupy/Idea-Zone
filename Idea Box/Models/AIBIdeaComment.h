//
// Created by Thomas Dimson on 12/29/13.
// Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AIBIdeaComment : NSObject
@property(nonatomic, copy) NSString *text;
@property(nonatomic, copy) NSString *author;
@property(nonatomic, copy) NSString *imagePath;

- (id)initWithText:(NSString *)text author:(NSString *)author;
- (id)initWithImagePath:(NSString *)imagePath author:(NSString *)author;
@end