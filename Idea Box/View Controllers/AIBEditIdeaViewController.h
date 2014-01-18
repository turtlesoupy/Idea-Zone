//
//  AIBEditIdeaViewController.h
//  Idea Zone
//
//  Created by Thomas Dimson on 1/11/14.
//  Copyright (c) 2014 Thomas Dimson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AIBIdea;

@interface AIBEditIdeaViewController : UIViewController <UITextViewDelegate>
@property (nonatomic, strong) AIBIdea *idea;
@end
