//
//  DayView.m
//  MYCalendar
//
//  Created by Alexey on 10.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DayView.h"
#import "AppDelegate.h"
#import "Event.h"
#import "DayViewInformationSheet.h"
#import <QuartzCore/QuartzCore.h>

@implementation DayView
@synthesize taskBriefView;
@synthesize taskDetailedView;
@synthesize fetchedResultsController;
@synthesize targetDate = _targetDate;
@synthesize informationSheet;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}


- (void) awakeFromNib
{
    [super awakeFromNib];
    UINib *test = [UINib nibWithNibName: @"DayViewInformationSheet" bundle: nil];
    [self setInformationSheet: [[test instantiateWithOwner: self options: nil] objectAtIndex: 0]];
    CGPoint infSheetCenter = {[self taskBriefView].frame.size.width + [self informationSheet].frame.size.width/2, [self informationSheet].frame.size.height/2};
    [[self informationSheet] setCenter: infSheetCenter];
    [self addSubview: informationSheet];
//    [[self layer] setCornerRadius: 5];
    [[[[self informationSheet] descriptionLabel]layer] setBorderWidth: 1];
    [[self taskBriefView] setDelegate: self];
    [[self taskBriefView] setDataSource: self];
    [[[self informationSheet] descriptionLabel]setText: @""];
    [[[self informationSheet] titleLabel]setText: @""];
    [[[self informationSheet] durationLabel]setText: @""];
    [[[self informationSheet] statusLabel]setText: @""];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) setTargetDate:(NSDate *)targetDate
{
    _targetDate = targetDate;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName: @"Event"];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *components = [gregorian 
                                    components: NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit
                                    fromDate: _targetDate];
    [components setHour: 0];
    _targetDate = [gregorian dateFromComponents: components];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [[[self informationSheet] mainDateLabel]setText: [NSString stringWithFormat: @"%d %@", [components day], [[formatter monthSymbols] objectAtIndex: [components month] - 1]]];
    [[[self informationSheet] secondaryDateLabel]setText: [NSString stringWithFormat: @"%@ %d", [[formatter weekdaySymbols] objectAtIndex: [components weekday] - 1], [components year]]];
    CGRect rect = {{[[[self informationSheet] mainDateLabel]frame].origin.x, [[[self informationSheet] secondaryDateLabel]frame].origin.y}, [[[self informationSheet] secondaryDateLabel]frame].size};
//    [[[self informationSheet] secondaryDateLabel]setFrame: rect];
    NSManagedObjectContext *context = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSPredicate *predicate = [NSPredicate 
                              predicateWithFormat: @"\
                              (startDate >= %f AND endDate < %f) OR \
                              (startDate <= %f AND endDate > %f) OR \
                              (startDate < %f AND (endDate > %f AND endDate < %f)) OR \
                              (endDate > %f AND (startDate > %f AND startDate < %f))", 
                              [_targetDate timeIntervalSince1970], 
                              [_targetDate timeIntervalSince1970] + 86400,
                              [_targetDate timeIntervalSince1970], 
                              [_targetDate timeIntervalSince1970] + 86400,
                              [_targetDate timeIntervalSince1970] + 86400, 
                              [_targetDate timeIntervalSince1970],
                              [_targetDate timeIntervalSince1970] + 86400,
                              [_targetDate timeIntervalSince1970] + 86400, 
                              [_targetDate timeIntervalSince1970],
                              [_targetDate timeIntervalSince1970] + 86400];

    NSSortDescriptor *descr = [[NSSortDescriptor alloc] initWithKey: @"startDate" ascending: YES];
    double testStart = [_targetDate timeIntervalSince1970];
    double testEnd = [_targetDate timeIntervalSince1970] + 86400;
    NSLog(@"testStart = %@\ntestEnd = %@", [NSDate dateWithTimeIntervalSince1970: testStart], [NSDate dateWithTimeIntervalSince1970: testEnd]);
    [request setPredicate: predicate];
    [request setSortDescriptors: [NSArray arrayWithObject: descr]];
    [self setFetchedResultsController: [[NSFetchedResultsController alloc] 
                                        initWithFetchRequest: request 
                                        managedObjectContext: context 
                                        sectionNameKeyPath: [NSString 
                                                             stringWithFormat: @"startDate"] 
                                                                    cacheName: @"dayView"]]; //.compare(%f)", [_targetDate timeIntervalSince1970]] cacheName: @"dayView"]];
    NSError* error;
    [[self fetchedResultsController] performFetch: &error ];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    Event *cellInfo = [[self fetchedResultsController] objectAtIndexPath: indexPath];
    [[cell textLabel] setText: [cellInfo eventTitle]];
    [[cell detailTextLabel] setText: [cellInfo eventDescription]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Section : %@", [[[[self fetchedResultsController] sections] objectAtIndex: section] name]);
    
    return [[[[self fetchedResultsController] sections] objectAtIndex: section] numberOfObjects];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"There are %d sections.", [[[self fetchedResultsController] sections] count]);
    return [[[self fetchedResultsController] sections] count];
//    return 2; //Started at targetDate; Started before targetDate;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event *event = [[self fetchedResultsController] objectAtIndexPath: indexPath];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLog(@"Current locale is: %@", [[NSLocale currentLocale] localeIdentifier]);
//    [formatter setLocale: [NSLocale currentLocale]];
    [formatter setDateFormat: @"dd MMMM"];
    NSLog(@"\nEvent '%@' \n %@ - %@", [event eventTitle], 
                                      [formatter stringFromDate: [NSDate dateWithTimeIntervalSince1970: [[event startDate] doubleValue]]], 
                                      [formatter stringFromDate: [NSDate dateWithTimeIntervalSince1970: [[event endDate] doubleValue]]]);
    [[[self informationSheet] titleLabel]setText: [event eventTitle]];
    [[[self informationSheet] titleLabel]sizeToFit];
    [[[self informationSheet] descriptionLabel]setText: [event eventDescription]];
    if (([[event startDate] doubleValue] > [_targetDate timeIntervalSince1970]) && ([[event endDate] doubleValue] < [_targetDate timeIntervalSince1970] + 86400)) {
        [formatter setDateFormat: @"HH:mm"];
    } else {
        [formatter setDateFormat: @"dd MMMM HH:mm"];
    }
    [[[self informationSheet] durationLabel]setText: [NSString stringWithFormat: @"%@ – %@", 
                                    [formatter stringFromDate: [NSDate dateWithTimeIntervalSince1970: [[event startDate] doubleValue]]], 
                                    [formatter stringFromDate: [NSDate dateWithTimeIntervalSince1970: [[event endDate] doubleValue]]]]]; 
    [[[self informationSheet] durationLabel]sizeToFit];
}


@end
