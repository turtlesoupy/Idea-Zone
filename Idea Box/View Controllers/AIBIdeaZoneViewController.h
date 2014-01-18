//
//  AIBIdeaZoneViewController.h
//  Idea Box
//
//  Created by Thomas Dimson on 12/26/13.
//  Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import <SWTableViewCell/SWTableViewCell.h>

@class AIBIdeaZoneDescriptor;

@interface AIBIdeaZoneViewController : UITableViewController <SWTableViewCellDelegate>

- (IBAction)addIdeaPressed:(id)sender;
@property(nonatomic, strong) AIBIdeaZoneDescriptor *ideaZone;
@end
