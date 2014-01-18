//
//  AIBViewController.m
//  Idea Box
//
//  Created by Thomas Dimson on 12/24/13.
//  Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import "AIBViewController.h"
#import "AIBAnimation.h"
#import "AIBIdeaZoneManager.h"
#import "AIBConstants.h"
#import <Dropbox/Dropbox.h>
#import <EXTScope.h>

@interface AIBViewController ()
- (IBAction)connectDropboxButtonPressed:(id)sender;

@end

@implementation AIBViewController {
    BOOL _expectConnect;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _expectConnect = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performSignIn) name:kAIBDropboxOpenURLOccurred object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    _errorLabel.hidden = YES;

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self performSignIn];
}

- (void) performSignIn {
    if (![self isViewLoaded ]|| ![[self view] window]) {
        return;
    }

    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    if(account) {
        NSError *error = [[AIBIdeaZoneManager sharedInstance] handleAuthorized];
        if(error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription]
                                       delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
        }
        if(_expectConnect) {
            [self performSegueWithIdentifier:@"PresentMainTableView" sender:self];
        } else {
            [self performSegueWithIdentifier:@"PresentMainTableViewNoAnimate" sender:self];
        }
    } else if (_expectConnect) {
        _errorLabel.text = @"Unauthorized - please reconnect";
        _errorLabel.hidden = NO;
        [AIBAnimation shakeAnimation:self.view.layer];
    }

    _expectConnect = NO;
    [[DBAccountManager sharedManager] removeObserver:self];
}


- (IBAction)connectDropboxButtonPressed:(id)sender {
    [[[DBAccountManager sharedManager] linkedAccount] unlink];
    [[DBAccountManager sharedManager] linkFromController:self];
    _expectConnect = YES;
}

-(IBAction)signOut:(UIStoryboardSegue *)segue {
    [[[DBAccountManager sharedManager] linkedAccount] unlink];
}
@end
