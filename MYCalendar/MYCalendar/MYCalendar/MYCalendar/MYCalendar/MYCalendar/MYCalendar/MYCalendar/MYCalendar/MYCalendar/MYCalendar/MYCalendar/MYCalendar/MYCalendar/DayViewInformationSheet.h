//
//  DayViewInformationSheet.h
//  MYCalendar
//
//  Created by Alexey on 12.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DayViewInformationSheet : UIView
@property IBOutlet UILabel *mainDateLabel;
@property IBOutlet UILabel *secondaryDateLabel;
@property IBOutlet UILabel *durationLabel;
@property IBOutlet UILabel *statusLabel;
@property IBOutlet UILabel *titleLabel;
@property IBOutlet UITextView *descriptionLabel;
@property (nonatomic) NSDate *targetDate;
@end
