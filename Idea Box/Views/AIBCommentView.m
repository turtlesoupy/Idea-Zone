//
// Created by Thomas Dimson on 12/30/13.
// Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import "AIBCommentView.h"
#import "AIBIdeaComment.h"


@implementation AIBCommentView {

}

- (id) initWithFrame:(CGRect)frame comment:(AIBIdeaComment *)comment {
    if((self = [super initWithFrame:frame])) {
        UILabel *authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 20)];
        [authorLabel setText:[comment author]];
        [authorLabel setFont:[UIFont boldSystemFontOfSize:14]];


        UITextView *commentText = [[UITextView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(authorLabel.frame), frame.size.width, 0)];
        [commentText setText:[comment text]];
        [commentText setScrollEnabled:NO];
        [self addSubview:commentText];

        CGFloat fixedWidth = commentText.frame.size.width;
        CGSize newSize = [commentText sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = commentText.frame;
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        commentText.frame = newFrame;

        [self addSubview:authorLabel];

        [self setFrame:CGRectMake([self frame].origin.x, [self frame].origin.y, [self frame].size.width, CGRectGetMaxY(commentText.frame))];
    }

    return self;
}

@end