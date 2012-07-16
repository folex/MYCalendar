//
//  DayView.h
//  MYCalendar
//
//  Created by Alexey on 10.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
@class TaskDetailedView, DayViewInformationSheet;

static NSString *nibName = @"DayView";

@interface DayView : UIView <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *taskBriefView;
@property (weak, atomic) DayViewInformationSheet *informationSheet;
@property (weak, atomic) DayViewInformationSheet *oldInformationSheet;

@property TaskDetailedView *taskDetailedView;
@property NSFetchedResultsController *fetchedResultsController;
@property CGPoint firstTouch;
@property CGPoint sheetOrigin;
@property UIPanGestureRecognizer *panRecognizer;

- (void) setTargetDate: (NSDate*) targetDate;
@end
