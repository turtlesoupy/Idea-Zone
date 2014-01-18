//
//  AIBIdeaViewController.m
//  Idea Box
//
//  Created by Thomas Dimson on 12/31/13.
//  Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import "AIBIdeaViewController.h"
#import "AIBIdeaCommentController.h"
#import "AIBIdea.h"
#import "AIBIdeaDescriptor.h"
#import "AIBIdeaZoneDescriptor.h"
#import "AIBIdeaZoneManager.h"
#import "AIBAlerts.h"
#import "AIBIdeaComment.h"
#import "UIImage+AIBExtensions.h"
#import "AIBPathViewStates.h"
#import "AIBCreateIdeaViewController.h"
#import "AIBEditIdeaViewController.h"
#import <Dropbox/Dropbox.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "EXTScope.h"
#import <objc/runtime.h>

static CGFloat const kImageCommentHeight = 100;

@interface AIBIdeaViewController ()
- (IBAction)cameraButtonPressed:(id)sender;

@end

@implementation AIBIdeaViewController {
    UIImage *_myBubbleImage;
    UIImage *_theirBubbleImage;
    __weak AIBIdeaComment *_lastTappedComment;
}

+ (UIImage *)bubbleImageViewForType:(UIColor *)color flip:(BOOL) flip
{
    UIImage *bubble = [UIImage imageNamed:@"bubble.png"];
    UIImage *normalBubble = [bubble imageMaskWithColor:color];

    if(flip) {
        normalBubble = [normalBubble imageFlippedHorizontal];
    }

    // make image stretchable from center point
    CGPoint center = CGPointMake(bubble.size.width / 2.0f, bubble.size.height / 2.0f);
    UIEdgeInsets capInsets = UIEdgeInsetsMake(center.y, center.x, center.y, center.x);
    return [normalBubble stretchableImageWithCapInsets:capInsets];

}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _myBubbleImage = [AIBIdeaViewController bubbleImageViewForType:
                [UIColor colorWithHue:210.0f / 360.0f
                                              saturation:0.94f
                                              brightness:1.0f
                                                   alpha:1.0f]
                                                              flip:YES];

        _theirBubbleImage= [AIBIdeaViewController bubbleImageViewForType:
                        [UIColor colorWithHue:240.0f / 360.0f
                                   saturation:0.02f
                                   brightness:0.92f
                                        alpha:1.0f]
                                                                      flip:NO];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:[_ideaDescriptor name]];
    [[self tableView] registerClass:[UITableViewCell class] forCellReuseIdentifier:@"IdeaTextCell"];
    [[self tableView] registerClass:[UITableViewCell class] forCellReuseIdentifier:@"IdeaCommentCell"];
    [[self tableView] registerClass:[UITableViewCell class] forCellReuseIdentifier:@"IdeaCommentImageCell"];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        DBError *error;
        _idea = [[AIBIdeaZoneManager sharedInstance] readIdea:_ideaDescriptor error:&error];

        if(error) {
            [AIBAlerts showErrorAlert:error];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateStyle:NSDateFormatterLongStyle];
                [dateFormatter setTimeStyle:NSDateFormatterNoStyle];

                NSString *headerText = [dateFormatter stringFromDate:[[[_idea descriptor] info] modifiedTime]];
                if([_idea coordinateName]) {
                    headerText = [headerText stringByAppendingFormat:@" · %@", [_idea coordinateName]];
                }
                UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,
                        [[self tableView] bounds].size.width, 20)];
                [headerLabel setTextAlignment:NSTextAlignmentCenter];
                [headerLabel setText:headerText];
                [headerLabel setFont:[UIFont systemFontOfSize:10]];
                [headerLabel setTextColor:[UIColor grayColor]];
                [[self tableView] setTableHeaderView:headerLabel];

                [[self tableView] reloadData];
            });
        }
    });
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    // HACK HACK HACK
    [[self tableView] reloadData];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[[AIBIdeaZoneManager sharedInstance] pathViewStates] markViewed:[_ideaDescriptor info] sync:YES];
    [[self tableView] reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(!_idea) {
        return 0;
    }

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!_idea) {
        return 0;
    }

    if(section == 0) {
        return 1;
    } else {
        return [[_idea comments] count];
    }
}

static UIEdgeInsets const kIdeaMargins = {20.0, 40.0, 20.0, 40.0};
static UIEdgeInsets const kCommentMargins = {0.0, 20.0, 12.0, 20.0};
static UIEdgeInsets const kBubbleLabelInsets = {6.0, 16.0, 6.0, 16.0};
static CGFloat const kIdeaAttributionLabelHeight = 14;
static CGFloat const kIdeaCommentAttributionLabelHeight = 14.0;

- (CGFloat) ideaTextViewHeight {
    NSDictionary *stringAttributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:14] forKey: NSFontAttributeName];

    CGSize expectedLabelSize2 = [[_idea text] boundingRectWithSize:CGSizeMake([[self tableView] bounds].size.width - kIdeaMargins.left - kIdeaMargins.right, 10000)
                                                     options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:stringAttributes context:nil].size;
    return expectedLabelSize2.height;
}


- (CGSize) commentLabelSize:(AIBIdeaComment *)comment {
    NSDictionary *stringAttributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:13] forKey: NSFontAttributeName];
    CGSize expectedLabelSize2 = [[comment text] boundingRectWithSize:CGSizeMake(
            [[self tableView] bounds].size.width - kCommentMargins.left - kCommentMargins.right - kBubbleLabelInsets.left - kBubbleLabelInsets.right
            , 10000)
                                                           options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:stringAttributes context:nil].size;
    return CGSizeMake(expectedLabelSize2.width, expectedLabelSize2.height);
}

static char kButtonRowKey;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section] == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IdeaTextCell" forIndexPath:indexPath];
        UILabel *ideaLabel;
        UILabel *attributionLabel;
        if([cell viewWithTag:2]) {
            ideaLabel = (UILabel *) [cell viewWithTag:1];
            attributionLabel = (UILabel *) [cell viewWithTag:2];
        } else {
            ideaLabel = [[UILabel alloc] init];
            [ideaLabel setNumberOfLines:0];
            [ideaLabel setFont:[UIFont systemFontOfSize:14]];
            [ideaLabel setTag:1];
            [ideaLabel setTextAlignment:NSTextAlignmentLeft];
            [cell addSubview:ideaLabel];

            attributionLabel =  [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0,0)];
            [attributionLabel setFont:[UIFont systemFontOfSize:10]];
            [attributionLabel setTextAlignment:NSTextAlignmentRight];
            [attributionLabel setTag:2];
            [cell addSubview:attributionLabel];
        }

        [ideaLabel setText:[_idea text]];
        [ideaLabel setFrame:CGRectMake(
                kIdeaMargins.left, kIdeaMargins.top,[[self tableView] bounds].size.width - kIdeaMargins.left - kIdeaMargins.right, [self ideaTextViewHeight])];
        [attributionLabel setText:[NSString stringWithFormat:@"-%@", [_idea author]]];
        [attributionLabel setFrame:CGRectMake(
                [ideaLabel frame].origin.x, CGRectGetMaxY(ideaLabel.frame),
                [ideaLabel bounds].size.width,
                kIdeaAttributionLabelHeight)];

        return cell;
    } else {
        AIBIdeaComment *comment = [_idea comments][(NSUInteger) [indexPath row]];
        BOOL myComment = [[comment author] isEqualToString:[[AIBIdeaZoneManager sharedInstance] preferredUsername]];
        if([comment imagePath]) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IdeaCommentImageCell" forIndexPath:indexPath];
            UIButton *cellImageButton;
            UILabel *commentAttributionLabel;
            if([cell viewWithTag:1]) {
                cellImageButton = (UIButton *)[cell viewWithTag:1];
                commentAttributionLabel = (UILabel *) [cell viewWithTag:2];
            } else {
                cellImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [cellImageButton setTag:1];
                [cell addSubview:cellImageButton];
                [cellImageButton addTarget:self action:@selector(commentImageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

                commentAttributionLabel = [[UILabel alloc] initWithFrame:CGRectMake(kCommentMargins.left, CGRectGetMaxY([cellImageButton frame]),
                        [cellImageButton bounds].size.width, kIdeaCommentAttributionLabelHeight)];
                [commentAttributionLabel setFont:[UIFont systemFontOfSize:10]];
                [commentAttributionLabel setTextColor:[UIColor grayColor]];
                [commentAttributionLabel setTag:2];
                [commentAttributionLabel setTextAlignment:NSTextAlignmentCenter];
                [cell addSubview:commentAttributionLabel];
            }

            objc_setAssociatedObject(cellImageButton, &kButtonRowKey, @([indexPath row]), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            @weakify(cellImageButton, tableView)
            [[AIBIdeaZoneManager sharedInstance] imageFromPath:[[DBPath alloc] initWithString:[comment imagePath]] callback:^(UIImage *image) {
                @strongify(cellImageButton, tableView)
                float availableWidth = ([tableView bounds].size.width - kCommentMargins.left - kCommentMargins.right);
                float scaleX = availableWidth / [image size].width;
                float scaleY = kImageCommentHeight / [image size].height;
                float scale = MIN(scaleX, scaleY);
                if(myComment) {
                    [cellImageButton setFrame:CGRectMake(availableWidth - ([image size].width * scale) + kCommentMargins.left, kCommentMargins.top,
                            [image size].width * scale, kImageCommentHeight)];
                } else {
                    [cellImageButton setFrame:CGRectMake(kCommentMargins.left, kCommentMargins.top,
                            [image size].width * scale, kImageCommentHeight)];
                }

                [cellImageButton setBackgroundImage:image forState:UIControlStateNormal];
            }];
            [commentAttributionLabel setFrame:CGRectMake(kCommentMargins.left, kImageCommentHeight + kCommentMargins.top,
                    [tableView bounds].size.width - kCommentMargins.left - kCommentMargins.right, kIdeaCommentAttributionLabelHeight)];
            if(myComment) {
                [commentAttributionLabel setTextAlignment:NSTextAlignmentRight];
            } else {
                [commentAttributionLabel setTextAlignment:NSTextAlignmentLeft];
            }
            [commentAttributionLabel setText:[comment author]];
            return cell;
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IdeaCommentCell" forIndexPath:indexPath];
            UIImageView *bubbleStretcher;
            UILabel *bubbleLabel;
            UILabel *commentAttributionLabel;

            if([cell viewWithTag:1]) {
                bubbleStretcher = (UIImageView *) [cell viewWithTag:1];
                bubbleLabel = (UILabel *)[cell viewWithTag:2];
                commentAttributionLabel = (UILabel *) [cell viewWithTag:3];
            } else {
                bubbleStretcher = [[UIImageView alloc] initWithFrame:CGRectZero];
                [bubbleStretcher setTag:1];
                [cell addSubview:bubbleStretcher];

                bubbleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                [bubbleLabel setTextColor:[UIColor whiteColor]];
                [bubbleLabel setNumberOfLines:0];
                [bubbleLabel setFont:[UIFont systemFontOfSize:13]];
                [bubbleLabel setTag:2];
                [bubbleStretcher addSubview:bubbleLabel];

                commentAttributionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                [commentAttributionLabel setFont:[UIFont systemFontOfSize:10]];
                [commentAttributionLabel setTextColor:[UIColor grayColor]];
                [commentAttributionLabel setTag:3];
                [cell addSubview:commentAttributionLabel];
            }

            CGSize labelSize = [self commentLabelSize:comment];
            CGFloat trueWidth= labelSize.width + kBubbleLabelInsets.left + kBubbleLabelInsets.right;
            CGFloat fullWidth = [[self tableView] bounds].size.width - kCommentMargins.left - kCommentMargins.right;

            if(myComment) {
                [bubbleStretcher setImage:[AIBIdeaViewController bubbleImageViewForType:
                        [UIColor colorWithHue:210.0f / 360.0f
                                   saturation:0.94f
                                   brightness:1.0f
                                        alpha:1.0f]
                                                                           flip:NO]];
                [bubbleStretcher setFrame:CGRectMake(kCommentMargins.left + (fullWidth - trueWidth),
                        kCommentMargins.top,
                        trueWidth,
                        labelSize.height+ kBubbleLabelInsets.top + kBubbleLabelInsets.bottom
                )];
                [commentAttributionLabel setTextAlignment:NSTextAlignmentRight];
                [bubbleLabel setTextColor:[UIColor whiteColor]];
            } else {
                [bubbleStretcher setImage:[AIBIdeaViewController bubbleImageViewForType:
                        [UIColor colorWithHue:240.0f / 360.0f
                                   saturation:0.02f
                                   brightness:0.92f
                                        alpha:1.0f]
                                                                            flip:YES]];
                [bubbleStretcher setFrame:CGRectMake(kCommentMargins.left,
                        kCommentMargins.top,
                        trueWidth,
                        labelSize.height+ kBubbleLabelInsets.top + kBubbleLabelInsets.bottom
                )];
                [commentAttributionLabel setTextAlignment:NSTextAlignmentLeft];
                [bubbleLabel setTextColor:[UIColor blackColor]];
            }

            [bubbleLabel setText:[comment text]];
            [bubbleLabel setFrame:CGRectMake(kBubbleLabelInsets.left, kBubbleLabelInsets.top,
                    [bubbleStretcher bounds].size.width - kBubbleLabelInsets.left - kBubbleLabelInsets.right,
                    labelSize.height)];

            [commentAttributionLabel setText:[comment author]];
            [commentAttributionLabel setFrame:CGRectMake(
                    kCommentMargins.left,
                    CGRectGetMaxY([bubbleStretcher frame]),
                    fullWidth,
                    kIdeaCommentAttributionLabelHeight)];

            return cell;
        }

    }

}

- (void)commentImageButtonPressed:(id)cellImageButton {
    NSNumber *row = (NSNumber * ) objc_getAssociatedObject(cellImageButton, &kButtonRowKey);
    _lastTappedComment = [_idea comments][(NSUInteger) [row integerValue]];
    [self performSegueWithIdentifier:@"PushImagePreview" sender:self];
}

- (CGFloat) tableView: tableView heightForRowAtIndexPath:indexPath {
    if([indexPath section] == 0) {
        return [self ideaTextViewHeight] + kIdeaAttributionLabelHeight + kIdeaMargins.top + kIdeaMargins.bottom;
    } else {
        AIBIdeaComment *comment = [_idea comments][(NSUInteger) [indexPath row]];
        if([comment imagePath]) {
            return kImageCommentHeight + kIdeaCommentAttributionLabelHeight + kCommentMargins.top + kCommentMargins.bottom;
        }  else {
            return [self commentLabelSize:comment].height
                    + kBubbleLabelInsets.top + kBubbleLabelInsets.bottom +
                    + kIdeaCommentAttributionLabelHeight
                    + kCommentMargins.top + kCommentMargins.bottom;
        }
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *image;

    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0)
            == kCFCompareEqualTo) {

        editedImage = (UIImage *) [info objectForKey:
                UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                UIImagePickerControllerOriginalImage];

        image = editedImage ? editedImage : originalImage;
        [self dismissViewControllerAnimated:YES completion:nil];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            DBError *error;
            [[AIBIdeaZoneManager sharedInstance] addCommentToIdea:_idea commentImage:image error:&error];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(error) {
                    [AIBAlerts showErrorAlert:error];
                    return;
                }

                [[self tableView] reloadData];
            });
        });
    }
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 2) {
        return;
    }

    UIImagePickerController *cameraController = [[UIImagePickerController alloc] init];
    [cameraController setDelegate:self];
    if(buttonIndex == 1) {
        [cameraController setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    [self presentViewController:cameraController animated:YES completion:nil];
}



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"CommentSegue"]) {
        AIBIdeaCommentController *dst = [segue destinationViewController];
        [dst setIdea:_idea];
    } else if ([[segue identifier] isEqualToString:@"PushImagePreview"]) {
        UIViewController *dst = [segue destinationViewController];
        UIImageView *previewImage = (UIImageView *) [[dst view] viewWithTag:1];


        [[AIBIdeaZoneManager sharedInstance] setImageViewFromPath:[[DBPath alloc] initWithString:[_lastTappedComment imagePath]]
                                                        imageView:previewImage];
    } else if([[segue identifier] isEqualToString:@"EditIdeaSegue"]) {
        AIBEditIdeaViewController *dst = [segue destinationViewController];
        [dst setIdea:_idea];
    }
}


- (IBAction)cameraButtonPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
            initWithTitle:@"Attach photo from" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
        otherButtonTitles:@"Library", @"Camera", nil];

    [actionSheet showFromBarButtonItem:sender animated:YES];
}

@end
