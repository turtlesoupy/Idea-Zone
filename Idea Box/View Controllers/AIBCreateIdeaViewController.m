//
//  AIBCreateIdeaViewController.m
//  Idea Box
//
//  Created by Thomas Dimson on 12/28/13.
//  Copyright (c) 2013 Thomas Dimson. All rights reserved.
//

#import "AIBCreateIdeaViewController.h"
#import "AIBIdea.h"
#import "AIBIdeaZoneManager.h"
#import "AIBAlerts.h"
#import <Dropbox/Dropbox.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>
#import <EXTScope.h>

@interface AIBCreateIdeaViewController ()
@property (weak, nonatomic) IBOutlet UITextView *mainTextView;
@property (weak, nonatomic) IBOutlet UIView *actionButtonContainer;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@end

@implementation AIBCreateIdeaViewController {
    CLLocationManager *_locationManager;
    CLLocation *_lastLocation;
    CLPlacemark *_lastPlacemark;
    CLGeocoder *_geocoder;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _actionButtonContainer.alpha = 0.0;
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    _lastLocation = nil;
    _lastPlacemark = nil;

    _geocoder = [[CLGeocoder alloc] init];

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

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [UIView animateWithDuration:0.2 delay:0.35 options:(UIViewAnimationOptions) 0 animations:^{
        _actionButtonContainer.alpha = 1.0;
    } completion:nil];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    _lastLocation = locations[[locations count] - 1];
    AIBLog(@"Performing reverse geocode on %@ %@", _lastLocation, _geocoder);
    @weakify(self)
    [_geocoder reverseGeocodeLocation:_lastLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        @strongify(self)
        AIBLog(@"Reverse geocode %@", placemarks);
        if(!self) {
            return;
        }

        if([placemarks count] == 0 || error) {
            AIBLog(@"Error during reverse geocode %@", error);
        }

        self->_lastPlacemark = placemarks[0];
        AIBLog(@"Got location %@ %@", self->_lastPlacemark, self->_lastLocation);
    }];

    if(_lastLocation.horizontalAccuracy < 200.0 && _lastLocation.verticalAccuracy < 200.0) {
        [_locationManager stopUpdatingLocation];
    }
}

#pragma mark - Event Handlers

- (void) keyboardDidShow:(NSNotification *)notification {
    CGSize kbSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _bottomConstraint.constant = kbSize.height;
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)saveButtonPressed:(id)sender {
    AIBIdea *idea = [[AIBIdea alloc] initWithText:[_mainTextView text]];
    [idea setAuthor:[[AIBIdeaZoneManager sharedInstance] preferredUsername]];
    if(_lastLocation) {
        [idea setCoordinate:_lastLocation.coordinate];
        if(_lastPlacemark) {
            NSString *city = [[_lastPlacemark addressDictionary] objectForKey:(NSString *)kABPersonAddressCityKey];
            NSString *countryName = _lastPlacemark.country;
            NSString *stateProvince = _lastPlacemark.subAdministrativeArea;
            NSString *name;

            if(city) {
                name = [NSString stringWithFormat:@"%@, %@", city, countryName];
            } else {
                name = [NSString stringWithFormat:@"%@, %@", stateProvince, countryName];
            }

            [idea setCoordinateName:name];
        }
    }

    DBError *error;
    [[AIBIdeaZoneManager sharedInstance] createIdea:idea inZone:_zone error:&error];

    if(error) {
        [AIBAlerts showErrorAlert:error];
    } else {
        
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
}
@end
