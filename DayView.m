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
@synthesize informationSheet;
@synthesize oldInformationSheet;
@synthesize firstTouch;
@synthesize panRecognizer;
@synthesize sheetOrigin;

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
    UINib *sheetNib = [UINib nibWithNibName: @"DayViewInformationSheet" bundle: nil];
    [self setInformationSheet: [[sheetNib instantiateWithOwner: self options: nil] objectAtIndex: 0]];
    CGPoint infSheetCenter = {[self taskBriefView].frame.size.width + [self informationSheet].frame.size.width/2, [self informationSheet].frame.size.height/2};
    [[self informationSheet] setCenter: infSheetCenter];
    [[[[self informationSheet] descriptionLabel]layer] setBorderWidth: 1];
    [[[self informationSheet] descriptionLabel]setText: @""];
    [[[self informationSheet] titleLabel]setText: @""];
    [[[self informationSheet] durationLabel]setText: @""];
    [[[self informationSheet] statusLabel]setText: @""];
    [self addSubview: informationSheet];
//    [[self layer] setCornerRadius: 5];
    [[self taskBriefView] setDelegate: self];
    [[self taskBriefView] setDataSource: self];
    [[self taskBriefView] setOpaque: NO];
    
    [self setPanRecognizer: [[UIPanGestureRecognizer alloc] initWithTarget: self action:@selector(handlePan:)]];
    [self addGestureRecognizer: panRecognizer];
    [self setOldInformationSheet: nil];
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
}

- (void) handlePan: (UIPanGestureRecognizer*) recognizer
{
    NSLog(@"Pan detected.");
    switch ([recognizer state]) {
        case UIGestureRecognizerStateBegan:
        {
            if ([recognizer locationInView: [recognizer view]].x < [[self taskBriefView] frame].size.width - 20) {
//                [[self panRecognizer] setCancelsTouchesInView: YES];
                [[self panRecognizer] setEnabled: NO];
                return;
            }
            if ([self informationSheet] == NULL) {
                NSMutableArray *forDeleting = [NSMutableArray array];
                for (UIView *subview in [self subviews]) {
                    if ([subview isKindOfClass: [DayViewInformationSheet class]]) {
                        [forDeleting addObject: subview];
                    }
                }
                for (UIView *subview in forDeleting) {
                    [subview removeFromSuperview];
                }
                [self awakeFromNib];
            }
            [self setOldInformationSheet: [self informationSheet]];
            UINib *sheetNib = [UINib nibWithNibName: @"DayViewInformationSheet" bundle: nil];
            [self setInformationSheet: [[sheetNib instantiateWithOwner: self options: nil] objectAtIndex: 0]];
            CGPoint infSheetCenter = {[[self oldInformationSheet] center].x + [[self oldInformationSheet] frame].size.width, 
                [[self oldInformationSheet] center].y};
            [[self informationSheet] setCenter: infSheetCenter];
            [[[self informationSheet] layer] setBorderWidth: 1.0];
            [self setFirstTouch: [recognizer locationInView: [recognizer view]]];
            [self setSheetOrigin: [[self oldInformationSheet] frame].origin];
            [self sendSubviewToBack: [self oldInformationSheet]];
            [self addSubview: [self informationSheet]];
            [self sendSubviewToBack: [self informationSheet]];
            break;
        }
            
        case UIGestureRecognizerStateChanged:
        { 
            CGRect oldSheetFrame = {{[self sheetOrigin].x - [self firstTouch].x + [recognizer locationInView: [recognizer view]].x,
            [self sheetOrigin].y},
            [[self oldInformationSheet] frame].size};
            [[self oldInformationSheet] setFrame: oldSheetFrame];
            if ([self sheetOrigin].x - oldSheetFrame.origin.x >= 0) {
                CGRect infromationSheetFrame = {{oldSheetFrame.origin.x + oldSheetFrame.size.width, oldSheetFrame.origin.y}, oldSheetFrame.size};
                [[self informationSheet] setFrame: infromationSheetFrame];
                [[self informationSheet] setTargetDate: [[[self oldInformationSheet] targetDate] dateByAddingTimeInterval: 86400]];
//                [self setTargetDate: [[self oldInformationSheet]]
            } else {
                CGRect infromationSheetFrame = {{oldSheetFrame.origin.x - oldSheetFrame.size.width, oldSheetFrame.origin.y}, oldSheetFrame.size};
                [[self informationSheet] setFrame: infromationSheetFrame];
                [[self informationSheet] setTargetDate: [[[self oldInformationSheet] targetDate] dateByAddingTimeInterval: -86400]];
            }
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        {
            [[self panRecognizer] setCancelsTouchesInView: YES];
            [[self panRecognizer] setEnabled: NO];
            if ([[self oldInformationSheet] center].x <= [self center].x)
            {
                [UIView animateWithDuration: 0.5 animations:^{
                    [[self oldInformationSheet] setCenter: [[self taskBriefView] center]];
                    CGRect sheetFrame = {[self sheetOrigin], [[self informationSheet] frame].size};
                    [[self informationSheet] setFrame: sheetFrame];     
//                    [[self informationSheet] setTargetDate: [[[self oldInformationSheet] targetDate] dateByAddingTimeInterval: 86400]];
                    [[self taskBriefView] reloadData];
                } completion:^(BOOL finished) {
                    if (finished) {
                        [[self oldInformationSheet] removeFromSuperview];
//                        [self setOldInformationSheet: nil];
                        [[self taskBriefView] reloadData];
                    }
                }];
            } else if (([[self oldInformationSheet] center].x > [self center].x) && ([[self oldInformationSheet] center].x < [self bounds].size.width - 50)) {
                [UIView animateWithDuration: 0.5 animations:^{
                    CGRect sheetFrame = {[self sheetOrigin], [[self informationSheet] frame].size};
                    [[self oldInformationSheet] setFrame: sheetFrame];     
                    NSInteger mult = ([[self informationSheet] frame].origin.x - [self oldInformationSheet].frame.origin.x) < 0 ? -1 : 1;
                    CGRect infromationSheetFrame = {{[[self oldInformationSheet] frame].origin.x + [[self oldInformationSheet] frame].size.width * mult, 
                                                     [[self oldInformationSheet] frame].origin.y}, [[self oldInformationSheet] frame].size};
                    [[self informationSheet] setFrame: infromationSheetFrame];
                } completion:^(BOOL finished) {
                    if (finished) {
                        [[self informationSheet] removeFromSuperview];
                        [self setInformationSheet: [self oldInformationSheet]];
//                        [self setOldInformationSheet: nil];
                    }
                }];
            } else {
                [UIView animateWithDuration: 0.5 animations:^{
                    NSInteger mult = ([[self informationSheet] frame].origin.x - [self oldInformationSheet].frame.origin.x) < 0 ? 1 : -1;
                    CGRect sheetFrame = {[self sheetOrigin], [[self informationSheet] frame].size};
                    [[self informationSheet] setFrame: sheetFrame];     
                    CGRect oldSheetFrame = {{[[self informationSheet] frame].origin.x + [[self informationSheet] frame].size.width * mult, 
                        [[self oldInformationSheet] frame].origin.y}, [[self oldInformationSheet] frame].size};
                    [[self oldInformationSheet] setFrame: oldSheetFrame];
//                    [[self informationSheet] setTargetDate: [[[self oldInformationSheet] targetDate] dateByAddingTimeInterval: -86400]];
                } completion:^(BOOL finished) {
                    if (finished) {
                        [[self oldInformationSheet] removeFromSuperview];
//                        [self setOldInformationSheet: nil];
                        [[self taskBriefView] reloadData];
                    }
                }];
            }
            [[self panRecognizer] setCancelsTouchesInView: NO];
            [[self panRecognizer] setEnabled: YES];
            break;
        }
        default:
            break;
    }
    [[self panRecognizer] setEnabled: YES];
    NSLog(@"\nBound x: %f\nOld: %f\nNew: %f", [self bounds].size.width, [[self oldInformationSheet] center].x, [[self informationSheet] center].x);
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


@end
