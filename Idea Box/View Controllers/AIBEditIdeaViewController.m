//
//  AIBEditIdeaViewController.m
//  Idea Zone
//
//  Created by Thomas Dimson on 1/11/14.
//  Copyright (c) 2014 Thomas Dimson. All rights reserved.
//

#import "AIBEditIdeaViewController.h"
#import "AIBIdea.h"
#import "AIBIdeaZoneManager.h"
#import "AIBAlerts.h"
#import "UIScreen+AIBExtensions.h"
#import <Dropbox/Dropbox.h>

@interface AIBEditIdeaViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UITextView *mainTextView;
- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
@end

@implementation AIBEditIdeaViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [_mainTextView setText:[_idea text]];
    _toolbar.alpha = 0.0;
    [_mainTextView setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_mainTextView becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void) keyboardDidShow:(NSNotification *)notification {
    CGSize kbSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _bottomConstraint.constant = kbSize.height;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [UIView animateWithDuration:0.2 delay:0.35 options:(UIViewAnimationOptions) 0 animations:^{
        _toolbar.alpha = 1.0;
    } completion:nil];
}

- (IBAction)saveButtonPressed:(id)sender {
    [_idea setText:[_mainTextView text]];
    DBError *error;
    [[AIBIdeaZoneManager sharedInstance] writeIdea:_idea error:&error];
    if(error) {
        [AIBAlerts showErrorAlert:error];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
