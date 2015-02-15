//
//  AIBIdeaCommentController.m
//  Idea Box
//
//  Created by Thomas Dimson on 12/29/13.
//  Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import "AIBIdeaCommentController.h"
#import "AIBIdeaZoneDescriptor.h"
#import "AIBIdea.h"
#import "AIBIdeaZoneManager.h"
#import "AIBAlerts.h"
#import <Dropbox/Dropbox.h>

@interface AIBIdeaCommentController ()
@property (weak, nonatomic) IBOutlet UITextView *mainTextView;
@property (weak, nonatomic) IBOutlet UIToolbar *cancelSaveToolbar;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)savePressed:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpacing;

@end

@implementation AIBIdeaCommentController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _cancelSaveToolbar.alpha = 0.0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_mainTextView setDelegate:self];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [UIView animateWithDuration:0.2 delay:0.35 options:(UIViewAnimationOptions) 0 animations:^{
        _cancelSaveToolbar.alpha = 1.0;
    } completion:nil];
}

- (void) keyboardDidShow:(NSNotification *)notification {
    CGSize kbSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _bottomSpacing.constant = kbSize.height;
}

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)savePressed:(id)sender {
    DBError *error;
    [[AIBIdeaZoneManager sharedInstance] addCommentToIdea:_idea commentText:[_mainTextView text]
                                                    error:&error];
    if(error) {
        [AIBAlerts showErrorAlert:error];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
}
@end
