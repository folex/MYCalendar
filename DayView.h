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

@interface DayView : UIView <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *taskBriefView;
@property (weak, atomic) DayViewInformationSheet *informationSheet;
@property (weak, atomic) DayViewInformationSheet *oldInformationSheet;
@property (weak, nonatomic) IBOutlet UIScrollView *informationSheetScroll;

@property TaskDetailedView *taskDetailedView;
@property NSMutableArray *informationSheets;

- (void) setTargetDate: (NSDate*) targetDate;
@end
