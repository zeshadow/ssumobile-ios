//
//  SSUCalendarEventDetail.m
//  SSUMobile
//
//  Created by Eric Amorde on 9/28/14.
//  Copyright (c) 2014 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUCalendarEventDetail.h"
#import "SSUEvent.h"
#import "NSString+html.h"
#import "SSULogging.h"

@import EventKit;
@import EventKitUI;

static NSString * DEFAULT_DESCRIPTION = @"No description for this event";

@interface SSUCalendarEventDetail() <EKEventEditViewDelegate>

@property (nonatomic) IBOutlet UILabel * titleLabel;
@property (nonatomic) IBOutlet UILabel * categoryLabel;
@property (nonatomic) IBOutlet UILabel * dateLabel;
@property (nonatomic) IBOutlet UILabel * locationLabel;
@property (nonatomic) IBOutlet UIWebView * descriptionWebView;

- (IBAction)addToCalendarAction:(id)sender;

@end

@implementation SSUCalendarEventDetail

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.title;
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    [self updateDisplay];
    SSULogDebug(@"%@",self.event);
}

- (void) updateDisplay
{
    self.titleLabel.text = self.event.title;
    self.categoryLabel.text = self.event.category;
    self.locationLabel.text = [self.event.location stringByDecodingXMLEntities];
    if (SSUIsEmptyString(self.locationLabel.text)) {
        self.locationLabel.text = @"No location provided";
    }
    self.dateLabel.text = [NSDateFormatter localizedStringFromDate:self.event.startDate
                                                         dateStyle:NSDateFormatterShortStyle
                                                         timeStyle:NSDateFormatterShortStyle];
    if (self.event.summary == nil) {
        [self.descriptionWebView loadHTMLString:DEFAULT_DESCRIPTION baseURL:nil];
    }
    else {
        [self.descriptionWebView loadHTMLString:self.event.summary baseURL:nil];
    }
}

#pragma mark -
#pragma mark - EventKit

- (void) addToCalendarAction:(id)sender
{
    EKEventEditViewController * editView = [[EKEventEditViewController alloc] init];
    editView.editViewDelegate = self;
    EKEventStore * eventStore = [[EKEventStore alloc] init];
    EKEvent * event = [EKEvent eventWithEventStore:eventStore];
    editView.event = event;
    editView.eventStore = eventStore;
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Access Denied"
                                                             message:@"To add SSU events to your calendar, grant SSUMobile access to your calendar in your phone's settings"
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
            [alert show];
        }
        else {
            [self presentViewController:editView animated:YES completion:NULL];
        }
    }];
    
}

- (void) eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
