//
//  DatePickPopoverContent.m
//  MYCalendar
//
//  Created by Alexey on 23.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DatePickPopoverContent.h"
#import "AppDelegate.h"
#import "Event.h"
#import <QuartzCore/QuartzCore.h>

@interface DatePickPopoverContent ()

@end

@implementation DatePickPopoverContent
@synthesize titleField;
@synthesize picker;
@synthesize startButton;
@synthesize endButton;
@synthesize setDateButton;
@synthesize descriptionTextView;
@synthesize saveButton;
@synthesize cancelButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"TADAAAAAAAM!");
	// Do any additional setup after loading the view.
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

- (void) awakeFromNib
{
    [[[self startButton] layer] setCornerRadius: 5.0];
    [[[self endButton] layer] setCornerRadius: 5.0];
}

- (IBAction)savePickedData:(id)sender 
{
    NSManagedObjectContext *context = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    Event *event = [NSEntityDescription insertNewObjectForEntityForName: @"Event" inManagedObjectContext: context];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"dd MMM yyyy HH:mm"];
    [event setStartDate: [NSNumber numberWithDouble: [[formatter dateFromString: [[[self startButton] titleLabel] text]] timeIntervalSince1970]]];
    [event setEndDate: [NSNumber numberWithDouble: [[formatter dateFromString: [[[self endButton] titleLabel] text]] timeIntervalSince1970]]];
    [event setEventTitle: [[self titleField] text]];
    [event setEventDescription: [[self descriptionTextView] text]];
    NSError *fetchingError;
    if ([context save:&fetchingError])
    {
        NSLog(@"Successfully saved the context."); 
    } else 
    {
        NSLog(@"Failed to save the context. Error = %@", fetchingError); 
    }
    
    [(UIPopoverController*)[[(AppDelegate*)[[UIApplication sharedApplication] delegate] calendarViewController] 
                            performSelector: @selector(popover)] dismissPopoverAnimated: YES];
    
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] updateTableViews];
}

- (IBAction)cancelPicking:(id)sender 
{
    [(UIPopoverController*)[[(AppDelegate*)[[UIApplication sharedApplication] delegate] calendarViewController] 
                            performSelector: @selector(popover)] dismissPopoverAnimated: YES];
}

- (IBAction)showDatePicker:(id)sender 
{
    CGRect viewFrame = [[self view] frame];
    viewFrame.size.width = 313;
    viewFrame.size.height = 447;
    CGRect startFrame = {{20, 10}, {273, 52}};
    CGRect endFrame = {{20, 77}, {272, 52}};
    CGRect pickerFrame = {{-6, 155}, {324, 216}};
    CGRect saveFrame = {{20, 393}, {92, 44}};
    CGRect cancelFrame = {{201, 393}, {92, 44}};
    [UIView animateWithDuration: 0.5 animations:^{
        [[self view] setFrame: viewFrame];
        [[self titleField] setHidden: YES];
        [[self setDateButton] setHidden: YES];
        [[self descriptionTextView] setHidden: YES];
        [[self startButton] setFrame: startFrame];
        [[self startButton] setHidden: NO];
        [[self endButton] setFrame: endFrame];
        [[self endButton] setHidden: NO];
        [[self picker] setFrame: pickerFrame];
        [[self picker] setHidden: NO];
        [[self saveButton] setFrame: saveFrame];
        [[self cancelButton] setFrame: cancelFrame];
        [(UIPopoverController*)[[(AppDelegate*)[[UIApplication sharedApplication] delegate] calendarViewController] 
                                performSelector: @selector(popover)] 
         setPopoverContentSize:viewFrame.size animated: YES];
    }];
}

- (void) SetOnChangeButton: (UIButton*) button
{
    if (self->_onChangeButton != nil) {
        [self->_onChangeButton setBackgroundColor: [UIColor whiteColor]];
        if (self->_onChangeButton == [self startButton]) {
            [[self picker] setMinimumDate: [[self picker] date]];
            [[self picker] setMaximumDate: nil];

        } else if (self->_onChangeButton == [self endButton]) {
            [[self picker] setMinimumDate: nil];
            [[self picker] setMaximumDate: [[self picker] date]];
        }
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"dd MMM yyyy HH:mm"];
    [button setTitle: [formatter stringFromDate: [[self picker] date]] forState: UIControlStateNormal];    
    self->_onChangeButton = button;
    [self->_onChangeButton setBackgroundColor: [UIColor lightGrayColor]];
}

- (void) dateSelected: (UIDatePicker*) sender
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"dd MMM yyyy HH:mm"];
    [self->_onChangeButton setTitle: [formatter stringFromDate: [sender date]] forState: UIControlStateNormal];
}

@end
