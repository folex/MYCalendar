//
//  DayViewInformationSheet.m
//  MYCalendar
//
//  Created by Alexey on 12.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DayViewInformationSheet.h"
#import "AppDelegate.h"
#import "DayView.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreData/CoreData.h>

@implementation DayViewInformationSheet
@synthesize mainDateLabel;
@synthesize secondaryDateLabel;
@synthesize durationLabel;
@synthesize statusLabel;
@synthesize titleLabel;
@synthesize descriptionLabel;
@synthesize targetDate = _targetDate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[self mainDateLabel] setText: @""];
        [[self secondaryDateLabel] setText: @""];
        [[self durationLabel] setText: @""];
        [[self statusLabel] setText: @""];
        [[self titleLabel] setText: @""];
        [[self descriptionLabel] setText: @""];
    }
    return self;
}

- (void) awakeFromNib
{
    [[self mainDateLabel] setText: @""];
    [[self secondaryDateLabel] setText: @""];
    [[self durationLabel] setText: @""];
    [[self statusLabel] setText: @""];
    [[self titleLabel] setText: @""];
    [[self descriptionLabel] setText: @""];
    [[self layer] setBorderWidth: 1.0];
    [[[self descriptionLabel] layer] setBorderWidth: 1.0];
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
    if (targetDate == nil) {
        targetDate = [NSDate date];
    }
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *components = [gregorian 
                                    components: NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit
                                    fromDate: targetDate];
    [components setHour: 0];
    [components setMinute: 0];
    [components setSecond: 0];
    if ((_targetDate != nil) && [_targetDate compare: [gregorian dateFromComponents: components]] == NSOrderedSame) {
        return;
    }
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName: @"Event"];
    _targetDate = [gregorian dateFromComponents: components];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [[self mainDateLabel] setText: [NSString stringWithFormat: @"%d %@", [components day], [[formatter monthSymbols] objectAtIndex: [components month] - 1]]];
    [[self secondaryDateLabel] setText: [NSString stringWithFormat: @"%@ %d", [[formatter weekdaySymbols] objectAtIndex: [components weekday] - 1], [components year]]];
    
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
    [(DayView*)[self superview] setFetchedResultsController: [[NSFetchedResultsController alloc] 
                                        initWithFetchRequest: request 
                                        managedObjectContext: context 
                                        sectionNameKeyPath: [NSString 
                                                             stringWithFormat: @"startDate"] 
                                        cacheName: @"dayView"]]; //.compare(%f)", [_targetDate timeIntervalSince1970]] cacheName: @"dayView"]];
    NSError* error;
    [[(DayView*)[self superview] fetchedResultsController] performFetch: &error];
    if (error) {
        NSLog(@"Core Data fetching error: %@", error);
    }
}

@end
