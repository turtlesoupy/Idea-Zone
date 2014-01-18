//
//  AIBConfigureIdeaZoneViewController.m
//  Idea Box
//
//  Created by Thomas Dimson on 12/30/13.
//  Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import "AIBConfigureIdeaZoneViewController.h"
#import "AIBIdeaDescriptor.h"
#import "AIBIdeaZoneDescriptor.h"
#import "AIBIdeaZoneManager.h"
#import "AIBAlerts.h"
#import "UIAlertView+Blocks.h"
#import "UIColor+AIBExtensions.h"
#import "UINavigationBar+AIBExtensions.h"
#import <Dropbox/Dropbox.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

enum TableSections {
    kTableSectionAppearence = 0,
    kTableSectionSharing,
    kTableSectionLast
};

enum AppearenceRow {
    kTableAppearenceRowColor = 0,
    kTableAppearenceRowLast,
    kTableAppearenceRowName = 99
};

enum SharingRow {
    kTableSharingRowShare = 0,
    kTableSharingRowLast
};

@interface AIBConfigureIdeaZoneViewController ()

@end

@implementation AIBConfigureIdeaZoneViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *ret = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    [[ret detailTextLabel] setText:nil];
    [ret setSelectionStyle:UITableViewCellSelectionStyleDefault];

    switch([indexPath section]) {
        case kTableSectionAppearence:
            switch([indexPath row]) {
                case kTableAppearenceRowColor: {
                    [ret setSelectionStyle:UITableViewCellSelectionStyleNone];
                    UISegmentedControl *segmentedControl = (UISegmentedControl *) [ret viewWithTag:1];
                    segmentedControl.selectedSegmentIndex = [self segmentIndexForColor:[_ideaZone color]] ;
                    [segmentedControl addTarget:self action:@selector(colorSegmentChanged:) forControlEvents:UIControlEventValueChanged];
                } break;
                case kTableAppearenceRowName: {
                    [[ret detailTextLabel] setText:[_ideaZone name]];
                } break;
                default: break;
            } break;
        default: break;
    }

    return ret;
}

- (NSUInteger)segmentIndexForColor:(UIColor *)color {
    NSUInteger index = [[UIColor ideaZonePalette] indexOfObject:color];
    if(index == NSNotFound) {
        return 0;
    } else {
        return index;
    }
}

- (void)colorSegmentChanged:(UISegmentedControl *)colorSegment {
    UIColor *color = [[UIColor ideaZonePalette] objectAtIndex:(NSUInteger) [colorSegment selectedSegmentIndex]];

    DBError *error;
    [[AIBIdeaZoneManager sharedInstance] changeZoneColor:_ideaZone toColor:color error:&error];
    if(error) {
        [AIBAlerts showErrorAlert:error];
    } else {
        [[[self navigationController] navigationBar] tintForZone:_ideaZone];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch([indexPath section]) {
        case kTableSectionAppearence: {
            switch([indexPath row]) {
                case kTableAppearenceRowColor: {

                } break;
                case kTableAppearenceRowName: {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Zone Name"
                                                                    message:@"Enter your idea zone name" delegate:self
                                                          cancelButtonTitle:@"Cancel" otherButtonTitles:@"Okay", nil];
                    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                    [[alert textFieldAtIndex:0] setText:[_ideaZone name]];
                    [alert show];

                } break;

                default: break;
            }
        } break;

        case kTableSectionSharing: {
            switch([indexPath row]) {
                case kTableSharingRowShare: {
                    [UIAlertView showWithTitle:@"External Link"
                                       message:@"Due to limitations of the Dropbox API, you will have to use the Dropbox website to share this folder. "
                                               "Visit now?"
                             cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Visit Dropbox"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if(buttonIndex > 0) {
                            [[UIApplication sharedApplication] openURL:[_ideaZone shareURL]];

                            if([MFMailComposeViewController canSendMail]) {
                                [UIAlertView showWithTitle:@"Almost Done"
                                                   message:@"Now, we will send an instructional email to your collaborator to introduce them to Idea Zone"
                                         cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Okay"] tapBlock:^(UIAlertView *alertView2, NSInteger buttonIndex2) {
                                    if(buttonIndex2 > 0) {
                                        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] init];
                                        [composeViewController setSubject:[NSString stringWithFormat:@"Collaborate on my '%@' ideas with Idea Zone",
                                                        [_ideaZone name]]];
                                        [composeViewController setMessageBody:
                                                [NSString stringWithFormat:@"I want to collaborate with you on my '%@' ideas using the Idea Zone "
                                                @"application. To collaborate on ideas, download and open the application and then accept my Dropbox"
                                                                                   " shared folder link. Afterwards, moved the '%@' folder into the "
                                                                                   "/Idea Zone directory and open the application!",
                                                                [_ideaZone name], [_ideaZone name]]
                                                                       isHTML:NO];
                                        [composeViewController setMailComposeDelegate:self];
                                        [self presentViewController:composeViewController animated:YES completion:nil];
                                    }
                                }];
                            }
                        }
                    }];
                } break;
                default: break;
            } break;
        } break;

        default: break;
    }

    [[self tableView] deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex > 0) {
        NSString *newZoneName= [[alertView textFieldAtIndex:0] text];
        if(![newZoneName isEqualToString:[_ideaZone name]]) {
            DBError *error;
            [[AIBIdeaZoneManager sharedInstance] renameZone:_ideaZone toName:newZoneName error:&error];
            if(error) {
                [AIBAlerts showErrorAlert:error];
            } else {
                [[self tableView] reloadData];
                [[[self navigationController] viewControllers][[[[self navigationController] viewControllers] count] -1] setName:[_ideaZone name]];
            }
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:^{
        switch (result)
        {
            case MFMailComposeResultCancelled:
                break;
            case MFMailComposeResultSaved:
            case MFMailComposeResultSent:
                [UIAlertView showWithTitle:@"Awesome" message:@"Your mail has been sent. Get ready for collaboration!"
                         cancelButtonTitle:@"Okay" otherButtonTitles:@[] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {

                }];
                break;
            case MFMailComposeResultFailed:
                break;
            default:
                break;
        }

    }];
}


#pragma mark - Table view data source

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
