//
//  AIBIdeaCommentController.h
//  Idea Box
//
//  Created by Thomas Dimson on 12/29/13.
//  Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AIBIdeaZoneDescriptor;
@class AIBIdea;

@interface AIBIdeaCommentController : UIViewController <UITextViewDelegate>
@property (nonatomic, retain) AIBIdea *idea;
@end
