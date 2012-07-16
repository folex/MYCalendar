//
//  ViewController.m
//  MYCalendar
//
//  Created by Alexey on 10.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "DayView.h"
#import "Event.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreData/CoreData.h>

@interface ViewController ()

@end

@implementation ViewController
@synthesize fetchedResultsController;

- (void)viewDidLoad
{
    [super viewDidLoad];
//    NSManagedObjectContext *context = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
//    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
//    NSDateComponents *components = [gregorian 
//                                    components: NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit 
//                                    fromDate: [NSDate date]];
//    [components setHour: 0];
//    NSDate *testDate = [gregorian dateFromComponents: components];
//    for (int i = 1; i < 10; i++) {
//        Event *event = [NSEntityDescription insertNewObjectForEntityForName: @"Event" inManagedObjectContext: context];
//        [event setEventDescription: [NSString stringWithFormat: @"%d-th long event in my life", i]];
//        [event setEventTitle: [NSString stringWithFormat: @"%d-th long event", i]];
//        [event setStartDate: [NSNumber numberWithDouble: [testDate timeIntervalSince1970] + 84600*(i-4)]];
//        [event setEndDate: [NSNumber numberWithDouble: [testDate timeIntervalSince1970] + 84600*(i+1 + i/10)]];
//        NSError *error;
//        [context save: &error];
//        if (error) {
//            NSLog(@"Something went wrong while saving context. %@", error);
//        }
//    }
//    for (int i = 1; i < 10; i++) {
//        Event *event = [NSEntityDescription insertNewObjectForEntityForName: @"Event" inManagedObjectContext: context];
//        [event setEventDescription: [NSString stringWithFormat: @"%d-th short event in my life", i]];
//        [event setEventTitle: [NSString stringWithFormat: @"%d-th short event", i]];
//        [event setStartDate: [NSNumber numberWithDouble: [testDate timeIntervalSince1970] + 3600*i]];
//        [event setEndDate: [NSNumber numberWithDouble: [testDate timeIntervalSince1970] + 3600*(i + 1.0 + i/10)]];
//        NSError *error;
//        [context save: &error];
//        if (error) {
//            NSLog(@"Something went wrong while saving context. %@", error);
//        }
//    }
    UINib *test = [UINib nibWithNibName: @"DayView" bundle: nil];
    DayView *nya = [[test instantiateWithOwner: self options: nil] objectAtIndex: 0];
    //    [[nya layer] setBorderWidth: 10];
    [[self view] addSubview: nya];
    [nya setTargetDate: [NSDate date]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
