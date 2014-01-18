//
// Created by Thomas Dimson on 12/30/13.
// Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import "AIBIdeaZoneIdeaTableViewCell.h"
#import "AIBIdeaDescriptor.h"
#import "NSDate+AIBFormatting.h"
#import "AIBIdeaZoneManager.h"
#import "AIBPathViewStates.h"
#import <Dropbox/Dropbox.h>
#import "NSMutableArray+SWUtilityButtons.m"

static CGFloat const kButtonThreshold = 80;

@implementation AIBIdeaZoneIdeaTableViewCell {
}

+ (CGFloat) cellHeight {
   return 77.0f;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

    NSMutableArray *rightUtility = [[NSMutableArray alloc] init];
    [rightUtility sw_addUtilityButtonWithColor:[UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0f]
                                         title:@"Rename"];
    [rightUtility sw_addUtilityButtonWithColor:[UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                         title:@"Delete"];
    if((self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier containingTableView:nil leftUtilityButtons:nil rightUtilityButtons:rightUtility])) {
        [self setCellHeight:[[self class] cellHeight]];

        UIImageView *disclosureIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Disclosure"]];
        [disclosureIndicator setTag:1111];
        [[self cellScrollView] addSubview:disclosureIndicator];
    }
    return self;

    if((self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier])) {
        NSMutableArray *rightUtility = [[NSMutableArray alloc] init];
        [rightUtility sw_addUtilityButtonWithColor:[UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                             title:@"Rename"];
        [rightUtility sw_addUtilityButtonWithColor:[UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                    title:@"Delete"];
        self.rightUtilityButtons = rightUtility;
        NSMutableArray *leftUtility = [[NSMutableArray alloc] init];
        [leftUtility sw_addUtilityButtonWithColor:[UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                             title:@"Delete"];
        self.leftUtilityButtons = leftUtility;
        [self setCellHeight:[[self class] cellHeight]];
    }

    return self;
}

- (void) setIdeaDescriptor:(AIBIdeaDescriptor *)descriptor {
    [[self textLabel] setText:[descriptor name]];
    [[self viewWithTag:1111] setFrame:CGRectMake([self bounds].size.width - 28, ([[self class] cellHeight] - 14) / 2,
            [self viewWithTag:1111].bounds.size.width, [self viewWithTag:1111].bounds.size.height)];
    NSString *text = [[[descriptor info] modifiedTime] distanceOfTimeInWords];
    if([descriptor numComments] > 0) {
        text = [text stringByAppendingFormat:@" · %d comment%@", [descriptor numComments], [descriptor numComments] == 1 ? @"" : @"s"];
    }
    [[self detailTextLabel] setText:text];
    if([[[AIBIdeaZoneManager sharedInstance] pathViewStates] pathWasUpdated:[descriptor info] error:nil]) {
        [[self textLabel] setFont:[UIFont boldSystemFontOfSize:18]];
        [[self detailTextLabel] setFont:[UIFont boldSystemFontOfSize:12]];
    } else {
        [[self textLabel] setFont:[UIFont systemFontOfSize:18]];
        [[self detailTextLabel] setFont:[UIFont systemFontOfSize:12]];
    }
}

@end