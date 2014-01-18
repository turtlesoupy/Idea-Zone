//
//  AIBCreateIdeaViewController.h
//  Idea Box
//
//  Created by Thomas Dimson on 12/28/13.
//  Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class AIBIdeaZoneDescriptor;

@interface AIBCreateIdeaViewController : UIViewController<UITextViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) AIBIdeaZoneDescriptor *zone;

@end
