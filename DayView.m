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
@synthesize informationSheet;
@synthesize oldInformationSheet;
@synthesize informationSheetScroll;
@synthesize informationSheets;

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
    [[(AppDelegate*)[[UIApplication sharedApplication] delegate] tableViewsToBeUpdated] addObject: [self taskBriefView]];
    UINib *sheetNib = [UINib nibWithNibName: @"DayViewInformationSheet" bundle: nil];
    [self setInformationSheet: [[sheetNib instantiateWithOwner: self options: nil] objectAtIndex: 0]];
//    [[self informationSheet] setCenter: [self convertPoint: [[self informationSheetScroll] center] toView: [self informationSheetScroll]]];
    CGRect frame = {{0,0}, [[self informationSheet] frame].size};
    [[self informationSheet] setFrame: frame];
    [[self taskBriefView] setDelegate: self];
    [[self taskBriefView] setDataSource: self];
    [[self taskBriefView] setOpaque: NO];
    [self setOldInformationSheet: nil];
    [[self informationSheetScroll] setDelegate: self];
//    [[self informationSheetScroll] setPagingEnabled: YES];
    [[self informationSheetScroll] addSubview: informationSheet];
    CGRect infScrollFrame = {[[self informationSheetScroll] frame].origin, [[self informationSheet] frame].size};
    [[self informationSheetScroll] setBounds: infScrollFrame];
    [[self informationSheetScroll] setContentSize: CGSizeMake([[self informationSheet] bounds].size.width * 2, [[self informationSheet] bounds].size.height)];
    [self setInformationSheets: [NSMutableArray arrayWithObject: [self informationSheet]]];
}

- (void) testFunc
{
    NSLog(@"Test func");
    CGPoint scrollContentOffset = {CGRectGetMaxX([[[self informationSheets] lastObject] frame]), [[[self informationSheets] lastObject] frame].origin.y};
    CGRect scrollBounds = [[self informationSheetScroll] bounds];
    scrollBounds.origin = scrollContentOffset;
    [[self informationSheetScroll] setBounds: scrollBounds];
    //            CGPoint newInfPoint = {0, 0};
    CGRect lastSheetFrame = [[[self informationSheets] lastObject] frame];
    lastSheetFrame.origin = scrollContentOffset;
    [[[self informationSheets] lastObject] setFrame: lastSheetFrame];
    [self addInformationSheetAtPoint: CGPointZero WithDate: [[[[self informationSheets] lastObject] targetDate] dateByAddingTimeInterval: -86400]];
    NSArray *subviews = [[self informationSheetScroll] subviews];
    for (UIView *view in subviews) {
        if ([view isKindOfClass: [DayViewInformationSheet class]]) {
            NSLog(@"TargetDate: %@ (%f,%f)", [(DayViewInformationSheet*)view targetDate], [view frame].origin.x, [view frame].origin.y);
        }
    }
    NSLog(@"Current bounds are: (%f,%f)", [[self informationSheetScroll] bounds].origin.x, [[self informationSheetScroll] bounds].origin.y);
    [self setTag: 0];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) setTargetDate: (NSDate*) targetDate
{
    [[self informationSheet] setTargetDate: targetDate];
    NSManagedObjectContext *context = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSPredicate *predicate = [NSPredicate 
                              predicateWithFormat: @"\
                              (startDate >= %f AND endDate < %f) OR \
                              (startDate <= %f AND endDate > %f) OR \
                              (startDate < %f AND (endDate > %f AND endDate < %f)) OR \
                              (endDate > %f AND (startDate > %f AND startDate < %f))", 
                              [[[self informationSheet] targetDate] timeIntervalSince1970], 
                              [[[self informationSheet] targetDate] timeIntervalSince1970] + 86400,
                              [[[self informationSheet] targetDate] timeIntervalSince1970], 
                              [[[self informationSheet] targetDate] timeIntervalSince1970] + 86400,
                              [[[self informationSheet] targetDate] timeIntervalSince1970] + 86400, 
                              [[[self informationSheet] targetDate] timeIntervalSince1970],
                              [[[self informationSheet] targetDate] timeIntervalSince1970] + 86400,
                              [[[self informationSheet] targetDate] timeIntervalSince1970] + 86400, 
                              [[[self informationSheet] targetDate] timeIntervalSince1970],
                              [[[self informationSheet] targetDate] timeIntervalSince1970] + 86400];
    
    NSSortDescriptor *descr = [[NSSortDescriptor alloc] initWithKey: @"startDate" ascending: YES];
//    double testStart = [[[self informationSheet] targetDate] timeIntervalSince1970];
//    double testEnd = [[[self informationSheet] targetDate] timeIntervalSince1970] + 86400;
//    NSLog(@"testStart = %@\ntestEnd = %@", [NSDate dateWithTimeIntervalSince1970: testStart], [NSDate dateWithTimeIntervalSince1970: testEnd]);
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName: @"Event"];
    [request setPredicate: predicate];
    [request setSortDescriptors: [NSArray arrayWithObject: descr]];
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] setFetchedResultsController: [[NSFetchedResultsController alloc] 
                                                              initWithFetchRequest: request 
                                                              managedObjectContext: context 
                                                              sectionNameKeyPath: [NSString 
                                                                                   stringWithFormat: @"startDate"] 
                                                              cacheName: @"dayView"]]; //.compare(%f)", [[[self informationSheet] targetDate] timeIntervalSince1970]] cacheName: @"dayView"]];
    NSError* error;
    [[(AppDelegate*)[[UIApplication sharedApplication] delegate] fetchedResultsController] performFetch: &error];
    if (error) {
        NSLog(@"Core Data fetching error: %@", error);
    }
    [[self taskBriefView] reloadData];
}

- (DayViewInformationSheet*) addInformationSheetAtPoint:(CGPoint) point
{
    UINib *sheetNib = [UINib nibWithNibName: @"DayViewInformationSheet" bundle: nil];
    DayViewInformationSheet *sheet = [[sheetNib instantiateWithOwner: self options: nil] objectAtIndex: 0];
    CGRect sheetFrame = {point, [sheet frame].size};
    [sheet setFrame: sheetFrame];
    [[self informationSheetScroll] addSubview: sheet];
    [[self informationSheets] addObject: sheet];
    return sheet;
}

- (void) addInformationSheetAtPoint:(CGPoint) point WithDate:(NSDate*) date
{
    DayViewInformationSheet *inf = [self addInformationSheetAtPoint: point];
    [inf setTargetDate: date];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    Event *cellInfo = [[(AppDelegate*)[[UIApplication sharedApplication] delegate] fetchedResultsController] objectAtIndexPath: indexPath];
    [[cell textLabel] setText: [cellInfo eventTitle]];
    [[cell detailTextLabel] setText: [cellInfo eventDescription]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSLog(@"Section : %@", [[[[self fetchedResultsController] sections] objectAtIndex: section] name]);
    
    return [[[[(AppDelegate*)[[UIApplication sharedApplication] delegate] fetchedResultsController] sections] objectAtIndex: section] numberOfObjects];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    NSLog(@"There are %d sections.", [[[self fetchedResultsController] sections] count]);
    return [[[(AppDelegate*)[[UIApplication sharedApplication] delegate] fetchedResultsController] sections] count];
//    return 2; //Started at targetDate; Started before targetDate;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event *event = [[(AppDelegate*)[[UIApplication sharedApplication] delegate] fetchedResultsController] objectAtIndexPath: indexPath];
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
    if (([[event startDate] doubleValue] > [[[self informationSheet] targetDate] timeIntervalSince1970]) && 
        ([[event endDate] doubleValue] < [[[self informationSheet] targetDate] timeIntervalSince1970] + 86400)) {
        [formatter setDateFormat: @"HH:mm"];
    } else {
        [formatter setDateFormat: @"dd MMMM HH:mm"];
    }
    [[[self informationSheet] durationLabel]setText: [NSString stringWithFormat: @"%@ – %@", 
                                    [formatter stringFromDate: [NSDate dateWithTimeIntervalSince1970: [[event startDate] doubleValue]]], 
                                    [formatter stringFromDate: [NSDate dateWithTimeIntervalSince1970: [[event endDate] doubleValue]]]]]; 
    [[[self informationSheet] durationLabel]sizeToFit];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"We are in: %s", __FUNCTION__);
//    NSLog(@"Content offset is: (%f,%f)", [[self informationSheetScroll] contentOffset].x, [[self informationSheetScroll] contentOffset].y);
    CGRect lastSubviewFrame = [[[self informationSheets] lastObject] frame];
//    NSLog(@"bound is: %f", CGRectGetMaxX(lastSubviewFrame));
    //That's for determine where last sheet lays: on the left or on the right side.
    int lastSheetSubMainSheet = [[self informationSheet] center].x - [[[self informationSheets] lastObject] center].x;
//    NSLog(@"\nInfSheet x is: %f\ lastSheet x is% f", )
    if ([[self informationSheetScroll] contentOffset].x < 0) {
        if (([[self informationSheetScroll] contentOffset].x < [[[self informationSheets] lastObject] frame].origin.x) && (lastSheetSubMainSheet >= 0)) {
            if ([self tag] == 5) return;
            NSLog(@"\noffset is: %f\nlastX is: %f\n", [[self informationSheetScroll] contentOffset].x, [[[self informationSheets] lastObject] frame].origin.x);
            CGPoint scrollContentOffset = {CGRectGetMaxX([[[self informationSheets] lastObject] frame]), [[[self informationSheets] lastObject] frame].origin.y};
            CGRect lastSheetFrame = [[[self informationSheets] lastObject] frame];
            lastSheetFrame.origin = scrollContentOffset;
            CGRect scrollBounds = [[self informationSheetScroll] bounds];
            scrollBounds.origin = scrollContentOffset;
            CGSize contentSize = {lastSubviewFrame.size.width * ([[self informationSheets] count]), lastSubviewFrame.size.height};
            
            [[self informationSheetScroll] setContentSize: contentSize];
            [[self informationSheetScroll] setBounds: scrollBounds];
            [[[self informationSheets] lastObject] setFrame: lastSheetFrame];
            CGPoint newPoint = {[[[self informationSheets] lastObject] frame].origin.x - [[informationSheets lastObject] frame].size.width, 
                                [[[self informationSheets] lastObject] frame].origin.y};
            [self addInformationSheetAtPoint: newPoint WithDate: [[[[self informationSheets] lastObject] targetDate] dateByAddingTimeInterval: -86400]];
            [self setTag: [self tag] + 1];
        }
    } else if ([[self informationSheetScroll] contentOffset].x > 0) {
        if (([[self informationSheetScroll] contentOffset].x > [[[self informationSheets] lastObject] frame].origin.x) && (lastSheetSubMainSheet <= 0)) {
            NSLog(@"Went right");
            CGSize contentSize = {lastSubviewFrame.size.width * ([[self informationSheets] count] + 1), lastSubviewFrame.size.height};
            [[self informationSheetScroll] setContentSize: contentSize];
            [self addInformationSheetAtPoint: CGPointMake(CGRectGetMaxX(lastSubviewFrame), lastSubviewFrame.origin.y) 
                                    WithDate: [[[[self informationSheets] lastObject] targetDate] dateByAddingTimeInterval: 86400]];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    NSLog(@"We are in: %s", __FUNCTION__);
//    NSLog(@"Scroll bounds are: ((%f; %f), (%f; %f))", 
//          [[self informationSheetScroll] bounds].origin.x, 
//          [[self informationSheetScroll] bounds].origin.y, 
//          [[self informationSheetScroll] bounds].size.width, 
//          [[self informationSheetScroll] bounds].size.height);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{   
//    NSLog(@"We are in: %s", __FUNCTION__);
//    NSLog(@"Will decelerate: %d", decelerate);
    if (!decelerate) {
        [self showOnlyVisibleSheetOnScrollView: [self informationSheetScroll]  animated: YES];

//        [[self informationSheetScroll] setContentSize: contentSize];
        return;               
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    NSLog(@"We are in: %s", __FUNCTION__);
    
    [self showOnlyVisibleSheetOnScrollView: [self informationSheetScroll] animated: YES];
//    [[self informationSheetScroll] setContentSize: contentSize];
    return;
}


- (void) showOnlyVisibleSheetOnScrollView: (UIScrollView*) scrollView animated: (BOOL) animated
{
    for (DayViewInformationSheet *sheet in [self informationSheets]) {
        if (((CGRectGetMinX([sheet frame]) < CGRectGetMidX([scrollView bounds]))   && 
             (CGRectGetMinX([sheet frame]) >= CGRectGetMinX([scrollView bounds]))) || 
            ((CGRectGetMaxX([sheet frame]) > CGRectGetMidX([scrollView bounds]))   &&
             (CGRectGetMaxX([sheet frame]) <= CGRectGetMaxX([scrollView bounds])))) {
//               CGPoint scrollContentOffset = CGPointMake(CGRectGetMinX([sheet frame]), CGRectGetMinY([sheet frame]));
                [self setInformationSheet: sheet];
                [self setTargetDate: [sheet targetDate]];
            } else {
                [sheet removeFromSuperview];
            }
    }
    CGRect rect = {{0,0}, [[self informationSheet] frame].size};
    [UIView beginAnimations: nil context: NULL];
    [UIView setAnimationDuration: 0.5];
    [[self informationSheet] setFrame: rect];
    [[self informationSheetScroll] setContentOffset: rect.origin];
    [UIView commitAnimations];
    CGSize contentSize = {[[self informationSheet] frame].size.width * 2, 
        [[self informationSheet] frame].size.height};
    [[self informationSheetScroll] setContentSize: contentSize];  
    NSLog(@"Sheet is: %@", [self informationSheet]);
    [[self informationSheets] removeAllObjects];
    [[self informationSheets] addObject: [self informationSheet]];
}


@end