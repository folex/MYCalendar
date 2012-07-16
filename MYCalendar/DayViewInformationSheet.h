//
//  DayViewInformationSheet.h
//  MYCalendar
//
//  Created by Alexey on 12.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DayViewInformationSheet : UIView
@property (weak, nonatomic) IBOutlet UILabel *mainDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondaryDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionLabel;
@end
