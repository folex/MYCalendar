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
    NSLog(@"Setting target date!");
    if (targetDate == nil) {
        targetDate = [NSDate date];
    }
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *components = [gregorian 
                                    components: NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit
                                    fromDate: targetDate];
    if ((_targetDate != nil) && [_targetDate compare: [gregorian dateFromComponents: components]] == NSOrderedSame) {
        return;
    }
    _targetDate = [[gregorian dateFromComponents: components] dateByAddingTimeInterval:[[NSTimeZone localTimeZone]secondsFromGMT]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [[self mainDateLabel] setText: [NSString stringWithFormat: @"%d %@", [components day], [[formatter monthSymbols] objectAtIndex: [components month] - 1]]];
    [[self secondaryDateLabel] setText: [NSString stringWithFormat: @"%@ %d", [[formatter weekdaySymbols] objectAtIndex: [components weekday] - 1], [components year]]];
}

@end
