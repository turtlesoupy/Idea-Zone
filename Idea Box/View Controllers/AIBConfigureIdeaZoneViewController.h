//
//  AIBConfigureIdeaZoneViewController.h
//  Idea Box
//
//  Created by Thomas Dimson on 12/30/13.
//  Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class AIBIdeaZoneDescriptor;

@interface AIBConfigureIdeaZoneViewController : UITableViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) AIBIdeaZoneDescriptor *ideaZone;

@end
