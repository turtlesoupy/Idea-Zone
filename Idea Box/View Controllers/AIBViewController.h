//
//  AIBViewController.h
//  Idea Box
//
//  Created by Thomas Dimson on 12/24/13.
//  Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AIBViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

- (IBAction)signOut:(UIStoryboardSegue *)segue;
@end
