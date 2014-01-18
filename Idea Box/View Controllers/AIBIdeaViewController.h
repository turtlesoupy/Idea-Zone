//
//  AIBIdeaViewController.h
//  Idea Box
//
//  Created by Thomas Dimson on 12/31/13.
//  Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AIBIdea;
@class AIBIdeaDescriptor;

@interface AIBIdeaViewController : UITableViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>
@property(nonatomic, strong) AIBIdea *idea;
@property(nonatomic, strong) AIBIdeaDescriptor *ideaDescriptor;
@end
