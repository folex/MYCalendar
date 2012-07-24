//
//  TaskDetailedView.h
//  MYCalendar
//
//  Created by Alexey on 10.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface TaskDetailedView : UITableView <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *taskTable;
@property NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property NSMutableArray *markRectangles;
@property UIPopoverController *datePickPopover;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addTaskBarButton;

- (IBAction)addTask:(id)sender;
@end
