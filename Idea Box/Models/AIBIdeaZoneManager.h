//
// Created by Thomas Dimson on 12/25/13.
// Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBError;
@class AIBIdeaZoneDescriptor;
@class AIBIdea;
@class AIBIdeaDescriptor;
@class AIBPathViewStates;
@class DBPath;


typedef void (^UIImageBlock_t)(UIImage *);

@interface AIBIdeaZoneManager : NSObject

@property(nonatomic, readonly) AIBPathViewStates *pathViewStates;

+ (AIBIdeaZoneManager *)sharedInstance;

- (BOOL)completedInitialSync;

- (NSError *)handleAuthorized;
- (void)addZone:(NSString *)name error:(DBError **)srcError;

- (void)changeZoneColor:(AIBIdeaZoneDescriptor *)zone toColor:(UIColor *)color error:(DBError **)srcError;

- (void)renameZone:(AIBIdeaZoneDescriptor *)zone toName:(NSString *)name error:(DBError **)srcError;

- (NSArray *)zones:(DBError **)error;
- (NSArray *)ideasInZone:(AIBIdeaZoneDescriptor *)zone error:(DBError **)srcError;
- (void)createIdea:(AIBIdea *)idea inZone:(AIBIdeaZoneDescriptor *)zone error:(DBError **)srcError;

- (void)writeIdea:(AIBIdea *)idea error:(DBError **)srcError;

- (AIBIdea *)readIdea:(AIBIdeaDescriptor *)descriptor error:(DBError **)srcError;

- (void)addCommentToIdea:(AIBIdea *)idea commentText:(NSString *)commentText error:(DBError **)srcError;

- (NSString *)preferredUsername;

- (void)deleteIdea:(AIBIdeaDescriptor *)descriptor error:(DBError **)srcError;

- (void)deleteIdeaZone:(AIBIdeaZoneDescriptor *)descriptor error:(DBError **)srcError;

- (void)setImageViewFromPath:(DBPath *)path imageView:(UIImageView *)imageView;

- (void)imageFromPath:(DBPath *)path callback:(UIImageBlock_t)callback;

- (void)setImageButtonFromPath:(DBPath *)path imageView:(__weak UIButton *)imageButton;

- (void)addCommentToIdea:(AIBIdea *)idea commentImage:(UIImage *)image error:(DBError **)error;

- (void)renameIdea:(AIBIdeaDescriptor *)descriptor toName:(NSString *)name error:(DBError **)error;
@end