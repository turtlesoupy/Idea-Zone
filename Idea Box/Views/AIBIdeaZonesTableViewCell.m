//
// Created by Thomas Dimson on 12/31/13.
// Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import "AIBIdeaZonesTableViewCell.h"
#import "AIBIdeaZoneDescriptor.h"
#import "UIColor+AIBExtensions.h"
#import "AIBIdeaZoneManager.h"
#import "AIBPathViewStates.h"


@implementation AIBIdeaZonesTableViewCell {

}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
    }

    return self;
}

- (void) setIdeaZone:(AIBIdeaZoneDescriptor *)ideaZone {
    [self setBackgroundColor:[ideaZone color]];
    [[self textLabel] setTextColor:[[ideaZone color] blackOrWhiteContrastingColor]];
    [[self detailTextLabel] setTextColor:[[ideaZone color] blackOrWhiteContrastingColor]];
    [[self textLabel] setText:[ideaZone name]];
    if([ideaZone numIdeas] > 0) {
        [[self detailTextLabel] setText:[@([ideaZone numIdeas]) stringValue]];
    } else {
        [[self detailTextLabel] setText:@""];
    }

    if([ideaZone anyUpdated]) {
        [[self textLabel] setFont:[UIFont boldSystemFontOfSize:17]];
    } else {
        [[self textLabel] setFont:[UIFont systemFontOfSize:17]];
    }
}

@end