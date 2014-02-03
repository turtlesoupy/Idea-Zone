//
//  AIBIdeaZoneViewController.m
//  Idea Box
//
//  Created by Thomas Dimson on 12/26/13.
//  Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import "AIBIdeaZoneViewController.h"
#import "AIBIdeaZoneDescriptor.h"
#import "AIBIdeaZoneManager.h"
#import "AIBAlerts.h"
#import "AIBIdeaDescriptor.h"
#import "NSDate+AIBFormatting.h"
#import "AIBCreateIdeaViewController.h"
#import "AIBIdeaViewController.h"
#import "AIBIdeaZoneIdeaTableViewCell.h"
#import "UIAlertView+Blocks.h"
#import "EXTScope.h"
#import "AIBConfigureIdeaZoneViewController.h"
#import "UIColor+AIBExtensions.h"
#import "UINavigationBar+AIBExtensions.h"
#import "AIBPathViewStates.h"
#import <Dropbox/Dropbox.h>

@implementation AIBIdeaZoneViewController {
    NSMutableArray *_ideas;
    NSIndexPath *_selectedIndexPath;
    __weak AIBIdeaDescriptor *_lastSelectedIdea;
    __weak AIBIdeaDescriptor *_lastSwipedIdea;
}

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        _ideas = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:[_ideaZone name]];
    [[self tableView] setRowHeight:[AIBIdeaZoneIdeaTableViewCell cellHeight]];
    [[self tableView] registerClass:[AIBIdeaZoneIdeaTableViewCell class] forCellReuseIdentifier:@"IdeaCell"];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[[self navigationController] navigationBar] tintForZone:_ideaZone];
    [self refresh];
}

- (void) refresh {
    __block BOOL loadingCancelled = NO;


    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        DBError *error;
        _ideas = [[[AIBIdeaZoneManager sharedInstance] ideasInZone:_ideaZone error:&error] mutableCopy];
        [_ideas sortUsingComparator:^NSComparisonResult(AIBIdeaDescriptor *desc1, AIBIdeaDescriptor *desc2) {
            return [[[desc2 info] modifiedTime] compare:[[desc1 info] modifiedTime]];
        }];

        if(self && [self isViewLoaded] && [[self view] window] && [[self navigationController] topViewController] == self) {
            [AIBAlerts showErrorAlert:error];
        } else {
            loadingCancelled = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[self tableView] reloadData];
                [[self refreshControl] endRefreshing];
            });
        }
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if(loadingCancelled) {
            return;
        }

        [[self tableView] setContentOffset:CGPointMake(0, -self.topLayoutGuide.length) animated:YES];
        [[self refreshControl] beginRefreshing];
    });
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    // HACK HACK HACK
    [[self tableView] reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_ideas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AIBIdeaDescriptor *ideaDescriptor = _ideas[(NSUInteger) [indexPath row]];
    AIBIdeaZoneIdeaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IdeaCell"];
    [cell setIdeaDescriptor:ideaDescriptor];
    cell.containingTableView = tableView;
    [cell setDelegate:self];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _lastSelectedIdea = _ideas[(NSUInteger)[indexPath row]];
    [self performSegueWithIdentifier:@"PushIdea" sender:self];
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"PushIdea"]) {
        AIBIdeaViewController *dst = [segue destinationViewController];
        [dst setIdeaDescriptor:_lastSelectedIdea];
        [[[AIBIdeaZoneManager sharedInstance] pathViewStates] markViewed:[_lastSelectedIdea info] sync:YES];
    } else if([[segue identifier] isEqualToString:@"PushCreateIdea"]) {
        AIBCreateIdeaViewController *dst = [segue destinationViewController];
        [dst setZone:_ideaZone];
    } else if([[segue identifier] isEqualToString:@"PushConfigure"]) {
        AIBConfigureIdeaZoneViewController *dst = [segue destinationViewController];
        [dst setIdeaZone:_ideaZone];
    }
}


- (IBAction)addIdeaPressed:(id)sender {
    [self performSegueWithIdentifier:@"PushCreateIdea" sender:self];
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    if(index == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rename Idea"
                                                        message:@"Enter the new name" delegate:self
                                              cancelButtonTitle:@"Cancel" otherButtonTitles:@"Okay", nil];
        AIBIdeaDescriptor *idea = _ideas[(NSUInteger) [[[self tableView] indexPathForCell:cell] row]];
        _lastSwipedIdea = idea;
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [[alert textFieldAtIndex:0] setText:[idea name]];
        [alert show];
    } else if(index == 1) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        AIBIdeaDescriptor *idea = _ideas[(NSUInteger) [indexPath row]];
        @weakify(self)
        [UIAlertView showWithTitle:@"Confirm" message:[NSString stringWithFormat:@"Really delete '%@'?", [idea name]]
                 cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            @strongify(self)
            if(buttonIndex > 0) {
                DBError *error;
                [[AIBIdeaZoneManager sharedInstance] deleteIdea:idea error:&error];
                if(error) {
                    [AIBAlerts showErrorAlert:error];
                } else {
                    [self->_ideas removeObjectAtIndex:(NSUInteger) [indexPath row]];
                    [[self tableView] beginUpdates];
                    [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [[self tableView] endUpdates];
                }
            }
        }];
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex > 0) {
        AIBIdeaDescriptor *ideaDescriptor = _lastSwipedIdea;
        NSString *newIdeaName= [[alertView textFieldAtIndex:0] text];
        if(![newIdeaName isEqualToString:[ideaDescriptor name]]) {
            DBError *error;
            [[AIBIdeaZoneManager sharedInstance] renameIdea:ideaDescriptor toName:newIdeaName error:&error];
            if(error) {
                [AIBAlerts showErrorAlert:error];
            } else {
                [[self tableView] reloadData];
            }
        }
    }
}

@end
