//
//  TaskDetailedView.m
//  MYCalendar
//
//  Created by Alexey on 10.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TaskDetailedView.h"
#import "TaskMarkRectangle.h"
#import "AppDelegate.h"
#import "Event.h"

@implementation TaskDetailedView
@synthesize taskTable;
@synthesize fetchedResultsController;
@synthesize toolbar;
@synthesize markRectangles;
@synthesize datePickPopover;
@synthesize addTaskBarButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) awakeFromNib
{
    [[(AppDelegate*)[[UIApplication sharedApplication] delegate] tableViewsToBeUpdated] addObject: self];
    [[self taskTable] setDelegate: self];
    [[self taskTable] setDataSource: self];
    [self setMarkRectangles: [NSMutableArray array]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 24; //24 hours in a day.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"Cell"];
    [[cell textLabel] setText: [NSString stringWithFormat: @"%0d:00 – %0d:00", indexPath.row, indexPath.row+1]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (IBAction)addTask:(id)sender 
{
    if ([[self datePickPopover] isPopoverVisible]) {
        [[self datePickPopover] dismissPopoverAnimated: YES];
    } else {
        // Apple documentation advices to cache popovers, so I've included commented code that does that. Maybe someone will need that.
        // But in my case recreating the popover every time is cheaper than moving every element to initial positions every time.
        //*    if ([self datePickPopover] == nil) 
        //*    {
        UINib *popoverNib = [UINib nibWithNibName: @"DatePickPopover" bundle: nil];
        UIViewController *content = [[popoverNib instantiateWithOwner: self options: nil] objectAtIndex: 0];
        [self setDatePickPopover: [[UIPopoverController alloc] initWithContentViewController: content]];
        [[(AppDelegate*)[[UIApplication sharedApplication] delegate] calendarViewController] performSelector: @selector(setPopover:) withObject: [self datePickPopover]];
        //*    }
        [[self datePickPopover] presentPopoverFromBarButtonItem: [self addTaskBarButton] permittedArrowDirections: UIPopoverArrowDirectionAny animated: YES];
    }
}

- (void) drawTaskMarkRectangles
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    //Number of minutes from which the rectangles are horizontal to each other
    int offsetBeginMinutes = 6;
    //Offset point of mark rectangle 
    CGPoint markRectOffset = {5, 5}; 
    //Array for keeping startDate of events starting at some hour
    NSMutableArray *hours = [NSMutableArray arrayWithCapacity: 24];
    for (int i = 0; i < 24; ++i) {
        [hours addObject: [NSMutableArray array]];
    }
    for (Event* event in [[(AppDelegate*)[[UIApplication sharedApplication] delegate] fetchedResultsController] fetchedObjects])
    {
        NSDateComponents *startComponents = [gregorian 
                                             components: NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit 
                                             fromDate: [NSDate dateWithTimeIntervalSince1970: [[event startDate] doubleValue]]];
        NSDateComponents *endComponents = [gregorian 
                                             components: NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit 
                                             fromDate: [NSDate dateWithTimeIntervalSince1970: [[event endDate] doubleValue]]];
        CGRect startCellFrame = [[[self taskTable] 
                                  cellForRowAtIndexPath: [NSIndexPath 
                                                          indexPathForRow: [startComponents hour]
                                                          inSection: 1]] frame];
        CGRect endCellFrame = [[[self taskTable] 
                                  cellForRowAtIndexPath: [NSIndexPath 
                                                          indexPathForRow: [endComponents hour]
                                                          inSection: 1]] frame];
        CGRect markRectFrame = {
            {   startCellFrame.origin.x + markRectOffset.x, 
                startCellFrame.origin.y + startCellFrame.size.height * ([startComponents minute]*60 + [startComponents second])/3600},
            {   startCellFrame.size.width - markRectOffset.x,
                endCellFrame.origin.y + endCellFrame.size.height * ([endComponents minute]*60 + [endComponents second])/3600}};
        
        if ([[hours objectAtIndex: [startComponents hour]] count] != 0)
        {
            //1 hour == 100% of startCellFrame.size.height, so
            double offsetBeginPixels = (offsetBeginMinutes * 60)/startCellFrame.size.height;
            //Array for keeping 
            NSArray *horizontalRects = [NSArray array];
            for (TaskMarkRectangle* anotherRect in [hours objectAtIndex: [startComponents hour]]) 
            {
                if (abs([anotherRect frame].origin.y - markRectFrame.origin.y) < offsetBeginPixels) 
                {
                    
                }
            }
        }
            
    }
}

@end
