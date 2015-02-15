//
// Created by Thomas Dimson on 12/28/13.
// Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import "AIBAlerts.h"
#import "UIAlertView+Blocks.h"


@implementation AIBAlerts {

}

+ (void) showErrorAlert:(NSError *)error {
    AIBLog(@"Showing error alert: %@", error);
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIAlertView showWithTitle:@"Error"
                           message:[error localizedDescription]
                 cancelButtonTitle:@"Okay"
                 otherButtonTitles:@[]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {}];
    });
}

@end